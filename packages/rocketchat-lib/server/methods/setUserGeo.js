Meteor.methods({
    setUserGeo(position) {

        check(position, Object);

        if (!Meteor.userId()) {
            throw new Meteor.Error('error-invalid-user', 'Invalid user', { method: 'setUserGeo' });
        }

        RocketChat.models.Users.setUserGeo(Meteor.userId(), position);

        location = {
            "type": "Point",
            "coordinates": [position.longitude, position.latitude]
        };


        RocketChat.models.Users.setLocation(Meteor.userId(), location);

        return true;
    }
});
