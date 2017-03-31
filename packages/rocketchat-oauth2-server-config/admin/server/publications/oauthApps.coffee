Meteor.publish 'oauthApps', ->
	unless @userId
		return @ready()

	if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
		@error Meteor.Error "error-not-allowed", "Not allowed", { publish: 'oauthApps' }

	return RocketChat.models.OAuthApps.find()




Meteor.publish 'citys', ->
	unless @userId
		return @ready()

	return RocketChat.models.Citys.find({active: true})



Meteor.publish 'admincitys', ->
	unless @userId
		return @ready()

	return RocketChat.models.Citys.find()




Meteor.publish 'catalogs', ->
	unless @userId
		return @ready()

	return RocketChat.models.Catalogs.find()


Meteor.publish 'catalogsList', ->
	unless @userId
		return @ready()

	return RocketChat.models.Catalogs.find({parent: {$nor: "0"}, active: true})
		fields:
			name: 1
			url: 1


Meteor.publish 'orgs', ->
	unless @userId
		return @ready()

#	if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
#		@error Meteor.Error "error-not-allowed", "Not allowed", { publish: 'catalogs' }

	return RocketChat.models.Orgs.find()


Meteor.publish 'orgsByCityAndCategory', (city, category, limit) ->
	unless @userId
		return @ready()

#	if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
#		@error Meteor.Error "error-not-allowed", "Not allowed", { publish: 'catalogs' }

	if not city
		city = "Yalta"

	query =
		city: city
		category: category
		active: true
#		location:
#			$near:
#				$geometry: Meteor.user().location
#				$maxDistance: 20000

	options =
		fields:
			_id: 1
			name: 1
			adress: 1
			mainImg: 1
			votes: 1
			location: 1
		limit: limit


	return RocketChat.models.Orgs.find(query, options)



Meteor.publish 'orgsByCityAndCategoryMin', (city, category) ->
	unless @userId
		return @ready()

#	if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
#		@error Meteor.Error "error-not-allowed", "Not allowed", { publish: 'catalogs' }

	if not city
		city = "Yalta"

	return RocketChat.models.Orgs.findOne({ city: city, category: category, active: true }, {fields: {_id: 1}})



Meteor.publish 'orgById', (id) ->
	unless @userId
		return @ready()

	return RocketChat.models.Orgs.find({_id: id})



Meteor.publish 'orgsMin', ->
	unless @userId
		return @ready()

	return RocketChat.models.Orgs.find({ active: true }, {fields: {category: 1, city: 1}})



Meteor.publish 'admin-orgs', (filter, limit) ->
	unless @userId
		return @ready()

	if not RocketChat.authz.hasPermission @userId, 'manage-oauth-apps'
		@error Meteor.Error "error-not-allowed", "Not allowed", { publish: 'adminOrgs' }

	options =
		fields:
			name: 1
			active: 1
			city: 1
			category: 1
			url: 1
			creator: 1
		limit: limit
		sort:
			name: 1

#	filter = _.trim(filter)

	if filter
#		// CACHE: can we stop using publications here?
		return RocketChat.models.Orgs.findByNameContainingAndTypes(filter, options)
	else
#	// CACHE: can we stop using publications here?
		return RocketChat.models.Orgs.findByNameContaining(filter, options)