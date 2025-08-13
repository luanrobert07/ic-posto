const auth = require('./middleware/auth');
const config = require('./middleware/configs');
const collections = require('./middleware/firestoreCollections');
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

exports.addPatientRole = functions.https.onCall(config.httpsOptions, async (request) => {
	try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.NONE);

    const uid = request.auth.uid;
    const {name} = request.data;

    if (!name) throw new Error('name is missing');

    await collections.patientProfiles.doc(uid).set({
      name: name,
      role: config.PATIENT,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await admin.auth().setCustomUserClaims(uid, {userType: config.PATIENT});

    return {success: true};
  } catch (error) {
    console.error('addPatientRole error:', error);
    return {success: false, message: error.message};
  }
});

exports.addProfessionalRole = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.NONE);

    const uid = request.auth.uid;
    const {name} = request.data;

    if (!name) throw new Error('name is missing');

    await collections.professionalProfiles.doc(uid).set({
      name: name,
      role: config.PROFESSIONAL,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await admin.auth().setCustomUserClaims(uid, {userType: config.PROFESSIONAL});

    return {success: true};
  } catch (error) {
    console.error('addProfessionalRole error:', error);
    return {success: false, message: error.message};
  }
});

exports.addAgentRole = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.NONE);

    const uid = request.auth.uid;
    await admin.auth().setCustomUserClaims(uid, {userType: config.AGENT});

    return {success: true};
  } catch (error) {
    console.error('addAgentRole error:', error);
    return {success: false, message: error.message};
  }
});
