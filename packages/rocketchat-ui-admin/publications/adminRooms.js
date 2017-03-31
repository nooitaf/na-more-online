Meteor.publish('adminRooms', function(filter, types, limit) {
	var options;
	if (!this.userId) {
		return this.ready();
	}
	if (RocketChat.authz.hasPermission(this.userId, 'view-room-administration') !== true) {
		return this.ready();
	}
	if (!_.isArray(types)) {
		types = [];
	}
	options = {
		fields: {
			name: 1,
			t: 1,
			cl: 1,
			u: 1,
			customFields: 1,
			usernames: 1,
			muted: 1,
			ro: 1,
			default: 1,
			topic: 1,
			img: 1,
			msgs: 1,
			archived: 1
		},
		limit: limit,
		sort: {
			default: -1,
			name: 1
		}
	};
	filter = _.trim(filter);
	if (filter && types.length) {
		// CACHE: can we stop using publications here?
		return RocketChat.models.Rooms.findByNameContainingAndTypes(filter, types, options);
	} else if (types.length) {
		// CACHE: can we stop using publications here?
		return RocketChat.models.Rooms.findByTypes(types, options);
	} else {
		// CACHE: can we stop using publications here?
		return RocketChat.models.Rooms.findByNameContaining(filter, options);
	}
});


Meteor.publish('usersSearch', function(filter, types, query, limit) {
	var options;
	if (!this.userId) {
		return this.ready();
	}

	if (!_.isArray(types)) {
		types = [];
	}
	options = {
		fields: {
			name: 1,
			username: 1,
			sex: 1,
			homecity: 1,
			city: 1,
			location: 1
		},
		limit: limit
	};
	return RocketChat.models.Users.find(query, options);
	//
	//filter = _.trim(filter);
	//if (filter && types.length) {
	//	// CACHE: can we stop using publications here?
	//	return RocketChat.models.Users.findBySexAndName(filter, types, options);
	//} else if (types.length) {
	//	// CACHE: can we stop using publications here?
	//	return RocketChat.models.Users.findBySex(types, options);
	//} else {
	//	// CACHE: can we stop using publications here?
	//	return RocketChat.models.Users.findActiveByUsernameOrNameRegexWithExceptions(filter, {}, options);
	//}
});
