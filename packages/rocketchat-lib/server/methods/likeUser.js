Meteor.methods({
    likeUser({_id, username}) {

        check(_id, String);
        check(username, String);


        if (!Meteor.userId()) {
            throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'likeUser' });
        }

        if (username != Meteor.user().username) {
            RocketChat.models.Users.addlikeById(_id, Meteor.user().username);
            return true;
        }
    }
});
