Meteor.methods({
	setHomeCity(homecity) {

		check(homecity, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setHomeCity' });
		}

		const user = Meteor.user();

		if (user.homecity === homecity) {
			return homecity;
		}

		if (_.trim(homecity)) {
			homecity = _.trim(homecity);
		}

		if (!RocketChat.models.Users.setHomeCity(Meteor.userId(), homecity)) {
			throw new Meteor.Error('error-could-not-change-homecity', 'Could not change homecity', { method: 'setHomeCity' });
		}

		return homecity;
	}
});
