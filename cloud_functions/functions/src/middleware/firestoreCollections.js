const admin = require("firebase-admin");

const db = admin.firestore();

// exports.patientPrivateProfiles = db.collection('patientPrivateProfiles');
// exports.patientPublicProfiles = db.collection('patientPublicProfiles');
// exports.professionalPrivateProfiles = db.collection('professionalPrivateProfiles');
// exports.professionalPublicProfiles = db.collection('professionalPublicProfiles');

exports.patientProfiles = db.collection('patientProfiles');
exports.professionalProfiles = db.collection('professionalProfiles');
exports.chats = db.collection('chats');
