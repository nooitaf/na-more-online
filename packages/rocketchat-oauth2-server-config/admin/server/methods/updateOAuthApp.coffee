Meteor.methods
	updateOAuthApp: (applicationId, application) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'updateOAuthApp' }

		if not _.isString(application.name) or application.name.trim() is ''
			throw new Meteor.Error 'error-invalid-name', 'Invalid name', { method: 'updateOAuthApp' }

		if not _.isString(application.redirectUri) or application.redirectUri.trim() is ''
			throw new Meteor.Error 'error-invalid-redirectUri', 'Invalid redirectUri', { method: 'updateOAuthApp' }

		if not _.isBoolean(application.active)
			throw new Meteor.Error 'error-invalid-arguments', 'Invalid arguments', { method: 'updateOAuthApp' }

		currentApplication = RocketChat.models.OAuthApps.findOne(applicationId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'updateOAuthApp' }

		RocketChat.models.OAuthApps.update applicationId,
			$set:
				name: application.name
				active: application.active
				redirectUri: application.redirectUri
				_updatedAt: new Date
				_updatedBy: RocketChat.models.Users.findOne @userId, {fields: {username: 1}}

		return RocketChat.models.OAuthApps.findOne(applicationId)


Meteor.methods
	updateCatalog: (applicationId, application) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'updateCatalog' }

		if not _.isString(application.name) or application.name.trim() is ''
			throw new Meteor.Error 'error-invalid-name', 'Invalid name', { method: 'updateCatalog' }

		if not _.isBoolean(application.active)
			throw new Meteor.Error 'error-invalid-arguments', 'Invalid arguments', { method: 'updateCatalog' }

		currentApplication = RocketChat.models.Catalogs.findOne(applicationId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'updateCatalog' }

		anotherCategory = RocketChat.models.Catalogs.findOne({ url: currentApplication.url })
		if currentApplication._id != anotherCategory._id
			throw new Meteor.Error 'error-duble-category-name', 'Категория с таким именем уже существует', { method: 'updateCatalog' }

		RocketChat.models.Catalogs.update applicationId,
			$set:
				name: application.name
				active: application.active
				url: application.url
				parent: application.parent


		return RocketChat.models.Catalogs.findOne(applicationId)


#import { translit } from 'translit'

Meteor.methods
	updateOrg: (applicationId, application) ->

		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'updateOrg' }

		if not _.isString(application.name) or application.name.trim() is ''
			throw new Meteor.Error 'error-invalid-name', 'Invalid name', { method: 'updateOrg' }

		if not _.isBoolean(application.active)
			throw new Meteor.Error 'error-invalid-arguments', 'Invalid arguments', { method: 'updateOrg' }

		currentApplication = RocketChat.models.Orgs.findOne(applicationId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'updateOrg' }


		anotherOrg = RocketChat.models.Orgs.findOne({ url: currentApplication.url })
		if currentApplication._id != anotherOrg._id
			throw new Meteor.Error 'error-duble-org-name', 'Организация с таким именем уже существует', { method: 'updateOrg' }

#   Проверяем изменение адреса, если было изменение, определяем новый город, если новый зависываем его в список городов

		if currentApplication.adress != application.adress
			geo = new GeoCoder(
				geocoderProvider: 'yandex'
				httpAdapter: 'https'
				lang: 'ru_RU')

			geodata = geo.geocode(application.adress)
			city = translit geodata[0].city
			curgeo = geodata[0]
			data = {}
			data.name = city
			data.runame = geodata[0].city
			Meteor.call "addCityList", data, (err,res) ->

		else
			city = currentApplication.city
			curgeo = currentApplication.geo


		RocketChat.models.Orgs.update applicationId,
			$set:
				name: application.name
				active: application.active
				url: translit application.name
				city: city
				category: application.category
				adress: application.adress
				phone: application.phone
				description: application.description
				website: application.website
				galleryImg: application.galleryImg
				mainImg: application.mainImg
				geo: curgeo
				location: {"type": "Point",	"coordinates": [curgeo.longitude, curgeo.latitude] }



		return RocketChat.models.Orgs.findOne(applicationId)



Meteor.methods
	addOrgChat: (applicationId, chatId) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'addOrgChat' }

		currentApplication = RocketChat.models.Orgs.findOne(applicationId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'addOrgChat' }

		currentApplicationChar = RocketChat.models.Orgs.findOne(applicationId)
		if not currentApplication.channel?
			RocketChat.models.Orgs.update applicationId,
				$set:
					channel: chatId
		else
			throw new Meteor.Error 'ошибка изменения чата организации', 'Чат организации уже существует', { method: 'addOrgChat' }


Meteor.methods
	addOrgFeed: (msg, orgId) ->

		check(msg, String)

		if not Meteor.userId()
			throw new Meteor.Error 'user-not-found', 'User not found', { method: 'addOrgFeed' }

		currentApplication = RocketChat.models.Orgs.findOne(orgId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'addOrgFeed' }

		RocketChat.models.Orgs.update orgId,
			$push:
				feeds: {username: Meteor.user().username, message: msg, createdAt: new Date}


Meteor.methods
	deleteGaleryOrgImg: (key, orgId) ->
		if not RocketChat.authz.hasPermission @userId, 'create-p'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'deleteGaleryOrgImg' }

		currentApplication = RocketChat.models.Orgs.findOne(orgId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'deleteGaleryOrgImg' }

		org = RocketChat.models.Orgs.findOne(orgId)
		gallery = org.galleryImg.splice(key,1)

		RocketChat.models.Orgs.update orgId,
			$set:
				galleryImg: gallery




Meteor.methods
	mainImgUpdate: (img, orgId) ->
		if not RocketChat.authz.hasPermission @userId, 'create-p'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'mainImgUpdate' }

		currentApplication = RocketChat.models.Orgs.findOne(orgId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'mainImgUpdate' }


		RocketChat.models.Orgs.update orgId,
			$set:
				mainImg: img

		return true

Meteor.methods
	galleryImgUpdate: (img, orgId) ->
		if not RocketChat.authz.hasPermission @userId, 'create-p'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'galleryImgUpdate' }

		currentApplication = RocketChat.models.Orgs.findOne(orgId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'galleryImgUpdate' }


		RocketChat.models.Orgs.setGalleryImg(orgId, img)

		return true



Meteor.methods
	updateCity: (applicationId, application) ->
		if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'updateCity' }

		if not _.isBoolean(application.active)
			throw new Meteor.Error 'error-invalid-arguments', 'Invalid arguments', { method: 'updateCity' }

		currentApplication = RocketChat.models.Citys.findOne(applicationId)
		if not currentApplication?
			throw new Meteor.Error 'error-application-not-found', 'Application not found', { method: 'updateCity' }


		RocketChat.models.Citys.update applicationId,
			$set:
				active: application.active


		return RocketChat.models.Citys.findOne(applicationId)

