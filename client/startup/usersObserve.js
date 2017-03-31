Meteor.startup(function() {
	Meteor.users.find({}, { fields: { name: 1, username: 1, mood: 1, status: 1, emails: 1, phone: 1, services: 1, utcOffset: 1 } }).observe({
		added(user) {
			Session.set('user_' + user.username + '_status', user.status);
			Session.set('user_' + user.username + '_mood', user.mood);
			//Session.set('user_' + user.username + '_mood', user.mood);
			RoomManager.updateUserStatus(user, user.status, user.utcOffset);
			//RoomManager.updateUserMood(user, user.mood);
		},
		changed(user) {
			Session.set('user_' + user.username + '_status', user.status);
			//Session.set('user_' + user.username + '_mood', user.mood);
			Session.set('user_' + user.username + '_mood', user.mood);
			RoomManager.updateUserStatus(user, user.status, user.utcOffset);
			//RoomManager.updateUserMood(user, user.mood);
		},
		removed(user) {
			Session.set('user_' + user.username + '_status', null);
			Session.set('user_' + user.username + '_mood', null);
			//Session.set('user_' + user.username + '_mood', null);
			RoomManager.updateUserStatus(user, 'offline', null);
			//RoomManager.updateUserMood(user, user.mood);
		}
	});
});