const auth = require('./middleware/auth');
const config = require('./middleware/configs');
const collections = require('./middleware/firestoreCollections');
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const utils = require('./middleware/utils');

function removeSensitiveFieldsFromAppointments(appointments) {
	if (!appointments) {
		return [];
	}

  return appointments.map(appointment => {
    return {
      start: appointment.start,
      end: appointment.end,
    };
  });
}

function removeSensitiveFieldsFromProfile(id, data) {
	return {
		id: id,
		name: data.name,
		contact: data.contact,
		scheduleRules: data.scheduleRules,
		scheduleRulesExceptions: data.scheduleRulesExceptions,
		sessionDuration: data.sessionDuration,
    timezoneOffset: data.timezoneOffset,

		bookedAppointments: removeSensitiveFieldsFromAppointments(data.bookedAppointments),
		pendingAppointments: removeSensitiveFieldsFromAppointments(data.pendingAppointments),
	};
}

exports.searchProfessionals = functions.https.onCall(config.httpsOptions, async (request) => {
	try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.PATIENT);

    const startAfter = request.data?.startAfter;

    const queryLimit = 10;
    let query = collections.professionalProfiles.limit(queryLimit).orderBy(admin.firestore.FieldPath.documentId());

    if (startAfter != null) {
      query = query.startAfter(startAfter);
    }

		const snapshot = await query.get();

		const professionals = snapshot.docs.map(doc => {
			return removeSensitiveFieldsFromProfile(doc.id, doc.data());
		});

    const lastDocId = snapshot.docs.length > 0
      ? snapshot.docs[snapshot.docs.length - 1].id
      : null;

    const canLoadMore = snapshot.docs.length == queryLimit;

		return {
      success: true,
      lastDocId: lastDocId,
      canLoadMore: canLoadMore,
      professionals: professionals,
    };
  } catch (error) {
    return {success: false, message: error.message};
  }
});

exports.getProfessionalFromId = functions.https.onCall(config.httpsOptions, async (request) => {
	try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.PATIENT);

    const professionalId = request.data?.professionalId;
    if (!professionalId) {
      throw new Error("Missing required fields: professionalId");
    }

		const doc = await collections.professionalProfiles.doc(professionalId).get();

		if (!doc.exists) {
      throw new Error("No professional found");
		}

		const data = doc.data();
		return {
			success: true,
			...removeSensitiveFieldsFromProfile(doc.id, data),
		};
  } catch (error) {
    return {success: false, message: error.message};
  }
});

exports.getMultipleProfessionalsFromIds = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
    auth.requireAuth(request.auth);
    auth.checkUserType(request.auth, config.PATIENT);

    const { professionalIds } = request.data;
    if (!professionalIds || !Array.isArray(professionalIds)) {
      throw new Error("Missing or invalid 'professionalIds' array");
    }

		if (professionalIds.length === 0) {
      throw new Error("professionalIds passed is empty");
		}

    const chunks = [];
    for (let i = 0; i < professionalIds.length; i += 10) {
      chunks.push(professionalIds.slice(i, i + 10));
    }

    const promises = chunks.map(chunk => {
      return collections.professionalProfiles
        .where(admin.firestore.FieldPath.documentId(), 'in', chunk)
        .get();
    });

    const snapshots = await Promise.all(promises);

    const profiles = [];
    snapshots.forEach(snapshot => {
      snapshot.forEach(doc => {
        const data = doc.data();
        profiles.push(removeSensitiveFieldsFromProfile(doc.id, data));
      });
    });

    return { success: true, professionals: profiles };
  } catch (error) {
    return { success: false, message: error.message };
  }
});

exports.updateProfessionalProfile = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
    auth.requireAuth(request.auth);
    auth.checkUserType(request.auth, config.PROFESSIONAL);

    let newProfileData = {};
    const profileData = request.data;

    if (profileData.contact != null) {
      newProfileData.contact = utils.sanitizeString(profileData.contact, 256);
    }

    if (
      profileData.scheduleRules != null &&
      typeof profileData.scheduleRules === 'object' &&
      !Array.isArray(profileData.scheduleRules)
    ) {
      const scheduleRulesMap = {};
    
      for (const [key, value] of Object.entries(profileData.scheduleRules)) {
        // Validate day index
        const dayIndex = parseInt(key, 10);
        if (isNaN(dayIndex) || dayIndex < 0 || dayIndex > 6) {
          throw new Error(`Invalid day index: ${key}`);
        }
    
        if (!Array.isArray(value)) {
          throw new Error(`Invalid schedule format for day ${key}`);
        }
    
        if (!utils.isWorkPeriodValid(value)) {
          throw new Error(`Invalid work period on day ${key}`);
        }

        scheduleRulesMap[dayIndex] = value;
      }
    
      newProfileData.scheduleRules = scheduleRulesMap;
    }

    if (profileData.scheduleRulesExceptions != null) {
      if (!Array.isArray(profileData.scheduleRulesExceptions)) throw new Error('ScheduleRulesExceptions is not a array');

      let rules = [];

      for (const rule of profileData.scheduleRulesExceptions) {
        if (rule.range != null && rule.days != null) throw new Error('Invalid rule day selection');
        if (rule.range == null && rule.days == null) throw new Error('Invalid rule, no day selection');

        let sanitizedRule = {};

        if (rule.range != null) {
          if (!Number.isInteger(rule.range.start)) throw new Error('Error parsing start');
          if (!Number.isInteger(rule.range.end)) throw new Error('Error parsing end');

          sanitizedRule.range = {
            start: rule.range.start,
            end: rule.range.end,
          };
        }

        if (rule.days != null) {
          if (!Array.isArray(rule.days)) throw new Error('days is not a array');

          sanitizedRule.days = rule.days.map(item => {
            if (!Number.isInteger(item)) throw new Error('Invalid timestamp object in days');

            return item;
          });
        }

        if (rule.periods != null) {
          if (!Array.isArray(rule.periods)) throw new Error('Periods is not a array');
          if (!utils.isWorkPeriodValid(rule.periods)) throw new Error('Invalid work period');

          sanitizedRule.periods = rule.periods;
        }

        rules.push(sanitizedRule);
      }

      newProfileData.scheduleRulesExceptions = rules;
    }

    if (profileData.sessionDuration != null) {
      if (!Number.isInteger(profileData.sessionDuration)) throw new Error('sessionDuration is not a number');
      if (profileData.sessionDuration <= 0) throw new Error('sessionDuration is not possitive');

      newProfileData.sessionDuration = profileData.sessionDuration;
    }

    if (profileData.timezoneOffset != null) {
      if (!Number.isInteger(profileData.timezoneOffset)) throw new Error('timezoneOffset is not a number');
      if (Math.abs(profileData.timezoneOffset) > (12 * 60)) throw new Error('timezoneOffset is not supported');

      newProfileData.timezoneOffset = profileData.timezoneOffset;
    }

    if (profileData.firebaseMessagingToken != null) {
      newProfileData.firebaseMessagingToken = utils.sanitizeString(profileData.firebaseMessagingToken, 512);
    }

    if (profileData.recentRecords != null && Array.isArray(profileData.recentRecords)) {
      newProfileData.recentRecords = profileData.recentRecords.map((item) =>
        utils.sanitizeString(item, 64)
      );
    }

    if (Object.keys(newProfileData).length > 0) {
      const uid = request.auth.uid;
      await collections.professionalProfiles.doc(uid).update(newProfileData);
    }

    return { success: true };
  } catch (error) {
    return { success: false, message: error.message };
  }
});
