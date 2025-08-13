const auth = require('./middleware/auth');
const config = require('./middleware/configs');
const collections = require('./middleware/firestoreCollections');
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const utils = require('./middleware/utils');

exports.requestAppointment = functions.https.onCall(config.httpsOptions, async (request) => {
	try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.PATIENT);

    const {professionalId, start, end} = request.data;
    if (!professionalId || !start || !end) {
      throw new Error("Missing required fields: professionalId, start, or end");
    }
		const startTimestamp = new admin.firestore.Timestamp(start, 0);
		const endTimestamp = new admin.firestore.Timestamp(end, 0);

    const uid = request.auth.uid;

		const patientRef = collections.patientProfiles.doc(uid);
		const professionalRef = collections.professionalProfiles.doc(professionalId);
    const professionalDoc = await professionalRef.get();
    
    if (!professionalDoc.exists) {
      throw new Error("Professional not found");
    }

    const professionalData = professionalDoc.data();
    const {pendingAppointments=[], bookedAppointments=[], scheduleRules={}, scheduleRulesExceptions=[], sessionDuration, timezoneOffset = 0} = professionalData;
		const allAppointments = [...pendingAppointments, ...bookedAppointments];

    // Check for existing appointments with the same start
    var isAppointmentConflict = allAppointments.some(appointment => {
      return appointment.start === start;
    });

    if (isAppointmentConflict) {
      throw new Error("There is already an appointment scheduled for this time.");
    }

		const exceptionApplies = scheduleRulesExceptions.some((rule) => utils.isRuleSameDayAsDate(rule, startTimestamp));
		if (exceptionApplies) {
			const matchesAny = scheduleRulesExceptions.some(rule => {
				return utils.doesRuleCoverPeriod(rule, startTimestamp.toDate(), endTimestamp.toDate(), timezoneOffset);
			});
			if (!matchesAny) {
				throw new Error("Appointment does not match any rules");
			}
		} else {
			const matchesAny = utils.doesAppointmentMatchSlot(startTimestamp.toDate(), endTimestamp.toDate(), scheduleRules, sessionDuration, timezoneOffset);
			if (!matchesAny) {
				throw new Error('Appointment does not match any slots');
			}
		}

    const appointment = {
      patientId: uid,
			professionalId: professionalId,
      start,
      end,
			createdAt: new Date(),
    };

		await admin.firestore().runTransaction(async (transaction) => {
			transaction.update(professionalRef, {
				pendingAppointments: admin.firestore.FieldValue.arrayUnion(appointment),
			});

			transaction.update(patientRef, {
				pendingAppointments: admin.firestore.FieldValue.arrayUnion(appointment),
			});
		});

    return {success: true};
  } catch (error) {
    console.error('requestAppointment error:', error);
    return {success: false, message: error.message};
  }
});

exports.acceptPendingAppointment = functions.https.onCall(config.httpsOptions, async (request) => {
	try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.PROFESSIONAL);

    const {appointment} = request.data;
    if (!appointment) {
      throw new Error("Missing required fields: appointment");
    }

		const patientId = appointment.patientId;
		const professionalId = request.auth.uid;

		const patientRef = collections.patientProfiles.doc(patientId);
		const professionalRef = collections.professionalProfiles.doc(professionalId);

		await admin.firestore().runTransaction(async (transaction) => {
			const professionalSnap = await transaction.get(professionalRef);
			const professionalData = professionalSnap.data();
			if (!professionalData) throw new Error("Professional profile not found");
	
			const pendingAppointments = professionalData.pendingAppointments || [];
	
			// Find the matching appointment using the identifying fields
			const appointmentToRemove = pendingAppointments.find((a) =>
				a.patientId === appointment.patientId &&
				a.start === appointment.start &&
				a.end === appointment.end
			);
	
			if (!appointmentToRemove) {
				throw new Error("Matching appointment not found in pendingAppointments");
			}
	
			const acceptedAt = new Date();
			const appointmentToBook = {
				...appointmentToRemove,
				lastInteractionAt: acceptedAt,
			};
	
			const now = new Date();
			const apptStart = new admin.firestore.Timestamp(appointmentToRemove.start, 0).toDate();
			if (apptStart <= now) {
				throw new Error("Can't accept appointment after it started");
			}

			transaction.update(patientRef, {
				pendingAppointments: admin.firestore.FieldValue.arrayRemove(appointmentToRemove),
				bookedAppointments: admin.firestore.FieldValue.arrayUnion(appointmentToBook),
			});

			transaction.update(professionalRef, {
				pendingAppointments: admin.firestore.FieldValue.arrayRemove(appointmentToRemove),
				bookedAppointments: admin.firestore.FieldValue.arrayUnion(appointmentToBook),
			});
		});

    return { success: true };
  } catch (error) {
    console.error('acceptPendingAppointment error:', error);
    return {success: false, message: error.message};
  }
});

exports.declinePendingAppointment = functions.https.onCall(config.httpsOptions, async (request) => {
	try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.PROFESSIONAL);

    const {appointment} = request.data;
    if (!appointment) {
      throw new Error("Missing required fields: appointment");
    }

		const patientId = appointment.patientId;
		const professionalId = request.auth.uid;

		const patientRef = collections.patientProfiles.doc(patientId);
		const professionalRef = collections.professionalProfiles.doc(professionalId);
		const patientAppointmentHistoryRef = patientRef.collection('appointment_history').doc();
		const professionalAppointmentHistoryRef = professionalRef.collection('appointment_history').doc();

    await admin.firestore().runTransaction(async (transaction) => {
			const professionalSnap = await transaction.get(professionalRef);
			const professionalData = professionalSnap.data();
			if (!professionalData) throw new Error("Professional profile not found");

			const pendingAppointments = professionalData.pendingAppointments || [];

			// Find the matching appointment using the identifying fields
			const appointmentToRemove = pendingAppointments.find((a) =>
				a.patientId === appointment.patientId &&
				a.start === appointment.start &&
				a.end === appointment.end
			);

			if (!appointmentToRemove) {
				throw new Error("Matching appointment not found in pendingAppointments");
			}

			transaction.set(patientAppointmentHistoryRef, {
				...appointmentToRemove,
				status:'declined',
				lastInteractionAt: admin.firestore.FieldValue.serverTimestamp(),
			});

			transaction.set(professionalAppointmentHistoryRef, {
				...appointmentToRemove,
				status:'declined',
				lastInteractionAt: admin.firestore.FieldValue.serverTimestamp(),
			});

      transaction.update(patientRef, {
        'pendingAppointments': admin.firestore.FieldValue.arrayRemove(appointmentToRemove),
      });

      transaction.update(professionalRef, {
        'pendingAppointments': admin.firestore.FieldValue.arrayRemove(appointmentToRemove),
      });
    });

    return { success: true };
  } catch (error) {
    console.error('declinePendingAppointment error:', error);
    return {success: false, message: error.message};
  }
});
