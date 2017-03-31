import toastr from 'toastr'
import moment from 'moment'

Template.orgItem.onCreated ->
  instance = @
  @ready = new ReactiveVar true
  @applications = new ReactiveVar
  @autorun =>
    subscription = instance.subscribe 'orgById', FlowRouter.getParam('org')
    instance.ready.set subscription.ready()
    Session.set "current-org", FlowRouter.getParam('org')

    application = Orgs.findOne(FlowRouter.getParam('org'))

    @applications.set application


Template.orgItem.helpers

  data: ->
    return Orgs.findOne(FlowRouter.getParam('org'))

  date: (created) ->
    return moment(created).format(RocketChat.settings.get('Message_DateFormat'));

  me: ->
    return Meteor.user().username

  width: (username) ->
    application = Template.instance().applications.get()
    if Meteor.user()?.username isnt application.creator
      return parseInt(application.galleryImg.length) * 202
    if application.galleryImg
      return (parseInt(application.galleryImg.length) + 1) * 202

  isReady: ->
    return Template.instance().ready.get()

  catalogTitle: ->
    params = Template.instance().data.params?()
    if params.catalogurl
      catalog = Catalogs.findOne({ url: params.catalogurl })
    else catalog = Catalogs.findOne({ url: FlowRouter.getParam('catalogurl') })
    return catalog.name

  gallery: ->
    g = Orgs.findOne(FlowRouter.getParam('org'))
    return g.galleryImg

  feeds: ->
    arr = applications.get()
    return arr.feeds

  hasChat: ->
    q = Orgs.findOne(FlowRouter.getParam('org'))
    if q.channel
      return true

  notManager: ->
    q = Orgs.findOne(FlowRouter.getParam('org'))
    if q.creator != Meteor.userId()
      return true



Template.orgItem.events
  'click .iconback': () ->
    FlowRouter.go 'org-list', {catalogurl: FlowRouter.getParam('catalogurl')}

  'click .chat': ->
    g = Orgs.findOne(FlowRouter.getParam('org'))
    FlowRouter.go '/channel/' + g.url

  'click .mng': ->
    g = Orgs.findOne(FlowRouter.getParam('org'))
    FlowRouter.go '/direct/' + g.creatorname

  'click .like-user': (e, instance) ->
    e.stopPropagation()
    e.preventDefault()
    Meteor.call 'likeOrgs', e.currentTarget.value, (error, result) ->
      if error
        handleError(error)

  'click .feed': (e, tpl) ->
    text = """
					<div class='upload-preview-title'>
						<input id='org-description' style='display: inherit;' value='' placeholder='#{t("Upload_file_description")}'>
					</div>
				"""
    swal {
      title: t('Оставить отзыв')
      text: text
      showCancelButton: true
      closeOnConfirm: false
      closeOnCancel: false
      html: true
    }, (isConfirm) ->
      if isConfirm
        msg = document.getElementById('org-description').value
        id = Session.get("current-org")
        Meteor.call "addOrgFeed", msg.trim(), id, (err, res) ->
          if err
            console.log err
        swal.close()
      else
        swal.close()



