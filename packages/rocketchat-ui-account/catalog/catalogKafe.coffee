import toastr from 'toastr'
import moment from 'moment'

Template.catalogKafe.helpers

Template.catalogKafe.onCreated ->
	settingsTemplate = this.parentTemplate(3)
	settingsTemplate.child ?= []
	settingsTemplate.child.push this

Template.catalogKafe.onRendered ->
	Tracker.afterFlush ->
		# this should throw an error-template
#		FlowRouter.go("home") if !RocketChat.settings.get("Accounts_AllowUserProfileChange")
		SideNav.setFlex "KatalogFlex"
		SideNav.openFlex()

Template.catalogKafe.events
