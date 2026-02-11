const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// ============================
// Roles
// ============================
exports.addPatientRole = functions.https.onCall(async (data, context) => {
  const { name, email } = data;
  if (!email) throw new functions.https.HttpsError('invalid-argument', 'Email is required');
  
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { role: 'patient' });
  
  await db.collection('patients').doc(user.uid).set({ name, email }, { merge: true });

  return { success: true, message: 'Patient role added' };
});

exports.addProfessionalRole = functions.https.onCall(async (data, context) => {
  const { name, email } = data;
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { role: 'professional' });
  await db.collection('professionals').doc(user.uid).set({ name, email }, { merge: true });

  return { success: true, message: 'Professional role added' };
});

exports.addAgentRole = functions.https.onCall(async (data, context) => {
  const { name, email } = data;
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { role: 'agent' });
  await db.collection('agents').doc(user.uid).set({ name, email }, { merge: true });

  return { success: true, message: 'Agent role added' };
});

// ============================
// Appointments
// ============================
exports.requestAppointment = functions.https.onCall(async (data, context) => {
  await db.collection('appointments').add(data);
  return { success: true, message: 'Appointment requested' };
});

exports.acceptPendingAppointment = functions.https.onCall(async (data, context) => {
  const { appointment } = data;
  await db.collection('appointments').doc(appointment.id).update({ status: 'accepted' });
  return { success: true };
});

exports.declinePendingAppointment = functions.https.onCall(async (data, context) => {
  const { appointment } = data;
  await db.collection('appointments').doc(appointment.id).update({ status: 'declined' });
  return { success: true };
});

// ============================
// Professionals / Patients
// ============================
exports.getProfessionalFromId = functions.https.onCall(async (data, context) => {
  const doc = await db.collection('professionals').doc(data.professionalId).get();
  if (!doc.exists) throw new functions.https.HttpsError('not-found', 'Professional not found');
  return { success: true, ...doc.data(), id: doc.id };
});

exports.getPatientFromId = functions.https.onCall(async (data, context) => {
  const doc = await db.collection('patients').doc(data.patientId).get();
  if (!doc.exists) throw new functions.https.HttpsError('not-found', 'Patient not found');
  return { success: true, ...doc.data(), id: doc.id };
});

exports.getMultipleProfessionalsFromIds = functions.https.onCall(async (data, context) => {
  const ids = data.professionalIds;
  const result = [];
  for (let id of ids) {
    const doc = await db.collection('professionals').doc(id).get();
    if (doc.exists) result.push({ id: doc.id, ...doc.data() });
  }
  return { success: true, professionals: result };
});

exports.getMultiplePatientsFromIds = functions.https.onCall(async (data, context) => {
  const ids = data.patientIds;
  const result = [];
  for (let id of ids) {
    const doc = await db.collection('patients').doc(id).get();
    if (doc.exists) result.push({ id: doc.id, ...doc.data() });
  }
  return { success: true, patients: result };
});

// ============================
// Profile Updates
// ============================
exports.updateProfessionalProfile = functions.https.onCall(async (data, context) => {
  await db.collection('professionals').doc(data.id).update(data);
  return { success: true };
});

exports.updatePatientProfile = functions.https.onCall(async (data, context) => {
  await db.collection('patients').doc(data.id).update(data);
  return { success: true };
});

// ============================
// Public Key / Chat (exemplo simples)
// ============================
exports.createPublicKey = functions.https.onCall(async (data, context) => {
  // gerar chave pública fictícia
  const publicKey = "dummyPublicKey";
  const uid = context.auth.uid;
  await db.collection('keys').doc(uid).set({ publicKey });
  return { success: true, publicKey };
});

exports.getPublicKey = functions.https.onCall(async (data, context) => {
  const doc = await db.collection('keys').doc(data.professionalId).get();
  if (!doc.exists) throw new functions.https.HttpsError('not-found', 'Key not found');
  return { success: true, publicKey: doc.data().publicKey };
});

// Para chat, timestamp e mensagens você pode implementar de forma similar
