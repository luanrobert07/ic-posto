const auth = require('./middleware/auth');
const config = require('./middleware/configs');
const collections = require('./middleware/firestoreCollections');
const kmsHelper = require('./middleware/kms');
const encryption = require('./middleware/encryption');
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { KeyManagementServiceClient } = require("@google-cloud/kms");

const kmsClient = new KeyManagementServiceClient();

exports.getPublicKey = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);
		const professionalId = request.data.professionalId;

		if (!professionalId) {
			throw new Error('professionalId attribute is missing');
		}

		const publicKey = await kmsHelper.getPublicKeyFromKms(professionalId);
		
    return {success: true, publicKey: publicKey.pem};
  } catch (error) {
		if (error.code === 5) {
			return {success: false, message: 'NOT FOUND (5)'};
		}

    return {success: false, message: error.message};
  }
});

// Wait a few seconds before retrieving the public key after creation
exports.createPublicKey = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.PROFESSIONAL);

		const parent = kmsClient.keyRingPath(
			config.projectId,
			config.region,
			config.professionalsKeyring
		);
	
		await kmsClient.createCryptoKey({
			parent,
			cryptoKeyId: uid,
			cryptoKey: {
				purpose: 'ASYMMETRIC_DECRYPT',
				versionTemplate: {
					algorithm: 'RSA_DECRYPT_OAEP_2048_SHA256',
				},
				destroyScheduledDuration: {
					seconds: 60 * 60 * 24 * 7,  // 7 days
				},
			},
		});

		return {success: true};
  } catch (error) {
    return {success: false, message: error.message};
  }
});

exports.decryptDek = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);
		auth.checkUserType(request.auth, config.PROFESSIONAL);

		const {encryptedDek, publicKey} = request.data;
		if (!encryptedDek) {
			throw new Error('encryptedDek attribute is missing');
		}
		if (!publicKey) {
			throw new Error('publicKey attribute is missing');
		}

		const keyName = kmsClient.cryptoKeyVersionPath(
			config.projectId,
			config.region,
			config.professionalsKeyring,
			request.auth.uid,
			'1'
		);

    const [decryptResponse] = await kmsClient.asymmetricDecrypt({
			name: keyName,
			ciphertext: encryptedDek,
		});
		const dek = decryptResponse.plaintext.toString('utf8');

		const reEncryptedDek = encryption.encryptWithRsaPublicKey(dek, publicKey);

		return {success: true, dek: reEncryptedDek};
  } catch (error) {
    return {success: false, message: error.message};
  }
});
