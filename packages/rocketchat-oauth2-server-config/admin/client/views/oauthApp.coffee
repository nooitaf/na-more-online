import toastr from 'toastr'
import moment from 'moment'

Template.oauthApp.onCreated ->
	@subscribe 'oauthApps'
	@record = new ReactiveVar
		active: true


Template.oauthApp.helpers
	hasPermission: ->
		return RocketChat.authz.hasAllPermission 'manage-oauth-apps'

	data: ->
		params = Template.instance().data.params?()

		if params?.id?
			data = ChatOAuthApps.findOne({_id: params.id})
			if data?
				data.authorization_url = Meteor.absoluteUrl("oauth/authorize")
				data.access_token_url = Meteor.absoluteUrl("oauth/token")

				Template.instance().record.set data
				return data

		return Template.instance().record.curValue


Template.oauthApp.events
	"click .submit > .delete": ->
		params = Template.instance().data.params()

		swal
			title: t('Are_you_sure')
			text: t('You_will_not_be_able_to_recover')
			type: 'warning'
			showCancelButton: true
			confirmButtonColor: '#DD6B55'
			confirmButtonText: t('Yes_delete_it')
			cancelButtonText: t('Cancel')
			closeOnConfirm: false
			html: false
		, ->
			Meteor.call "deleteOAuthApp", params.id, (err, data) ->
				swal
					title: t('Deleted')
					text: t('Your_entry_has_been_deleted')
					type: 'success'
					timer: 1000
					showConfirmButton: false

				FlowRouter.go "admin-oauth-apps"

	"click .submit > .save": ->
		name = $('[name=name]').val().trim()
		active = $('[name=active]:checked').val().trim() is "1"
		redirectUri = $('[name=redirectUri]').val().trim()

		if name is ''
			return toastr.error TAPi18n.__("The_application_name_is_required")

		if redirectUri is ''
			return toastr.error TAPi18n.__("The_redirectUri_is_required")

		app =
			name: name
			active: active
			redirectUri: redirectUri

		params = Template.instance().data.params?()
		if params?.id?
			Meteor.call "updateOAuthApp", params.id, app, (err, data) ->
				if err?
					return handleError(err)

				toastr.success TAPi18n.__("Application_updated")
		else
			Meteor.call "addOAuthApp", app, (err, data) ->
				if err?
					return handleError(err)

				toastr.success TAPi18n.__("Application_added")
				FlowRouter.go "admin-oauth-app", {id: data._id}

#d==========================================================  CATEGORY  ==========================================================
Template.adminCatalog.onCreated ->
	@subscribe 'catalogs'
	@record = new ReactiveVar
		active: true


Template.adminCatalog.helpers
	hasPermission: ->
		return RocketChat.authz.hasAllPermission 'manage-oauth-apps'

	data: ->
		params = Template.instance().data.params?()

		if params?.id?
			data = Catalogs.findOne({_id: params.id})
			Template.instance().record.set data
			return data

		return Template.instance().record.curValue


	categorys: ->
		data = Catalogs.find({ active: true, parent: "0" })
		return data

	currentCategory: ->
		params = Template.instance().data.params?()
		data = Catalogs.findOne({_id: params.id})
		if (data.parent == '0')
			return false
		if (data._id == params.id)
			return true


Template.adminCatalog.events
	"click .submit > .delete": ->
		params = Template.instance().data.params()

		swal
			title: t('Are_you_sure')
			text: t('You_will_not_be_able_to_recover')
			type: 'warning'
			showCancelButton: true
			confirmButtonColor: '#DD6B55'
			confirmButtonText: t('Yes_delete_it')
			cancelButtonText: t('Cancel')
			closeOnConfirm: false
			html: false
		, ->
			Meteor.call "deleteCatalog", params.id, (err, data) ->
				swal
					title: t('Deleted')
					text: t('Your_entry_has_been_deleted')
					type: 'success'
					timer: 1000
					showConfirmButton: false

				FlowRouter.go "adminCatalogs"

	"click .submit > .save": (event) ->
		name = $('[name=name]').val().trim()
		active = $('[name=active]:checked').val().trim() is "1"
		url = translit(name)
		parent = $('[name=parent]').val().trim()


		if name is ''
			return toastr.error TAPi18n.__("The_application_name_is_required")

		app =
			name: name
			active: active
			url: url
			parent: parent

		params = Template.instance().data.params?()
		if params?.id?
			Meteor.call "updateCatalog", params.id, app, (err, data) ->
				if err?
					return handleError(err)

				toastr.success TAPi18n.__("Catalog_updated")
		else
			Meteor.call "addCatalog", app, (err, data) ->
				if err?
					return handleError(err)

				toastr.success TAPi18n.__("Catalog_added")
				FlowRouter.go "admin-catalogs", {id: data._id}


	'change #upload': (event) ->
		e = event.originalEvent or event
		files = e.target.files
		filesToUpload = []
		for file in files
			filesToUpload.push
				file: file
			name: file.name
		params = Template.instance().data.params()
		imgCatalogUpload filesToUpload, params.id


