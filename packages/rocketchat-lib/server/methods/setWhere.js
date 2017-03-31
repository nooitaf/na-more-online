Meteor.methods({
	setWhere(where) {

		check(where, String);

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setWhere' });
		}

		const user = Meteor.user();

		if (user.where === where) {
			return where;
		}

		if (_.trim(where)) {
			where = _.trim(where);
		}

		if (!RocketChat.models.Users.setWhere(Meteor.userId(), where)) {
			throw new Meteor.Error('error-could-not-change-where', 'Could not change where', { method: 'setWhere' });
		}

		return where;
	}
});
