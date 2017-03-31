
import toastr from 'toastr'

Template.sideNav.helpers
	flexTemplate: ->
		return SideNav.getFlex().template

	flexData: ->
		return SideNav.getFlex().data

	footer: ->
		return RocketChat.settings.get 'Layout_Sidenav_Footer'

	showStarredRooms: ->
		favoritesEnabled = RocketChat.settings.get 'Favorite_Rooms'
		hasFavoriteRoomOpened = ChatSubscription.findOne({ f: true, open: true })

		return true if favoritesEnabled and hasFavoriteRoomOpened

	roomType: ->
		return RocketChat.roomTypes.getTypes()

	canShowRoomType: ->
		userPref = Meteor.user()?.settings?.preferences?.mergeChannels
		globalPref = RocketChat.settings.get('UI_Merge_Channels_Groups')
		mergeChannels = if userPref? then userPref else globalPref
		if mergeChannels
			return RocketChat.roomTypes.checkCondition(@) and @template isnt 'privateGroups'
		else
			return RocketChat.roomTypes.checkCondition(@)

	templateName: ->
		userPref = Meteor.user()?.settings?.preferences?.mergeChannels
		globalPref = RocketChat.settings.get('UI_Merge_Channels_Groups')
		mergeChannels = if userPref? then userPref else globalPref
		if mergeChannels
			return if @template is 'channels' then 'combined' else @template
		else
			return @template

	citys: ->
		return Citys.find()

	city: ->
#		return Session.get "current-city"
		return Meteor.user().city

	ruletka: ->
		return Session.get "ruletka-state"


Template.sideNav.events
	'change #city': (event) ->
		data = {}
		data.city = event.currentTarget.value
		Session.set 'current-city', data.city
		Meteor.call 'saveUserProfile', data, {}, (error, results) ->

		Meteor.call 'joinRoomByCity', data.city, (err) ->
			if err?
				toastr.error t(err.reason)

	'click .close-left-menu': (e) ->
		menu.close()

	'click .close-flex': ->
		SideNav.closeFlex ->
			instance.clearForm()

	'click .arrow': ->
		SideNav.toggleCurrent()

	'mouseenter .header': ->
		SideNav.overArrow()

	'mouseleave .header': ->
		SideNav.leaveArrow()

	'scroll .rooms-list': ->
		menu.updateUnreadBars()

	'dropped .side-nav': (e) ->
		e.preventDefault()

	'click .ruletka': (e, template) ->
		Session.set "ruletka-state", false
		Meteor.call 'triggerRuletka', (err,res) ->

		if template.ruletkaUser.get()
			text = """
				<div style='width: 50px; height: 50px;'>
					<div class='avatar'>
						<div class='avatar-image' style='background-image:url(/avatar/{user.username}?_dc=0);'></div>
					</div>
				</div>
			"""
			swal {
				title: template.ruletkaUser.get().username
				text: text
				type: 'success'
				showCancelButton: true
				confirmButtonColor: '#DD6B55'
				confirmButtonText: t('Conversation_Start')
				cancelButtonText: t('Close')
				closeOnConfirm: false
				html: true
			}, (isConfirm) ->
				if isConfirm
					RocketChat.Notifications.notifyUser(template.ruletkaUser.get()._id, 'myevent', { userId: Meteor.userId() })
					FlowRouter.go '/direct/' + template.ruletkaUser.get().username
					swal.close()
				else
					swal.close()

		# Через 20 сек меняем статус поиска собеседника
		Meteor.setTimeout ->
			Session.set "ruletka-state", true
			Meteor.call 'triggerRuletka', (err,res) ->
			swal
				title: t('There_is_no_one_to_chat_with_now')
				type: 'error'
				timer: 3000
			return
		, 20000



#		if user._id not Meteor.userId()


Template.sideNav.onCreated ->
	@ruletkaUser = new ReactiveVar

	@autorun =>
		@ruletkaUser.set Meteor.users.findOne({_id: {$ne: Meteor.userId()}, ruletka: true})


Template.sideNav.onRendered ->
	SideNav.init()
	menu.init()

	Meteor.defer ->
		menu.updateUnreadBars()

	Session.set "current-city", Meteor.user().city
	Session.set "ruletka-state", true
