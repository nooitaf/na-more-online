FlowRouter.route '/admin/oauth-apps',
	name: 'admin-oauth-apps'
	action: (params) ->
		BlazeLayout.render 'main',
			center: 'pageSettingsContainer'
			pageTitle: t('OAuth_Applications')
			pageTemplate: 'oauthApps'


FlowRouter.route '/admin/oauth-app/:id?',
	name: 'admin-oauth-app'
	action: (params) ->
		BlazeLayout.render 'main',
			center: 'oauthApp'
			pageTitle: t('OAuth_Application')
			pageTemplate: 'oauthApp'
			params: params

FlowRouter.route '/admin/catalogs',
	name: 'admin-catalogs'
	action: (params) ->
		BlazeLayout.render 'main',
			center: 'pageSettingsContainer'
			pageTitle: t('Catalogs_Manager')
			pageTemplate: 'adminCatalogs'


FlowRouter.route '/admin/catalog/:id?',
	name: 'admin-catalog'
	action: (params) ->
		BlazeLayout.render 'main',
			center: 'adminCatalog'
			pageTitle: t('Catalog_Editor')
			pageTemplate: 'adminCatalog'
			params: params

FlowRouter.route '/admin/orgs',
	name: 'admin-orgs'
	action: (params) ->
		BlazeLayout.render 'main',
			center: 'adminOrgs'
			pageTitle: t('Orgs_Manager')
			pageTemplate: 'adminOrgs'


FlowRouter.route '/admin/org/:id?',
	name: 'admin-org'
	subscriptions: (params) ->
		this.register 'orgById', Meteor.subscribe('orgById', params.id)

	action: (params) ->
		BlazeLayout.render 'main',
			center: 'adminOrg'
			pageTitle: t('Org_Editor')
			pageTemplate: 'adminOrg'
			params: params

FlowRouter.route '/nearby',
	name: 'nearby'
	subscriptions: (params) ->
		this.register 'orgById', Meteor.subscribe('orgById', params.id)

	action: (params) ->
		BlazeLayout.render 'main',
			center: 'nearby'
			pageTitle: t('Nearby')
#			pageTemplate: 'adminOrg'
#			params: params



FlowRouter.route '/admin/citys',
	name: 'adminCitys'
	action: (params) ->
		BlazeLayout.render 'main',
			center: 'adminCitys'
			pageTitle: t('Citys_list')
			pageTemplate: 'adminCitys'


FlowRouter.route '/admin/citys/:id?',
	name: 'adminCity'
	action: (params) ->
		BlazeLayout.render 'main',
			center: 'adminCity'
			pageTitle: t('Org_Editor')
			pageTemplate: 'adminCity'
			params: params