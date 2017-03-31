Meteor.methods({
	createChannel(name, members, readOnly = false, customFields = {}) {
		check(name, String);
		check(members, Match.Optional([String]));

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'createChannel' });
		}

		if (!RocketChat.authz.hasPermission(Meteor.userId(), 'create-c')) {
			throw new Meteor.Error('error-not-allowed', 'Not allowed', { method: 'createChannel' });
		}

		if (customFields.org && customFields.creator) {
			return RocketChat.createRoom('c', name, customFields.creatorname, members, readOnly, {customFields});
		}
		else return RocketChat.createRoom('c', name, Meteor.user() && Meteor.user().username, members, readOnly, {customFields});
	}
});

Meteor.methods({
	createCityChannel(name, members, readOnly = false, customFields = {}) {
		check(name, String);
		check(members, Match.Optional([String]));

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'createCityChannel' });
		}

		if (!RocketChat.authz.hasPermission(Meteor.userId(), 'create-c')) {
			throw new Meteor.Error('error-not-allowed', 'Not allowed', { method: 'createCityChannel' });
		}

		if (customFields.org && customFields.creator) {
			return RocketChat.createRoom('c', name, customFields.creatorname, members, readOnly, {customFields});
		}
		else return RocketChat.createRoom('c', name, Meteor.user() && Meteor.user().username, members, readOnly, {customFields});
	}
});
