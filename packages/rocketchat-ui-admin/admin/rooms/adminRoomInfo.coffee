import toastr from 'toastr'
Template.adminRoomInfo.helpers

	fileUploadAllowedMediaTypes: ->
		return RocketChat.settings.get('FileUpload_MediaTypeWhiteList')

	selectedRoom: ->
		return Session.get 'adminRoomsSelected'
	canEdit: ->
		return RocketChat.authz.hasAllPermission('edit-room', @rid)
	editing: (field) ->
		return Template.instance().editing.get() is field
	notDirect: ->
		return AdminChatRoom.findOne(@rid, { fields: { t: 1 }})?.t isnt 'd'
	roomType: ->
		return AdminChatRoom.findOne(@rid, { fields: { t: 1 }})?.t
	channelSettings: ->
		return RocketChat.ChannelSettings.getOptions()
	roomTypeDescription: ->
		roomType = AdminChatRoom.findOne(@rid, { fields: { t: 1 }})?.t
		if roomType is 'c'
			return t('Channel')
		else if roomType is 'p'
			return t('Private_Group')
	roomName: ->
		return AdminChatRoom.findOne(@rid, { fields: { name: 1 }})?.name
	roomTopic: ->
		return AdminChatRoom.findOne(@rid, { fields: { topic: 1 }})?.topic
	archivationState: ->
		return AdminChatRoom.findOne(@rid, { fields: { archived: 1 }})?.archived
	archivationStateDescription: ->
		archivationState = AdminChatRoom.findOne(@rid, { fields: { archived: 1 }})?.archived
		if archivationState is true
			return t('Room_archivation_state_true')
		else
			return t('Room_archivation_state_false')
	canDeleteRoom: ->
		roomType = AdminChatRoom.findOne(@rid, { fields: { t: 1 }})?.t
		return roomType? and RocketChat.authz.hasAtLeastOnePermission("delete-#{roomType}")
	readOnly: ->
		room = AdminChatRoom.findOne(@rid, { fields: { ro: 1 }})
		return room?.ro
	readOnlyDescription: ->
		room = AdminChatRoom.findOne(@rid, { fields: { ro: 1 }})
		readOnly = room?.ro
		if readOnly is true
			return t('True')
		else
			return t('False')

Template.adminRoomInfo.events

	'change #upload': (event, template) ->
		e = event.originalEvent or event
		files = e.target.files
		if not files or files.length is 0
			files = e.dataTransfer?.files or []

		filesToUpload = []
		for file in files
			filesToUpload.push
				file: file
				name: file.name

		imgUpload filesToUpload

	'click .delete': ->
		swal {
			title: t('Are_you_sure')
			text: t('Delete_Room_Warning')
			type: 'warning'
			showCancelButton: true
			confirmButtonColor: '#DD6B55'
			confirmButtonText: t('Yes_delete_it')
			cancelButtonText: t('Cancel')
			closeOnConfirm: false
			html: false
		}, =>
			swal.disableButtons()

			Meteor.call 'eraseRoom', @rid, (error, result) ->
				if error
					handleError(error)
					swal.enableButtons()
				else
					swal
						title: t('Deleted')
						text: t('Room_has_been_deleted')
						type: 'success'
						timer: 2000
						showConfirmButton: false

	'keydown input[type=text]': (e, t) ->
		if e.keyCode is 13
			e.preventDefault()
			t.saveSetting(@rid)

	'click [data-edit]': (e, t) ->
		e.preventDefault()
		t.editing.set($(e.currentTarget).data('edit'))
		setTimeout (-> t.$('input.editing').focus().select()), 100

	'click .cancel': (e, t) ->
		e.preventDefault()
		t.editing.set()

	'click .save': (e, t) ->
		e.preventDefault()
		t.saveSetting(@rid)

Template.adminRoomInfo.onCreated ->
	@editing = new ReactiveVar

	@validateRoomType = (rid) =>
		type = @$('input[name=roomType]:checked').val()
		if type not in ['c', 'p']
			toastr.error t('error-invalid-room-type', { type: type })
		return true

	@validateRoomName = (rid) =>
		room = AdminChatRoom.findOne rid

		if not RocketChat.authz.hasAllPermission('edit-room', rid) or room.t not in ['c', 'p']
			toastr.error t('error-not-allowed')
			return false

		name = $('input[name=roomName]').val()

		try
			nameValidation = new RegExp '^' + RocketChat.settings.get('UTF8_Names_Validation') + '$'
		catch
			nameValidation = new RegExp '^[0-9a-zA-Z-_.]+$'

		if not nameValidation.test name
			toastr.error t('error-invalid-room-name', { room_name: name })
			return false

		return true

	@validateRoomTopic = (rid) =>
		return true

	@saveSetting = (rid) =>
		switch @editing.get()
			when 'roomName'
				if @validateRoomName(rid)
					RocketChat.callbacks.run 'roomNameChanged', AdminChatRoom.findOne(rid)
					Meteor.call 'saveRoomSettings', rid, 'roomName', @$('input[name=roomName]').val(), (err, result) ->
						if err
							return handleError(err)
						toastr.success TAPi18n.__ 'Room_name_changed_successfully'
			when 'roomTopic'
				if @validateRoomTopic(rid)
					Meteor.call 'saveRoomSettings', rid, 'roomTopic', @$('input[name=roomTopic]').val(), (err, result) ->
						if err
							return handleError(err)
						toastr.success TAPi18n.__ 'Room_topic_changed_successfully'
						RocketChat.callbacks.run 'roomTopicChanged', AdminChatRoom.findOne(rid)
						console.log(this);
			when 'roomType'
				if @validateRoomType(rid)
					RocketChat.callbacks.run 'roomTypeChanged', AdminChatRoom.findOne(rid)
					Meteor.call 'saveRoomSettings', rid, 'roomType', @$('input[name=roomType]:checked').val(), (err, result) ->
						if err
							return handleError(err)
						toastr.success TAPi18n.__ 'Room_type_changed_successfully'
			when 'archivationState'
				if @$('input[name=archivationState]:checked').val() is 'true'
					if AdminChatRoom.findOne(rid)?.archived isnt true
						Meteor.call 'archiveRoom', rid, (err, results) ->
							return handleError(err) if err
							toastr.success TAPi18n.__ 'Room_archived'
							RocketChat.callbacks.run 'archiveRoom', AdminChatRoom.findOne(rid)
				else
					if AdminChatRoom.findOne(rid)?.archived is true
						Meteor.call 'unarchiveRoom', rid, (err, results) ->
							return handleError(err) if err
							toastr.success TAPi18n.__ 'Room_unarchived'
							RocketChat.callbacks.run 'unarchiveRoom', AdminChatRoom.findOne(rid)
			when 'readOnly'
				Meteor.call 'saveRoomSettings', rid, 'readOnly', @$('input[name=readOnly]:checked').val() is 'true', (err, result) ->
					return handleError err if err
					toastr.success TAPi18n.__ 'Read_only_changed_successfully'
		@editing.set()
