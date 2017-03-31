Meteor.publish('activeUsers', function() {
	if (!this.userId) {
		return this.ready();
	}

	return RocketChat.models.Users.findUsersNotOffline({
		fields: {
			username: 1,
			status: 1,
			mood: 1,
			city: 1,
			location: 1,
			ruletka: 1,
			utcOffset: 1
		}
	});
});
