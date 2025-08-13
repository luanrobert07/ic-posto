const auth = require('./middleware/auth');
const config = require('./middleware/configs');
const collections = require('./middleware/firestoreCollections');
const kmsHelper = require('./middleware/kms');
const encryption = require('./middleware/encryption');
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { KeyManagementServiceClient } = require("@google-cloud/kms");

const kmsClient = new KeyManagementServiceClient();

exports.createChat = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);

		const uid = request.auth.uid;
		const {participantId, dek} = request.data;

		if (!participantId) {
			throw new Error('participantId attribute is missing');
		}
		if (!dek) {
			throw new Error('dek attribute is missing');
		}

		var patientId;
		var professionalId;
		if (request.auth.token.userType == config.PATIENT) {
			patientId = uid;
			professionalId = participantId;

			// Check if professional exists
			const professional = await collections.professionalProfiles.doc(professionalId).get();
			if (!professional.exists) {
				throw new Error("No patient found");
			}
		} else if (request.auth.token.userType == config.PROFESSIONAL) {
			patientId = participantId;
			professionalId = uid;

			// Check if patient exists
			const patient = await collections.patientProfiles.doc(patientId).get();
			if (!patient.exists) {
				throw new Error("No patient found");
			}
		} else {
      throw new Error(`User type ${request.auth.token.userType} cant create a chat`);
		}

		const chatId = `${patientId}_${professionalId}`;
		const chatRef = collections.chats.doc(chatId);
		const chatDoc = await chatRef.get();

		if (chatDoc.exists) {
      throw new Error('Chat already exists');
		}

		await chatRef.set({
			participants: [patientId, professionalId],
			dek: dek,
			createdAt: admin.firestore.FieldValue.serverTimestamp(),
		});

		return { success: true, id: chatId };
  } catch (error) {
    return { success: false, message: error.message };
  }
});

exports.getChatKey = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);
		const uid = request.auth.uid;

		const {chatId, publicKey} = request.data;
		if (!chatId) {
			throw new Error('chatId attribute is missing');
		}
		if (!publicKey) {
			throw new Error('publicKey attribute is missing');
		}

		const chatDoc = await collections.chats.doc(chatId).get();

		if (!chatDoc.exists) {
			throw new Error('Chat does not exist');
		}

		const chat = chatDoc.data();

		if (!chat.participants.includes(uid)) {
			throw new Error('Permission denied, request uid does not match any chat participants');
		}

		const userType = request.auth.token.userType;
		var professionalId;
		if (userType == config.PROFESSIONAL) {
			professionalId = uid;
		} else if (userType == config.PATIENT) {
			if (uid == chat.participants[0]) {
				professionalId = chat.participants[1];
			} else if (uid == chat.participants[1]) {
				professionalId = chat.participants[0];
			}
		}

		const keyName = kmsClient.cryptoKeyVersionPath(
			config.projectId,
			config.region,
			config.professionalsKeyring,
			professionalId,
			'1'
		);

    const [decryptResponse] = await kmsClient.asymmetricDecrypt({
			name: keyName,
			ciphertext: chat.dek,
		});
		const dek = decryptResponse.plaintext.toString('utf8');

		const encryptedDek = encryption.encryptWithRsaPublicKey(dek, publicKey);

		return {success: true, dek: encryptedDek};
  } catch (error) {
    return {success: false, message: error.message};
  }
});

exports.sendChatMessage = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);
		const uid = request.auth.uid;

		const {chatId, data} = request.data;
		if (!chatId) {
			throw new Error('chatId attribute is missing');
		}
		if (!data) {
			throw new Error('data attribute is missing');
		}

		const chatDoc = collections.chats.doc(chatId);
		const chatSnapshot = await chatDoc.get();

		if (!chatSnapshot.exists) {
			throw new Error('Chat does not exist');
		}

		const chat = chatSnapshot.data();

		if (!chat.participants.includes(uid)) {
			throw new Error('Permission denied, request uid does not match any chat participants');
		}

		const userType = request.auth.token.userType;
		var participantProfileId;
		if (uid === chat.participants[0]) {
			participantProfileId = chat.participants[1];
		} else if (uid === chat.participants[1]) {
			participantProfileId = chat.participants[0];
		}

		var collection;
		var participantCollection;
		if (userType === config.PROFESSIONAL) {
			participantCollection = collections.patientProfiles;
			collection = collections.professionalProfiles;
		} else if (userType === config.PATIENT) {
			participantCollection = collections.professionalProfiles;
			collection = collections.patientProfiles;
		}

		const participantProfileDoc = participantCollection.doc(participantProfileId);
		const participantProfileSnapshot = await participantProfileDoc.get();
		const participantProfile = participantProfileSnapshot.data();

		await admin.firestore().runTransaction(async (transaction) => {
			// Updates chat last message field
			transaction.set(chatDoc, {
				lastMessage: admin.firestore.FieldValue.serverTimestamp(),
			}, { merge: true });

      // Increment notification count
      transaction.set(participantProfileDoc, {
        chatNotifications: {
					[chatId]: {
						count: admin.firestore.FieldValue.increment(1),
						createdAt: new Date(),
					}
				}
      }, { merge: true });

      // Add message to subcollection
      const messageRef = chatDoc.collection('messages').doc();
      transaction.set(messageRef, {
        data: data,
        sentBy: uid,
        sent: admin.firestore.FieldValue.serverTimestamp()
      });
    });

		if (participantProfile.firebaseMessagingToken != null) {
			const profileDoc = collection.doc(uid);
			const profileSnapshot = await profileDoc.get();
			const profile = profileSnapshot.data();

			var notificationsCount = 0;
			if (participantProfile.chatNotifications != null) {
				notificationsCount = participantProfile.chatNotifications?.[chatId] ?? 0;
			}

			try {
				admin.messaging().send({
					token: participantProfile.firebaseMessagingToken,
					notification: {
						title: profile.name,
						body: `${notificationsCount+1} novas mensagens.`,
					},
					data: {
						screen: 'chats',
						chatId: chatId,
					},
	
					android: {
						priority: 'high',
						"collapse_key": chatId,
						notification: {
							tag: chatId,
							visibility: 'SECRET',
						}
					},
				
					apns: {
						headers: {
							'apns-priority': '5'
						},
						payload: {
							aps: {
								badge: 1,
								sound: 'default'
							}
						}
					}
				});
			} catch (_) {
			}
		}

		return {success: true};
  } catch (error) {
    return {success: false, message: error.message};
  }
});

exports.removeChatNotification = functions.https.onCall(config.httpsOptions, async (request) => {
  try {
		auth.requireAuth(request.auth);

		const {chatId} = request.data;
		if (!chatId) {
			throw new Error('chatId attribute is missing');
		}

		const uid = request.auth.uid;
		const userType = request.auth.token.userType;

		var collection;
		if (userType === config.PROFESSIONAL) {
			collection = collections.professionalProfiles;
		} else if (userType === config.PATIENT) {
			collection = collections.patientProfiles;
		} else {
      throw new Error("Wrong account type");
		}

		collection.doc(uid).update({
			chatNotifications: {
				[chatId]: admin.firestore.FieldValue.delete(),
			},
		});

		return {success: true};
  } catch (error) {
    return {success: false, message: error.message};
  }
});