#d======================================================= ORGS =============================================================
Template.adminOrg.onCreated ->

#	@subscribe 'orgById', Template.instance().data.params?().id?
	@subscribe 'catalogs'


	@upload = new ReactiveVar
	@uploadgallery = new ReactiveVar []
	@record = new ReactiveVar
		active: true

	@autorun =>
		params = Template.instance().data.params?()
		if params?.id?
			data1 = Orgs.findOne(params.id)
			@record.set data1


Template.adminOrg.helpers
	hasPermission: ->
		return RocketChat.authz.hasAllPermission 'manage-oauth-apps'

	data: ->
		params = Template.instance().data.params?()
		if params?.id?
			data = Orgs.findOne({_id: params.id})
			Template.instance().record.set data
			return data

		return Template.instance().record.curValue

	categorys: ->
		data = Catalogs.find({ parent: {$ne: "0"} })
		return data

	currentCategory: (id) ->
		category = Template.instance().record.curValue
		if(id == category.category)
			return true
		else return false


Template.adminOrg.events
	"click .submit > .delete": ->
		params = Template.instance().data.params()

		swal
			title: t('Are_you_sure')
			text: t('You_will_not_be_able_to_recover')
			type: 'warning'
			showCancelButton: true
			confirmButtonColor: '#DD6B55'
			confirmButtonText: t('Yes_delete_it')
			cancelButtonText: t('Cancel')
			closeOnConfirm: false
			html: false
		, ->
			Meteor.call "deleteOrg", params.id, (err, data) ->
				swal
					title: t('Deleted')
					text: t('Your_entry_has_been_deleted')
					type: 'success'
					timer: 1000
					showConfirmButton: false

				FlowRouter.go "adminOrgs"

	"click .submit > .save": (event, template) ->
		name = $('[name=name]').val().trim()
		active = $('[name=active]:checked').val().trim() is "1"
		adress = $('[name=adress]').val().trim()
		website = $('[name=website]').val().trim()
		description = $('[name=description]').val().trim()
		phone = $('[name=phone]').val().trim()
		category = $('[name=category]').val().trim()

		if name is ''
			return toastr.error TAPi18n.__("The_org_name_is_required")

		app =
			name: name
			active: active
			category: category
			adress: adress
			website: website
			phone: phone
			description: description

		params = Template.instance().data.params?()
		if params?.id?
			if template.record.curValue.mainImg
				app.mainImg = template.record.curValue.mainImg
			if template.record.curValue.galleryImg
				app.galleryImg = template.record.curValue.galleryImg
			Meteor.call "updateOrg", params.id, app, (err, data) ->
				if err?
					return handleError(err)
				toastr.success TAPi18n.__("Org_updated")
		else
			if template.record.curValue.mainImg
				app.mainImg = template.record.curValue.mainImg
			if template.record.curValue.galleryImg
				app.galleryImg = template.record.curValue.galleryImg
			Meteor.call "addOrgFront", app, (err, data) ->
				if err?
					return handleError(err)
				toastr.success TAPi18n.__("Org_added")
				FlowRouter.go "admin-orgs", {id: data._id}



	'change #img-upload': (event, template) ->
		e = event.originalEvent or event
		files = e.target.files
		filesToUpload = []
		for file in files
			filesToUpload.push
				file: file
				name: file.name

			reader = new FileReader()
			reader.readAsDataURL(file)
			reader.onloadend = ->
				params = template.data.params?()
				if params?.id?
					Meteor.call 'mainImgUpdate', reader.result, params.id, (err, res) ->
						if err
							console.log err
				else
					template.record.set
						mainImg: reader.result



	'change #gal-upload': (event, template) ->
		e = event.originalEvent or event
		files = e.target.files
		filesToUpload = []
		for file in files
			filesToUpload.push
				file: file
				name: file
			reader = new FileReader()
			reader.readAsDataURL(file)
			reader.onloadend = ->
				params = template.data.params?()
				if params?.id?
					Meteor.call 'galleryImgUpdate', reader.result, params.id, (err, res) ->
						if err
							console.log err
				else
					arr = []
					if template.record.curValue.galleryImg
						arr = template.record.curValue.galleryImg
					arr.push(reader.result)
					template.record.set
						galleryImg: arr



	'click .del-img': (event, template) ->
		params = template.data.params?()
		if params?.id?
			key = event.currentTarget.id
			Meteor.call 'deleteGaleryOrgImg', key, params.id, (err, res) ->
				if err
					console.log err
		else
			arr = []
			if template.record.curValue.galleryImg
				key = event.currentTarget.id
				arr = template.record.curValue.galleryImg
				arr.splice(key,1)
				template.record.set
					galleryImg: arr



	'click .createchat': ->
		name = $('[name=name]').val().trim()
		params = Template.instance().data.params?()
		org = Orgs.findOne({_id: params.id})
		if !org.channel
			members = []

			Meteor.call 'createChannel', translit(name), members, false, { org: org._id, creator: org.creator, creatorname: org.creatorname, title: org.name }, (err, result) ->
				if err
					console.log err
					if err.error is 'error-invalid-name'
						instance.error.set({ invalid: true })
						return
					if err.error is 'error-duplicate-channel-name'
						instance.error.set({ duplicate: true })
						return
					if err.error is 'error-archived-duplicate-name'
						instance.error.set({ archivedduplicate: true })
						return
				if result

					Meteor.call "addOrgChat", org._id, result, (err, res) ->
						if err?
							return handleError(err)
						if res
							toastr.success TAPi18n.__("Org_chat_Added")
		else
			toastr.error "У компании уже есть чат"


