if (_.isUndefined(RocketChat.models.Users)) {
	RocketChat.models.Users = {};
}

Object.assign(RocketChat.models.Users, {
	isUserInRole(userId, roleName) {
		const query = {
			_id: userId,
			roles: roleName
		};

		return !_.isUndefined(this.findOne(query));
	},

	findUsersInRoles(roles, scope, options) {
		roles = [].concat(roles);

		const query = {
			roles: { $in: roles }
		};

		return this.find(query, options);
	},

	findAndSortByGeo(geo) {
		const query = {
			location: { $near :
				{
					$geometry: geo,
					$maxDistance: 5000
				}
			}
		};
		return this.find(query);
	}

});
