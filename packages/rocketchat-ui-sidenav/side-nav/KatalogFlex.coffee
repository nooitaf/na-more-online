
Template.KatalogFlex.helpers
	selectedUsers: ->
		return Template.instance().selectedUsers.get()

	name: ->
		return Template.instance().selectedUserNames[this.valueOf()]

	error: ->
		return Template.instance().error.get()

	roomName: ->
		return Template.instance().roomName.get()

	example: ->
		return 'example 7'


	organizations: ->
		data = Catalogs.find()
		return data
#		return [{title:"Еда", list:[ { subtitle:"Eat"}, {subtitle: "Kafe"}, {subtitle: "Рестораны" }, {subtitle: "Веган кафе" }, {subtitle: "Морская кухня" }, {subtitle: "Фаст фуд" }, {subtitle: "Суши" }, {subtitle: "Пицца" } ] }, {title:"Отдых и развлечения", list:[ { subtitle:"Активный отдых"}, {subtitle: "Бильярд" }, {subtitle: "Боулинг" }, {subtitle: "Для детей" }, {subtitle: "Экскурсии" }, {subtitle: "Кинотеатры" }, {subtitle: "Ночные клубы" }, {subtitle: "Пляжи" }, {subtitle: "Массаж" }, {subtitle: "Сауны/бани" } ] }, {title:"Искуство и творчество"}, {title:"Финансы"}, {title:"Магазины"}, {title:"Услуги"}, {title:"Проживание"}, {title:"Авто"}]


Template.KatalogFlex.events

#
#	'click header': (e, instance) ->
#		SideNav.closeFlex ->
#			instance.clearForm()
#
#	'mouseenter header': ->
#		SideNav.overArrow()
#
#	'mouseleave header': ->
#		SideNav.leaveArrow()

#	'autocompleteselect #channel-members': (event, instance, doc) ->
#		instance.selectedUsers.set instance.selectedUsers.get().concat doc.username
#
#		instance.selectedUserNames[doc.username] = doc.name
#
#		event.currentTarget.value = ''
#		event.currentTarget.focus()

Template.KatalogFlex.onCreated ->
	@subscribe 'catalogs'
	instance = this
	instance.selectedUsers = new ReactiveVar []
	instance.selectedUserNames = {}
	instance.error = new ReactiveVar []
	instance.roomName = new ReactiveVar ''



Template.subKatalogFlex.onCreated ->
	this.openSubKatalog = new ReactiveVar false

Template.subKatalogFlex.events
	'click .btn-katalog': (event, template) ->
		template.openSubKatalog.set !template.openSubKatalog.get()
		console.log(template)

Template.subKatalogFlex.helpers
	openSubKatalogFlag: ->
		return Template.instance().openSubKatalog.get()

	title: ->
		return Template.instance().data.title

	list: ->
		return Template.instance().data.suborganizations




Template.subKatalog.events
	'click a': (event, template) ->
		console.log(template)
		FlowRouter.go 'catalog'

Template.subKatalog.helpers

	subtitle: ->
		return Template.instance().data.subtitle
		console.log(Template.instance())

