Meteor.methods({
	setRestDate(restdate) {

		check(restdate, Date);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setRestDate' });
		}

		const user = Meteor.user();

		if (user.restdate === restdate) {
			return restdate;
		}

		if (_.trim(restdate)) {
			restdate = _.trim(restdate);
		}

		if (!RocketChat.models.Users.setRestDate(Meteor.userId(), restdate)) {
			throw new Meteor.Error('error-could-not-change-restdate', 'Could not change restdate', { method: 'setRestDate' });
		}

		return restdate;
	}
});
