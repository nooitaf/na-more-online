/* globals RocketChat */
RocketChat.getFullUserData = function({userId, filter, limit}) {
	let fields = {
		name: 1,
		username: 1,
		status: 1,
		services: 1,
		utcOffset: 1,
		type: 1,
		geo: 1,
		location: 1,
		galleryImg: 1,
		ruletka: 1,
		Votes: 1,
		orgs: 1,
		orientation: 1,
		mood: 1,
		sex: 1,
		description: 1,
		interes: 1,
		birthday: 1,
		mobile: 1,
		restdate: 1,
		where: 1,
		homecity: 1,
		active: 1
	};

	if (RocketChat.authz.hasPermission(userId, 'view-full-other-user-info')) {
		fields = _.extend(fields, {
			emails: 1,
			phone: 1,
			statusConnection: 1,
			createdAt: 1,
			lastLogin: 1,
			services: 1,
			requirePasswordChange: 1,
			requirePasswordChangeReason: 1,
			roles: 1,
			geo: 1,
			location: 1,
			galleryImg: 1,
			mood: 1,
			Votes: 1,
			orgs: 1,
			orientation: 1,
			sex: 1,
			description: 1,
			interes: 1,
			birthday: 1,
			mobile: 1,
			restdate: 1,
			where: 1,
			homecity: 1
		});
	} else if (limit !== 0) {
		limit = 1;
	}

	filter = s.trim(filter);

	if (!filter && limit === 1) {
		return undefined;
	}

	const options = {
		fields: fields,
		limit: limit,
		sort: { username: 1 }
	};

	if (filter) {
		if (limit === 1) {
			return RocketChat.models.Users.findByUsername(filter, options);
		} else {
			const filterReg = new RegExp(s.escapeRegExp(filter), 'i');
			return RocketChat.models.Users.findByUsernameNameOrEmailAddress(filterReg, options);
		}
	}

	return RocketChat.models.Users.find({}, options);
};
