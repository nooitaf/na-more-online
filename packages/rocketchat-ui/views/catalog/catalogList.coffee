import toastr from 'toastr'
import moment from 'moment'


Template.catalogList.onCreated ->
	@subscribe 'orgsMin'

Template.catalogList.helpers


Template.catalogListMain.onCreated ->
#	Template.instance().subscribe 'catalogs'

Template.catalogListMain.helpers
	catalogRootItem: ->
		query = { active: true, parent: "0" }
		data = Catalogs.find query
		return data



Template.subCatalog.onCreated ->

	this.openSubKatalog = new ReactiveVar Session.get Template.instance().data.edata._id
#	Template.instance().subscribe 'catalogs'
#	@subscribe 'catalogs'

Template.subCatalog.events
	'click .btn-katalog': (event, template) ->
		template.openSubKatalog.set !template.openSubKatalog.get()
		Session.set Template.instance().data.edata._id, template.openSubKatalog.get()

Template.subCatalog.helpers
	openSubKatalogFlag: ->
		return Session.get Template.instance().data.edata._id

	title: ->
		return Template.instance().data.title

	data: ->
		return Template.instance().data.edata

	list: ->
		parent = Template.instance().data.id
		query = { active: true, parent: parent }
		data = Catalogs.find query
		return data


Template.subCatalogItem.onCreated ->

Template.subCatalogItem.helpers


	subdata: ->
		return Template.instance().data.subdata

	count: ->
		categoty = Template.instance().data.subdata
		city = Session.get "current-city"
		count = Orgs.find({ category: categoty.url, city: city}).fetch()
		return count.length

