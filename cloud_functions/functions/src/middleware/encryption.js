const forge = require('node-forge');
const crypto = require('crypto');

function generateRsaKeyPair() {
  return new Promise((resolve) => {
    forge.pki.rsa.generateKeyPair({ bits: 2048, workers: 2 }, (err, keypair) => {
      const publicKeyPem = forge.pki.publicKeyToPem(keypair.publicKey);
      const privateKeyPem = forge.pki.privateKeyToPem(keypair.privateKey);
      resolve({ publicKey: publicKeyPem, privateKey: privateKeyPem });
    });
  });
}

function encryptWithRsaPublicKey(plaintext, publicKeyPem) {
  const buffer = Buffer.from(plaintext, 'utf-8');

  const encrypted = crypto.publicEncrypt(
    {
      key: publicKeyPem,
      padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
      oaepHash: 'sha256',
    },
    buffer
  );

  return encrypted.toString('base64');
}

function decryptWithRsaPrivateKey(ciphertextBase64, privateKeyPem) {
  const buffer = Buffer.from(ciphertextBase64, 'base64');

  const decrypted = crypto.privateDecrypt(
    {
      key: privateKeyPem,
      padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
      oaepHash: 'sha256',
    },
    buffer
  );

  return decrypted.toString('utf-8');
}

module.exports = {
	generateRsaKeyPair,
  encryptWithRsaPublicKey,
  decryptWithRsaPrivateKey,
};
