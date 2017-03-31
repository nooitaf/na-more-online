FlowRouter.route '/notifications',
  name: 'notifications'

  action: ->
    BlazeLayout.render 'main',
      center: 'notifications'
      pageTitle: t('Notifications')
#			pageTemplate: 'adminOrg'

