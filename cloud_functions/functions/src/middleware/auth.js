function requireAuth(auth) {
	if (!auth) {
		throw new Error('User must be logged in');
	}

	const uid = auth.uid;
	if (!uid) {
		throw new Error('UID is missing');
	}

	const token = auth.token;
	if (!token) {
		throw new Error('Auth token is missing');
	}
}

function checkUserType(auth, expectedUserType) {
	const userType = auth.token.userType;
	if (userType === expectedUserType) {
		return;
	}

  throw new Error(`User is type ${auth.token.userType} and not ${expectedUserType}`);
}

exports.requireAuth = requireAuth;
exports.checkUserType = checkUserType;
