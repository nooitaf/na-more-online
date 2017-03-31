Meteor.methods({
	setOrientation(orientation) {

		check(orientation, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setOrientation' });
		}

		const user = Meteor.user();

		if (user.orientation === orientation) {
			return orientation;
		}

		if (_.trim(orientation)) {
			orientation = _.trim(orientation);
		}

		if (!RocketChat.models.Users.setOrientation(Meteor.userId(), orientation)) {
			throw new Meteor.Error('error-could-not-change-orientation', 'Could not change orientation', { method: 'setOrientation' });
		}

		return orientation;
	}
});
