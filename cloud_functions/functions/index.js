const admin = require("firebase-admin");

admin.initializeApp();

const userRoles = require('./src/userRoles');
exports.addPatientRole = userRoles.addPatientRole;
exports.addProfessionalRole = userRoles.addProfessionalRole;
exports.addAgentRole = userRoles.addAgentRole;

const appointments = require('./src/appointments');
exports.requestAppointment = appointments.requestAppointment;
exports.acceptPendingAppointment = appointments.acceptPendingAppointment;
exports.declinePendingAppointment = appointments.declinePendingAppointment;

const professionals = require('./src/professionals');
exports.searchProfessionals = professionals.searchProfessionals;
exports.getProfessionalFromId = professionals.getProfessionalFromId;
exports.getMultipleProfessionalsFromIds = professionals.getMultipleProfessionalsFromIds;
exports.updateProfessionalProfile = professionals.updateProfessionalProfile;

const patients = require('./src/patients');
exports.getMultiplePatientsFromIds = patients.getMultiplePatientsFromIds;
exports.getPatientFromId = patients.getPatientFromId;
exports.updatePatientProfile = patients.updatePatientProfile;

const kms = require('./src/kms');
exports.getPublicKey = kms.getPublicKey;
exports.createPublicKey = kms.createPublicKey;
exports.decryptDek = kms.decryptDek;

const chat = require('./src/chat');
exports.createChat = chat.createChat;
exports.getChatKey = chat.getChatKey;
exports.sendChatMessage = chat.sendChatMessage;
exports.removeChatNotification = chat.removeChatNotification;

const misc = require('./src/misc');
exports.getServerTimestamp = misc.getServerTimestamp;
