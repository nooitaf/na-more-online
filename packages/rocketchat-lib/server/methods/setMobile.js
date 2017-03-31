Meteor.methods({
	setMobile(mobile) {

		check(mobile, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setMobile' });
		}

		const user = Meteor.user();

		if (user.mobile === mobile) {
			return mobile;
		}

		if (_.trim(mobile)) {
			mobile = _.trim(mobile);
		}

		if (!RocketChat.models.Users.setMobile(Meteor.userId(), mobile)) {
			throw new Meteor.Error('error-could-not-change-mobile', 'Could not change mobile', { method: 'setMobile' });
		}

		return mobile;
	}
});
