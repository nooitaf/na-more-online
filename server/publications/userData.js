Meteor.publish('userData', function() {
	if (!this.userId) {
		return this.ready();
	}

	return RocketChat.models.Users.find(this.userId, {
		fields: {
			name: 1,
			username: 1,
			status: 1,
			statusDefault: 1,
			statusConnection: 1,
			avatarOrigin: 1,
			utcOffset: 1,
			city: 1,
			language: 1,
			location: 1,
			galleryImg: 1,
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
			mood: 1,
			ruletka: 1,
			homecity: 1,
			geo: 1,
			roles: 1,
			active: 1,
			defaultRoom: 1,
			customFields: 1,
			'services.github': 1,
			'services.gitlab': 1,
			requirePasswordChange: 1,
			requirePasswordChangeReason: 1,
			'services.password.bcrypt': 1,
			statusLivechat: 1
		}
	});
});
