RocketChat.models.OAuthApps = new class extends RocketChat.models._Base
	constructor: ->
		super('oauth_apps')

RocketChat.models.Citys = new class extends RocketChat.models._Base
	constructor: ->
		super('citys')


RocketChat.models.Catalogs = new class extends RocketChat.models._Base
	constructor: ->
		super('catalogs')


	# update img
	setCatalogImg: (catalogId, fileId, fileName) ->
		query =
			_id: catalogId

		update =
			$set:
				img:
					id: fileId
					name: fileName

		return @update query, update

	# CREATE


RocketChat.models.Orgs = new class extends RocketChat.models._Base
	constructor: ->
		super('orgs')

		@tryEnsureIndex { 'url': 1 }
		@tryEnsureIndex { 'city': 1 }
		@tryEnsureIndex { 'category': 1 }

#		this.cache.ensureIndex(['name','ulr'], 'unique')
		this.cache.options = {fields: {usernames: 0}}


	likeOrgbyId: (_id, voter) ->
		update =
			$addToSet:
				votes : voter

		return @update _id, update


	# update img
	setOrgImg: (orgId, fileId, fileName) ->
		query =
			_id: orgId

		update =
			$set:
				img:
					id: fileId
					name: fileName

		return @update query, update

	# CREATE
	# update img
	setOrgGallery: (orgId, fileId, fileName) ->
		query =
			_id: orgId

		update =
			$addToSet:
				gallery: {id: fileId, name: fileName}

		return @update query, update

	setGalleryImg: (orgId, img) ->
		query =
			_id: orgId

		update =
			$addToSet:
				galleryImg : img

		return @update query, update


	findByNameContaining: (name, options) ->
		nameRegex = new RegExp s.trim(s.escapeRegExp(name)), "i"

		query =
			$or:
				name: nameRegex


		return @find query, options



	removeGalleryImg: (imgId, orgId) ->
		console.log imgId + ' - ' + orgId
		query =
			_id: orgId

		update =
			$pull:
				gallery:
					id: imgId

		return @update query, update


