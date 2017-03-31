Meteor.methods({
	getUsersMood(username) {
		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'getUsersMood' });
		}

		check(username, String);

		user = Meteor.users.findOne({ username : username });

		if (user.mood) return user.mood;
		else return '';

	}
});
