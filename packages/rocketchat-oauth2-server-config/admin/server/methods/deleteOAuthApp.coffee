Meteor.methods
	deleteOAuthApp: (applicationId) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error('error-not-allowed', 'Not allowed', { method: 'deleteOAuthApp' });

		application = RocketChat.models.OAuthApps.findOne(applicationId)

		if not application?
			throw new Meteor.Error('error-application-not-found', 'Application not found', { method: 'deleteOAuthApp' });


		RocketChat.models.OAuthApps.remove _id: applicationId

		return true

Meteor.methods
	deleteCatalog: (applicationId) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error('error-not-allowed', 'Not allowed', { method: 'deleteCatalog' });

		application = RocketChat.models.Catalogs.findOne(applicationId)

		if not application?
			throw new Meteor.Error('error-application-not-found', 'Application not found', { method: 'deleteCatalog' });


		RocketChat.models.Catalogs.remove _id: applicationId

		return true

Meteor.methods
	deleteOrg: (applicationId) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error('error-not-allowed', 'Not allowed', { method: 'deleteOrg' });

		application = RocketChat.models.Orgs.findOne(applicationId)

		if not application?
			throw new Meteor.Error('error-application-not-found', 'Application not found', { method: 'deleteOrg' });


		RocketChat.models.Orgs.remove _id: applicationId

		return true
