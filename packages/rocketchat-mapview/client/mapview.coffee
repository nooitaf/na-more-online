###
# MapView is a named function that will replace geolocation in messages with a Google Static Map
# @param {Object} message - The message object
###

class MapView
	constructor: (message) ->

		# get MapView settings
		mv_googlekey = RocketChat.settings.get 'MapView_GMapsAPIKey'

		if message.location

			# GeoJSON is reversed - ie. [lng, lat]
			longitude = message.location.coordinates[0]
			latitude = message.location.coordinates[1]
			m = message.msg

			# confirm we have an api key set, and generate the html required for the mapview
			if mv_googlekey?.length
				message.html  = '<a href="https://maps.google.com/maps?daddr='+latitude+','+longitude+'" target="_blank"><img src="https://maps.googleapis.com/maps/api/staticmap?zoom=14&language=ru&size=250x250&markers=color:gray%7Clabel:%7C'+latitude+','+longitude+'&key='+mv_googlekey+'" /></a><figcaption class="attachment-description">' + m + '</figcaption>'
			else
				message.html  = '<a href="https://maps.google.com/maps?daddr='+latitude+','+longitude+'" target="_blank">'+TAPi18n.__('Shared_Location')+'</a>'

		return message

RocketChat.callbacks.add 'renderMessage', MapView, RocketChat.callbacks.priority.HIGH
