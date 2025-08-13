const config = require('./middleware/configs');
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

exports.getServerTimestamp = functions.https.onCall(config.httpsOptions, async (request) => {
	try {
		return {
			success: true,
			serverTimestamp: admin.firestore.Timestamp.now().seconds,
		};
  } catch (error) {
    console.error('getServerTime error:', error);
    return {success: false, message: error.message};
  }
});
