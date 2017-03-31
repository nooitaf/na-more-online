Meteor.methods({
	setCity(city) {

		check(city, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setCity' });
		}

		const user = Meteor.user();

		if (user.city === city) {
			return city;
		}

		if (_.trim(city)) {
			city = _.trim(city);
		}

		if (!RocketChat.models.Users.setCity(Meteor.userId(), city)) {
			throw new Meteor.Error('error-could-not-change-city', 'Could not change city', { method: 'setCity' });
		}

		return city;
	}
});
