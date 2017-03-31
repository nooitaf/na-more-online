Meteor.methods({
	saveUserProfile(settings, customFields) {
		check(settings, Object);

		if (!RocketChat.settings.get('Accounts_AllowUserProfileChange')) {
			throw new Meteor.Error('error-not-allowed', 'Not allowed', {
				method: 'saveUserProfile'
			});
		}

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', {
				method: 'saveUserProfile'
			});
		}

		const user = RocketChat.models.Users.findOneById(Meteor.userId());

		function checkPassword(user = {}, currentPassword) {
			if (user.services && user.services.password && user.services.password.bcrypt && user.services.password.bcrypt.trim()) {
				return true;
			}

			if (!currentPassword) {
				return false;
			}

			const passCheck = Accounts._checkPassword(user, {
				digest: currentPassword,
				algorithm: 'sha-256'
			});

			if (passCheck.error) {
				return false;
			}

			return true;
		}

		if ((settings.newPassword) && RocketChat.settings.get('Accounts_AllowPasswordChange') === true) {
			if (!checkPassword(user, settings.currentPassword)) {
				throw new Meteor.Error('error-invalid-password', 'Invalid password', {
					method: 'saveUserProfile'
				});
			}

			Accounts.setPassword(Meteor.userId(), settings.newPassword, {
				logout: false
			});
		}

		if (settings.realname) {
			Meteor.call('setRealName', settings.realname);
		}

		if (settings.orientation) {
			Meteor.call('setOrientation', settings.orientation);
		}

		if (settings.description) {
			Meteor.call('setDescription', settings.description);
		}

		if (settings.mood) {
			Meteor.call('setMood', settings.mood);
		}

		if (settings.interes) {
			Meteor.call('setInteres', settings.interes);
		}

		if (settings.birthday) {
			Meteor.call('setBirthday', settings.birthday);
		}

		if (settings.sex) {
			Meteor.call('setSex', settings.sex);
		}

		if (settings.homecity) {
			Meteor.call('setHomeCity', settings.homecity);
		}

		if (settings.restdate) {
			Meteor.call('setRestDate', settings.restdate);
		}

		if (settings.mobile) {
			Meteor.call('setMobile', settings.mobile);
		}

		if (settings.where) {
			Meteor.call('setWhere', settings.where);
		}

		if (settings.username) {
			Meteor.call('setUsername', settings.username);
		}

		if (settings.city) {
			Meteor.call('setCity', settings.city);
		}

		if (settings.email) {
			if (!checkPassword(user, settings.currentPassword)) {
				throw new Meteor.Error('error-invalid-password', 'Invalid password', {
					method: 'saveUserProfile'
				});
			}

			Meteor.call('setEmail', settings.email);
		}

		RocketChat.models.Users.setProfile(Meteor.userId(), {});

		RocketChat.saveCustomFields(Meteor.userId(), customFields);

		return true;
	}
});
