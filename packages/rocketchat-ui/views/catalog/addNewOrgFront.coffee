import toastr from 'toastr'
import moment from 'moment'

Template.addNewOrgFront.onCreated ->
#  @subscribe 'orgs'
#  @subscribe 'catalogs'
#  @record = new ReactiveVar
#    active: true
  self = this
  self.upload = new ReactiveVar
  self.uploadgallery = new ReactiveVar []

Template.addNewOrgFront.helpers
  hasPermission: ->
    return RocketChat.authz.hasAllPermission 'create-p'

  categorys: ->
    data = Catalogs.find({ parent: {$ne: "0"} })
    return data

  upload: ->
    return Template.instance().upload.get()

  uploadgallery: ->
    return Template.instance().uploadgallery.get()

  savingorg: ->
    if Session.get() 'saving_org'
      return true


Template.addNewOrgFront.events
  "click .cancel": (event) ->
    FlowRouter.go FlowRouter.current().oldRoute.name

  "click .submit > .save": (event, template) ->
    Session.set 'saving_org', true

    name = $('[name=name]').val().trim()
    adress = $('[name=adress]').val().trim()
    website = $('[name=website]').val().trim()
    description = $('[name=description]').val().trim()
    phone = $('[name=phone]').val().trim()
    category = $('[name=category]').val().trim()

    if name is ''
      return toastr.error TAPi18n.__("The_org_name_is_required")

    if adress is ''
      return toastr.error TAPi18n.__("The_org_adress_is_required")

    app =
      name: name
      category: category
      adress: adress
      website: website
      phone: phone
      description: description

    if template.upload.get()
      app.mainImg = template.upload.get().blob
    if template.uploadgallery.get()
      app.galleryImg = template.uploadgallery.get()

    Meteor.call "addOrgFront", app, (err, data) ->
      if err?
        Session.set 'saving_org', false
        return handleError(err)
      toastr.success TAPi18n.__("Org_added")
      Session.set 'saving_org', false
      FlowRouter.go "catalog-list"

  'change #img-upload': (event, template) ->
    e = event.originalEvent or event
    files = e.target.files

    filesToUpload = []
    for file in files
      filesToUpload.push
        file: file
        name: file.name
      reader = new FileReader()
      reader.readAsDataURL(file)
      reader.onloadend = ->
        template.upload.set
          blob: reader.result


  'change #gal-upload': (event, template) ->
    e = event.originalEvent or event
    files = e.target.files

    filesToUpload = []
    for file in files
      filesToUpload.push
        file: file
        name: file

      reader = new FileReader()
      reader.readAsDataURL(file)
      reader.onloadend = ->
        arr = template.uploadgallery.get()
        arr.push(reader.result)
        template.uploadgallery.set arr
        console.log arr
        console.log template.uploadgallery.get()



  'click .del-img': (event, template) ->
    arr = []
    if template.uploadgallery.get()
      key = event.currentTarget.id
      arr = template.uploadgallery.get()
      arr.splice(key,1)
      template.uploadgallery.set arr
