import toastr from 'toastr'
import moment from 'moment'

Template.accountProfile.helpers
	allowDeleteOwnAccount: ->
		return RocketChat.settings.get('Accounts_AllowDeleteOwnAccount')

	realname: ->
		return Meteor.user().name

	username: ->
		return Meteor.user().username

	email: ->
		return Meteor.user().emails?[0]?.address

	emailVerified: ->
		return  Meteor.user().emails?[0]?.verified

	allowUsernameChange: ->
		return RocketChat.settings.get("Accounts_AllowUsernameChange") and RocketChat.settings.get("LDAP_Enable") isnt true

	allowEmailChange: ->
		return RocketChat.settings.get("Accounts_AllowEmailChange")

	usernameChangeDisabled: ->
		return t('Username_Change_Disabled')

	allowPasswordChange: ->
		return RocketChat.settings.get("Accounts_AllowPasswordChange")

	passwordChangeDisabled: ->
		return t('Password_Change_Disabled')

	orientation: ->
		return Meteor.user().orientation

	description: ->
		return Meteor.user().description

	mood: ->
		return Meteor.user().mood

	homecity: ->
		return Meteor.user().homecity

	interes: ->
		return Meteor.user().interes

	sex: ->
		return Meteor.user().sex

	where: ->
		return Meteor.user().where

	mobile: ->
		return Meteor.user().mobile

	birthday: ->
		ret = moment(Meteor.user().birthday).format('YYYY-MM-DD')
		return ret

	restdate: ->
		ret = moment(Meteor.user().restdate).format('YYYY-MM-DD')
		return ret

	customFields: ->
		return Meteor.user().customFields

	Orn_Custom_Fields_Orientation_Getero: ->
		if Meteor.user().orientation == "Custom_Fields_Orientation_Getero"
			return true

	Orn_Custom_Fields_Orientation_Bi: ->
		if Meteor.user().orientation == "Custom_Fields_Orientation_Bi"
			return true

	Orn_Custom_Fields_Orientation_Lesbi: ->
		if Meteor.user().orientation == "Custom_Fields_Orientation_Lesbi"
			return true

	Orn_Custom_Fields_Orientation_Gey: ->
		if Meteor.user().orientation == "Custom_Fields_Orientation_Gey"
			return true

	Orn_Custom_Fields_Orientation_Trans: ->
		if Meteor.user().orientation == "Custom_Fields_Orientation_Trans"
			return true

	Op_Sex_Female: ->
		if Meteor.user().sex == "Female"
			return true

	Op_Sex_Male: ->
		if Meteor.user().sex == "Male"
			return true


Template.accountProfile.onCreated ->
	settingsTemplate = this.parentTemplate(3)
	settingsTemplate.child ?= []
	settingsTemplate.child.push this

	@clearForm = ->
		@find('#password').value = ''

	@changePassword = (newPassword, callback) ->
		instance = @
		if not newPassword
			return callback()

		else
			if !RocketChat.settings.get("Accounts_AllowPasswordChange")
				toastr.remove();
				toastr.error t('Password_Change_Disabled')
				instance.clearForm()
				return

	@save = (currentPassword) ->
		instance = @

		data = { currentPassword: currentPassword }

		if _.trim($('#password').val()) and RocketChat.settings.get("Accounts_AllowPasswordChange")
			data.newPassword = $('#password').val()

		if _.trim $('#realname').val()
			data.realname = _.trim $('#realname').val()

		if _.trim $('#orientation').val()
			data.orientation = _.trim $('#orientation').val()

		if _.trim $('#homecity').val()
			data.homecity = _.trim $('#homecity').val()

		if _.trim $('#description').val()
			data.description = _.trim $('#description').val()

		if _.trim $('#mood').val()
			data.mood = _.trim $('#mood').val()

		if _.trim $('#interes').val()
			data.interes = _.trim $('#interes').val()

		if _.trim $('#sex').val()
			data.sex = _.trim $('#sex').val()

		if _.trim $('#birthday').val()
			data.birthday = new Date($('#birthday').val())

		if _.trim $('#restdate').val()
			data.restdate =  new Date($('#restdate').val())

		if _.trim $('#mobile').val()
			data.mobile = _.trim $('#mobile').val()

		if _.trim $('#where').val()
			data.where = _.trim $('#where').val()

		if _.trim($('#username').val()) isnt Meteor.user().username
			if !RocketChat.settings.get("Accounts_AllowUsernameChange")
				toastr.remove();
				toastr.error t('Username_Change_Disabled')
				instance.clearForm()
				return
			else
				data.username = _.trim $('#username').val()

		if _.trim($('#email').val()) isnt Meteor.user().emails?[0]?.address
			if !RocketChat.settings.get("Accounts_AllowEmailChange")
				toastr.remove();
				toastr.error t('Email_Change_Disabled')
				instance.clearForm()
				return
			else
				data.email = _.trim $('#email').val()

		customFields = {}
		$('[data-customfield=true]').each () ->
			customFields[this.name] = $(this).val() or ''

		Meteor.call 'saveUserProfile', data, customFields, (error, results) ->
			if results
				toastr.remove();
				toastr.success t('Profile_saved_successfully')
				swal.close()
				instance.clearForm()

			if error
				toastr.remove();
				handleError(error)

