const config = require('./configs');
const { KeyManagementServiceClient } = require("@google-cloud/kms");

const kmsClient = new KeyManagementServiceClient();

async function getPublicKeyFromKms(professionalId) {
	const keyName = kmsClient.cryptoKeyVersionPath(
		config.projectId,
		config.region,
		config.professionalsKeyring,
		professionalId,
		'1'
	);

	const [publicKey] = await kmsClient.getPublicKey({
		name: keyName,
	});

	return publicKey;
}
exports.getPublicKeyFromKms = getPublicKeyFromKms;
