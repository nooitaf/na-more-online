Meteor.methods({
	setSex(sex) {

		check(sex, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setSex' });
		}

		const user = Meteor.user();

		if (user.sex === sex) {
			return sex;
		}

		if (_.trim(sex)) {
			sex = _.trim(sex);
		}

		if (!RocketChat.models.Users.setSex(Meteor.userId(), sex)) {
			throw new Meteor.Error('error-could-not-change-sex', 'Could not change sex', { method: 'setSex' });
		}

		return sex;
	}
});
