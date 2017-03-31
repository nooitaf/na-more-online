
Template.orgList.onCreated ->
  instance = @
  @limit = new ReactiveVar 2
  @ready = new ReactiveVar true

  @autorun =>
    limit = instance.limit.get()
    subscription = instance.subscribe 'orgsByCityAndCategory', Meteor.user().city, FlowRouter.getParam('catalogurl'), limit
    instance.ready.set subscription.ready()

  @orgListItem = ->
    query =
      city: Meteor.user().city
      category: FlowRouter.getParam('catalogurl')


    return Orgs.find(query, { limit: Template.instance().limit?.get() })




Template.orgList.helpers
  orgListItem: ->
    return Template.instance().orgListItem()


  catalogurl: ->
    return FlowRouter.getParam('catalogurl')

  title: ->
    return Template.instance().catalog.name

  isReady: ->
    return Template.instance().ready.get()

  hasMore: ->
    return Template.instance().limit?.get() is Template.instance().orgListItem?().count()

  isLoading: ->
    return 'btn-loading' unless Template.instance().ready?.get()



Template.orgList.events
  'click .iconback': () ->
    FlowRouter.go 'catalog-list'

  'click .load-more': (e, t) ->
    e.preventDefault()
    e.stopPropagation()
    t.limit.set t.limit.get() + 4

  'click .like-user': (e, instance) ->
    e.stopPropagation()
    e.preventDefault()

    Meteor.call 'likeOrgs', e.currentTarget.value, (error, result) ->
      if error
        handleError(error)
