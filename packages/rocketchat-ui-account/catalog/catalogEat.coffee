import toastr from 'toastr'
import moment from 'moment'

Template.catalogEat.helpers
	title: ->
		return FlowRouter.getParam('group')

Template.catalogEat.onCreated ->
	settingsTemplate = this.parentTemplate(3)
	settingsTemplate.child ?= []
	settingsTemplate.child.push this

Template.catalogEat.onRendered ->
	Tracker.afterFlush ->
		# this should throw an error-template
#		FlowRouter.go("home") if !RocketChat.settings.get("Accounts_AllowUserProfileChange")
		SideNav.setFlex "KatalogFlex"
		SideNav.openFlex()

Template.catalogEat.events
