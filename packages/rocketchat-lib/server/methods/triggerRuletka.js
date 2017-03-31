

Meteor.methods({
	triggerRuletka() {

		if (!Meteor.userId()) {
			throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'triggerRuletka' });
		}
		if (!Meteor.user().ruletka) {
		ruletka = false }

		state = Meteor.user().ruletka;

		if (state == false) RocketChat.models.Users.triggerRuletka(Meteor.userId(), true);
		if (state == true) RocketChat.models.Users.triggerRuletka(Meteor.userId(), false);

		return true;

	}
});
