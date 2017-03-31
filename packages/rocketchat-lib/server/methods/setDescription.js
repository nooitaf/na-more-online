Meteor.methods({
	setDescription(description) {

		check(description, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setDescription' });
		}

		const user = Meteor.user();

		if (user.description === description) {
			return description;
		}

		if (_.trim(description)) {
			description = _.trim(description);
		}

		if (!RocketChat.models.Users.setDescription(Meteor.userId(), description)) {
			throw new Meteor.Error('error-could-not-change-description', 'Could not change description', { method: 'setDescription' });
		}

		return description;
	}
});
