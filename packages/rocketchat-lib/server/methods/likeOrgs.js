Meteor.methods({
    likeOrgs(_id) {

        check(_id, String);


        if (!Meteor.userId()) {
            throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'likeOrgs' });
        }

        //Зависываем +1 к организации от пользователя
        RocketChat.models.Orgs.likeOrgbyId(_id, Meteor.user().username);

        //Зависываем +1 к пользователю об организации
        RocketChat.models.Users.addlikeOrg(Meteor.userId(), _id);

        return true;

    }
});