Template.accountProfile.onRendered ->
	Tracker.afterFlush ->
		# this should throw an error-template
		FlowRouter.go("home") if !RocketChat.settings.get("Accounts_AllowUserProfileChange")
		SideNav.setFlex "accountFlex"
		SideNav.openFlex()

Template.accountProfile.events
	'click .submit button': (e, instance) ->
		user = Meteor.user()
		reqPass = ((_.trim($('#email').val()) isnt user?.emails?[0]?.address) or _.trim($('#password').val())) and s.trim(user?.services?.password?.bcrypt)
		unless reqPass
			return instance.save()

		swal
			title: t("Please_enter_your_password"),
			text: t("For_your_security_you_must_enter_your_current_password_to_continue"),
			type: "input",
			inputType: "password",
			showCancelButton: true,
			closeOnConfirm: false

		, (typedPassword) =>
			if typedPassword
				toastr.remove();
				toastr.warning(t("Please_wait_while_your_profile_is_being_saved"));
				instance.save(SHA256(typedPassword))
			else
				swal.showInputError(t("You_need_to_type_in_your_password_in_order_to_do_this"));
				return false;
	'click .logoutOthers button': (event, templateInstance) ->
		Meteor.logoutOtherClients (error) ->
			if error
				toastr.remove();
				handleError(error)
			else
				toastr.remove();
				toastr.success t('Logged_out_of_other_clients_successfully')
	'click .delete-account button': (e) ->
		e.preventDefault();
		if s.trim Meteor.user()?.services?.password?.bcrypt
			swal
				title: t("Are_you_sure_you_want_to_delete_your_account"),
				text: t("If_you_are_sure_type_in_your_password"),
				type: "input",
				inputType: "password",
				showCancelButton: true,
				closeOnConfirm: false

			, (typedPassword) =>
				if typedPassword
					toastr.remove();
					toastr.warning(t("Please_wait_while_your_account_is_being_deleted"));
					Meteor.call 'deleteUserOwnAccount', SHA256(typedPassword), (error, results) ->
						if error
							toastr.remove();
							swal.showInputError(t("Your_password_is_wrong"));
						else
							swal.close();
				else
					swal.showInputError(t("You_need_to_type_in_your_password_in_order_to_do_this"));
					return false;
		else
			swal
				title: t("Are_you_sure_you_want_to_delete_your_account"),
				text: t("If_you_are_sure_type_in_your_username"),
				type: "input",
				showCancelButton: true,
				closeOnConfirm: false

			, (deleteConfirmation) =>
				if deleteConfirmation is Meteor.user()?.username
					toastr.remove();
					toastr.warning(t("Please_wait_while_your_account_is_being_deleted"));
					Meteor.call 'deleteUserOwnAccount', deleteConfirmation, (error, results) ->
						if error
							toastr.remove();
							swal.showInputError(t("Your_password_is_wrong"));
						else
							swal.close();
				else
					swal.showInputError(t("You_need_to_type_in_your_username_in_order_to_do_this"));
					return false;

	'click #resend-verification-email': (e) ->
		e.preventDefault()

		e.currentTarget.innerHTML = e.currentTarget.innerHTML + ' ...'
		e.currentTarget.disabled = true

		Meteor.call 'sendConfirmationEmail', Meteor.user().emails?[0]?.address, (error, results) =>
			if results
				toastr.success t('Verification_email_sent')
			else if error
				handleError(error)

			e.currentTarget.innerHTML = e.currentTarget.innerHTML.replace(' ...', '')
			e.currentTarget.disabled = false
