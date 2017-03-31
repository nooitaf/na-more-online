RocketChat.AdminBox.addOption
	href: 'admin-oauth-apps'
	i18nLabel: 'OAuth Apps'
	permissionGranted: ->
		return RocketChat.authz.hasAllPermission('manage-oauth-apps')

RocketChat.AdminBox.addOption
	href: 'admin-catalogs'
	i18nLabel: 'Catalog'
	permissionGranted: ->
		return RocketChat.authz.hasAllPermission('manage-oauth-apps')

RocketChat.AdminBox.addOption
	href: 'admin-orgs'
	i18nLabel: 'Orgs'
	permissionGranted: ->
		return RocketChat.authz.hasAllPermission('manage-oauth-apps')

RocketChat.AdminBox.addOption
	href: 'adminCitys'
	i18nLabel: 'Citys_list'
	permissionGranted: ->
		return RocketChat.authz.hasAllPermission('manage-oauth-apps')
