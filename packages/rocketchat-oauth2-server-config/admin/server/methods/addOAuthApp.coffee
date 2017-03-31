Meteor.methods
	addOAuthApp: (application) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'addOAuthApp' }

		if not _.isString(application.name) or application.name.trim() is ''
			throw new Meteor.Error 'error-invalid-name', 'Invalid name', { method: 'addOAuthApp' }

		if not _.isString(application.redirectUri) or application.redirectUri.trim() is ''
			throw new Meteor.Error 'error-invalid-redirectUri', 'Invalid redirectUri', { method: 'addOAuthApp' }

		if not _.isBoolean(application.active)
			throw new Meteor.Error 'error-invalid-arguments', 'Invalid arguments', { method: 'addOAuthApp' }

		application.clientId = Random.id()
		application.clientSecret = Random.secret()
		application._createdAt = new Date
		application._createdBy = RocketChat.models.Users.findOne @userId, {fields: {username: 1}}

		application._id = RocketChat.models.OAuthApps.insert application

		return application


Meteor.methods
	addCityList: (data) ->
		if not RocketChat.authz.hasPermission @userId, 'create-p'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'addOAuthApp' }

		if not _.isString(data.name) or data.name.trim() is ''
			throw new Meteor.Error 'error-invalid-name', 'Invalid name', { method: 'addOAuthApp' }

		anotherCity = RocketChat.models.Citys.findOne({ name: data.name })
		if anotherCity
			throw new Meteor.Error 'Такой город уже есть в системе', 'Город уже есть в системе', { method: 'addOAuthApp' }

		data.active = false

		RocketChat.models.Citys.insert data

		Meteor.call 'createChannel', data.name, {}, false, { title: data.runame }, (err, result) ->






Meteor.methods
	addCatalog: (application) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'addCatalog' }

		if not _.isString(application.name) or application.name.trim() is ''
			throw new Meteor.Error 'error-invalid-name', 'Invalid name', { method: 'addCatalog' }

		if not _.isBoolean(application.active)
			throw new Meteor.Error 'error-invalid-arguments', 'Invalid arguments', { method: 'addCatalog' }


		anotherCategory = RocketChat.models.Catalogs.findOne({ url: application.url })
		if anotherCategory
			throw new Meteor.Error 'error-duble-category-name', 'Категория с таким именем уже существует', { method: 'updateCatalog' }

		application._id = RocketChat.models.Catalogs.insert application

		return application



Meteor.methods
	addOrg: (application) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'addOrg' }

		if not _.isString(application.name) or application.name.trim() is ''
			throw new Meteor.Error 'error-invalid-name', 'Invalid name', { method: 'addOrg' }

		if not _.isBoolean(application.active)
			throw new Meteor.Error 'error-invalid-arguments', 'Invalid arguments', { method: 'addOrg' }

		anotherOrg = RocketChat.models.Orgs.findOne({ url: application.url })
		if anotherOrg
			throw new Meteor.Error 'error-duble-org-name', 'Организация с таким именем уже существует', { method: 'addOrg' }

		geo = new GeoCoder(
			geocoderProvider: 'yandex'
			httpAdapter: 'https'
			lang: 'ru_RU')
		geodata = geo.geocode(application.adress)
		application.city = translit geodata[0].city

		application._id = RocketChat.models.Orgs.insert application

		cityInsert.name = application.city
		cityInsert.runame = geodata[0].city

		Meteor.call 'addCityList', cityInsert, (err,res) ->
			if err
				console.log err

		return application


Meteor.methods
	addOrgFront: (application) ->
		if not RocketChat.authz.hasPermission @userId, 'create-p'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'addOrgFront' }

		if not _.isString(application.name) or application.name.trim() is ''
			throw new Meteor.Error 'error-invalid-name', 'Invalid name', { method: 'addOrgFront' }

		application.url = translit application.name
		application.active = false
		application.creator = @userId
		user = RocketChat.models.Users.findOne(@userId)
		application.creatorname = user.username

		anotherOrg = RocketChat.models.Orgs.findOne({ url: application.url })
		if anotherOrg
			throw new Meteor.Error 'error-duble-org-name', 'Организация с таким именем уже существует', { method: 'addOrgFront' }

		geo = new GeoCoder(
			geocoderProvider: 'yandex'
			httpAdapter: 'https'
			lang: 'ru_RU')

		geodata = geo.geocode(application.adress)

		if not geodata[0].city
			throw new Meteor.Error 'error-invalid-city', 'Город не распознан, проверьте адресс', { method: 'addOrgFront' }

		application.city = translit geodata[0].city
		application.geo = geodata[0]
		application.location =
			"type": "Point",
			"coordinates": [geodata[0].longitude, geodata[0].latitude]

		data = {}
		data.name = application.city
		data.runame = geodata[0].city
		Meteor.call "addCityList", data, (err,res) ->


		application._id = RocketChat.models.Orgs.insert application

		return application


