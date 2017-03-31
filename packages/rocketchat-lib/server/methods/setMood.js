Meteor.methods({
	setMood(mood) {

		check(mood, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setMood' });
		}

		const user = Meteor.user();

		if (user.mood === mood) {
			return mood;
		}

		if (_.trim(mood)) {
			mood = _.trim(mood);
		}

		if (!RocketChat.models.Users.setMood(Meteor.userId(), mood)) {
			throw new Meteor.Error('error-could-not-change-mood', 'Could not change mood', { method: 'setMood' });
		}

		return mood;
	}
});
