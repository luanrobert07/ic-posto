const auth = require('./middleware/auth');
const config = require('./middleware/configs');
const collections = require('./middleware/firestoreCollections');
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const utils = require('./middleware/utils');

function removeSensitiveFieldsFromProfile(id, data) {
	return {
		id: id,
		name: data.name,
		contact: data.contact,
	};
}

exports.getPatientFromId = functions.https.onCall(config.httpsOptions, async (request) => {
	try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.PROFESSIONAL);

    const {patientId} = request.data;
    if (!patientId) {
      throw new Error("Missing required fields: patientId");
    }

		const doc = await collections.patientProfiles.doc(patientId).get();

		if (!doc.exists) {
      throw new Error("No patient found");
		}

		const data = doc.data();
		return {
			success: true,
			...removeSensitiveFieldsFromProfile(doc.id, data),
		};
  } catch (error) {
    console.error('getPatientFromId error:', error);
    return {success: false, message: error.message};
  }
});

exports.getMultiplePatientsFromIds = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
    auth.requireAuth(request.auth);
    auth.checkUserType(request.auth, config.PROFESSIONAL);

    const { patientIds } = request.data;
    if (!patientIds || !Array.isArray(patientIds)) {
      throw new Error("Missing or invalid 'patientIds' array");
    }

		if (patientIds.length === 0) {
      throw new Error("patientIds passed is empty");
		}

    const chunks = [];
    for (let i = 0; i < patientIds.length; i += 10) {
      chunks.push(patientIds.slice(i, i + 10));
    }

    const promises = chunks.map(chunk => {
      return collections.patientProfiles
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

    return { success: true, patients: profiles };
  } catch (error) {
    console.error('getMultiplePatientsFromIds error:', error);
    return { success: false, message: error.message };
  }
});

exports.updatePatientProfile = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
    auth.requireAuth(request.auth);
    auth.checkUserType(request.auth, config.PATIENT);

    let newProfileData = {};
    const profileData = request.data;

    if (profileData.contact != null) {
      newProfileData.contact = utils.sanitizeString(profileData.contact, 256);
    }

    if (profileData.firebaseMessagingToken != null) {
      newProfileData.firebaseMessagingToken = utils.sanitizeString(profileData.firebaseMessagingToken, 512);
    }

    if (Object.keys(newProfileData).length > 0) {
      const uid = request.auth.uid;
      await collections.patientProfiles.doc(uid).update(newProfileData);
    }

    return { success: true };
  } catch (error) {
    return { success: false, message: error.message };
  }
});
