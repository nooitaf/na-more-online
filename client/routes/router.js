/* globals KonchatNotification */

Blaze.registerHelper('pathFor', function(path, kw) {
	return FlowRouter.path(path, kw.hash);
});

BlazeLayout.setRoot('body');

FlowRouter.subscriptions = function() {
	Tracker.autorun(() => {
		if (Meteor.userId()) {
			this.register('userData', Meteor.subscribe('userData'));
			this.register('activeUsers', Meteor.subscribe('activeUsers'));
			this.register('catalogs', Meteor.subscribe('catalogs'));
			this.register('citys', Meteor.subscribe('citys'));
			//this.register('orgsByCityAndCategory', Meteor.subscribe('orgsByCityAndCategory', Session.get('current-city'), Session.get('current-category')));
			//this.register('orgsMin');
			//this.register('orgs', Meteor.subscribe('orgsByCity'));
		}
	});
};


FlowRouter.route('/', {
	name: 'index',
	action() {
		BlazeLayout.render('main', { modal: RocketChat.Layout.isEmbedded(), center: 'loading' });
		if (!Meteor.userId()) {
			return FlowRouter.go('home');
		}

		Tracker.autorun(function(c) {
			if (FlowRouter.subsReady() === true) {
				Meteor.defer(function() {
					if (Meteor.user().defaultRoom) {
						const room = Meteor.user().defaultRoom.split('/');
						FlowRouter.go(room[0], { name: room[1] }, FlowRouter.current().queryParams);
					} else {
						FlowRouter.go('home');
					}
				});
				c.stop();
			}
		});
	}
});


FlowRouter.route('/login', {
	name: 'login',

	action() {
		FlowRouter.go('home');
	}
});

FlowRouter.route('/home', {
	name: 'home',

	action(params, queryParams) {
		KonchatNotification.getDesktopPermission();
		if (queryParams.saml_idp_credentialToken !== undefined) {
			Accounts.callLoginMethod({
				methodArguments: [{
					saml: true,
					credentialToken: queryParams.saml_idp_credentialToken
				}],
				userCallback: function() { BlazeLayout.render('main', {center: 'home'}); }
			});
		} else {
			BlazeLayout.render('main', {center: 'home'});
		}
	}
});

FlowRouter.route('/changeavatar', {
	name: 'changeAvatar',

	action() {
		BlazeLayout.render('main', {center: 'avatarPrompt'});
	}
});

FlowRouter.route('/editprofile', {
	name: 'editprofile',

	action() {
		BlazeLayout.render('main', {center: 'accountProfile'});
	}
});

FlowRouter.route('/account/:group?', {
	name: 'account',

	action(params) {
		if (!params.group) {
			params.group = 'Profile';
		}
		params.group = _.capitalize(params.group, true);
		BlazeLayout.render('main', { center: `account${params.group}` });
	}
});


FlowRouter.route('/catalog', {
	name: 'catalog-list',
	action() {
		BlazeLayout.render('main', {center: `catalogList`, pageTemplate: 'catalogListMain' });
	}
});


FlowRouter.route('/catalog/:catalogurl?', {
	name: 'org-list',
	//subscriptions(/*params, queryParams*/) {
	//	this.register('orgs', Meteor.subscribe('orgs', { city: "Yalta"}));
	//},
	action: function(params) {
		if (!params.catalogurl) {
			params.catalogurl = 'eat';
		}
		Session.set('current-category', params.catalogurl);
		BlazeLayout.render('main', {center: `catalogList`, pageTemplate: 'orgList', params: params });
	}
});

FlowRouter.route('/catalog/:catalogurl/:org?', {
	name: 'org-item',
	//subscriptions(/*params, queryParams*/) {
	//	this.register('orgsByCity', Meteor.subscribe('orgs', { city: "Yalta" }));
	//},
	action: function(params) {
		if (!params.catalogurl) {
			params.catalogurl = 'kafe';
		}
		BlazeLayout.render('main', {center: `catalogList`, pageTemplate: 'orgItem', params: params });
	}
});


FlowRouter.route('/add-organization', {
	name: 'add-new-org-front',
	action() {
		BlazeLayout.render('main', {center: 'addNewOrgFront', params: null});
	}
});

FlowRouter.route('/history/private', {
	name: 'privateHistory',

	subscriptions(/*params, queryParams*/) {
		this.register('privateHistory', Meteor.subscribe('privateHistory'));
	},

	action() {
		Session.setDefault('historyFilter', '');
		BlazeLayout.render('main', {center: 'privateHistory'});
	}
});

FlowRouter.route('/terms-of-service', {
	name: 'terms-of-service',

	action() {
		Session.set('cmsPage', 'Layout_Terms_of_Service');
		BlazeLayout.render('cmsPage');
	}
});

FlowRouter.route('/privacy-policy', {
	name: 'privacy-policy',

	action() {
		Session.set('cmsPage', 'Layout_Privacy_Policy');
		BlazeLayout.render('cmsPage');
	}
});

FlowRouter.route('/room-not-found/:type/:name', {
	name: 'room-not-found',

	action(params) {
		Session.set('roomNotFound', {type: params.type, name: params.name});
		BlazeLayout.render('main', {center: 'roomNotFound'});
	}
});

FlowRouter.route('/fxos', {
	name: 'firefox-os-install',

	action() {
		BlazeLayout.render('fxOsInstallPrompt');
	}
});

FlowRouter.route('/register/:hash', {
	name: 'register-secret-url',

	action(/*params*/) {
		BlazeLayout.render('secretURL');

		// if RocketChat.settings.get('Accounts_RegistrationForm') is 'Secret URL'
		// 	Meteor.call 'checkRegistrationSecretURL', params.hash, (err, success) ->
		// 		if success
		// 			Session.set 'loginDefaultState', 'register'
		// 			BlazeLayout.render 'main', {center: 'home'}
		// 			KonchatNotification.getDesktopPermission()
		// 		else
		// 			BlazeLayout.render 'logoLayout', { render: 'invalidSecretURL' }
		// else
		// 	BlazeLayout.render 'logoLayout', { render: 'invalidSecretURL' }
	}
});