#d==========================================================  CATEGORY  ==========================================================
Template.adminCity.onCreated ->
	@subscribe 'admincitys'
	@record = new ReactiveVar
		active: true


Template.adminCity.helpers
	hasPermission: ->
		return RocketChat.authz.hasAllPermission 'manage-oauth-apps'

	data: ->
		params = Template.instance().data.params?()

		if params?.id?
			data = Citys.findOne({_id: params.id})
			Template.instance().record.set data
			return data

		return Template.instance().record.curValue



Template.adminCity.events
#	"click .submit > .delete": ->
#		params = Template.instance().data.params()
#
#		swal
#			title: t('Are_you_sure')
#			text: t('You_will_not_be_able_to_recover')
#			type: 'warning'
#			showCancelButton: true
#			confirmButtonColor: '#DD6B55'
#			confirmButtonText: t('Yes_delete_it')
#			cancelButtonText: t('Cancel')
#			closeOnConfirm: false
#			html: false
#		, ->
#			Meteor.call "deleteCatalog", params.id, (err, data) ->
#				swal
#					title: t('Deleted')
#					text: t('Your_entry_has_been_deleted')
#					type: 'success'
#					timer: 1000
#					showConfirmButton: false
#
#				FlowRouter.go "adminCatalogs"

	"click .submit > .save": (event) ->
		active = $('[name=active]:checked').val().trim() is "1"

		app =
			active: active

		params = Template.instance().data.params?()
		if params?.id?
			Meteor.call "updateCity", params.id, app, (err, data) ->
				if err?
					return handleError(err)

				toastr.success TAPi18n.__("City_updated")
		else
			Meteor.call "addCity", app, (err, data) ->
				if err?
					return handleError(err)

				toastr.success TAPi18n.__("City_added")
				FlowRouter.go "admin-catalogs", {id: data._id}

