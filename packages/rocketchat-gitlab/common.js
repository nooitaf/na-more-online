/* global CustomOAuth */
const config = {
	serverURL: 'https://gitlab.com',
	identityPath: '/api/v3/user',
	scope: 'api',
	addAutopublishFields: {
		forLoggedInUser: ['services.gitlab'],
		forOtherUsers: ['services.gitlab.username']
	}
};

const configvk = {
	serverURL: 'https://oauth.vk.com',
	authorizePath: 'https://oauth.vk.com/authorize',
	identityPath: 'https://api.vk.com/method/users.get',
	tokenPath: 'https://oauth.vk.com/access_token',
	scope: 'email',
	clientid: '5896022',
	secret: 'n0axcviQ1qJ84JzAk0oD',
	redirectUrl: '_oauth/vk',
	addAutopublishFields: {
		forLoggedInUser: ['services.vk'],
        forOtherUsers: [
            'services.vk.id',
            'services.vk.nickname',
            'services.vk.gender'
        ]
	}
};

const Gitlab = new CustomOAuth('gitlab', config);

const Vk = new CustomOAuth('vk', configvk);


if (Meteor.isServer) {
	Meteor.startup(function() {
		RocketChat.settings.get('API_Gitlab_URL', function(key, value) {
			config.serverURL = value;
			Gitlab.configure(config);
		});
	});
} else {
	Meteor.startup(function() {
		Tracker.autorun(function() {
			if (RocketChat.settings.get('API_Gitlab_URL')) {
				config.serverURL = RocketChat.settings.get('API_Gitlab_URL');
				Gitlab.configure(config);
			}
		});
	});
}

if (Meteor.isServer) {
	Meteor.startup(function() {

			Vk.configure(configvk);

	});
} else {
	Meteor.startup(function() {
		Tracker.autorun(function() {

			Vk.configure(configvk);

		});
	});
}
