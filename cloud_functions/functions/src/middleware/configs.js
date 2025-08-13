const region = 'southamerica-east1';
const timeoutSeconds = 10;

exports.region = region;
exports.projectId = 'ic-posto';
exports.httpsOptions = {
	region: region,
	timeoutSeconds: timeoutSeconds,
}

exports.NONE = undefined;
exports.PATIENT = 'patient';
exports.PROFESSIONAL = 'professional';
exports.AGENT = 'agent';

exports.professionalsKeyring = 'professionals';
