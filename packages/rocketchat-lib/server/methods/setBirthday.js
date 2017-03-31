Meteor.methods({
	setBirthday(birthday) {

		check(birthday, Date);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setBirthday' });
		}

		const user = Meteor.user();

		if (user.birthday === birthday) {
			return birthday;
		}

		if (_.trim(birthday)) {
			birthday = _.trim(birthday);
		}

		if (!RocketChat.models.Users.setBirthday(Meteor.userId(), birthday)) {
			throw new Meteor.Error('error-could-not-change-birthday', 'Could not change birthday', { method: 'setBirthday' });
		}

		return birthday;
	}
});
