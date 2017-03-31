Meteor.methods({
	setInteres(interes) {

		check(interes, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setInteres' });
		}

		const user = Meteor.user();

		if (user.interes === interes) {
			return interes;
		}

		if (_.trim(interes)) {
			interes = _.trim(interes);
		}

		if (!RocketChat.models.Users.setInteres(Meteor.userId(), interes)) {
			throw new Meteor.Error('error-could-not-change-interes', 'Could not change interes', { method: 'setInteres' });
		}

		return interes;
	}
});
