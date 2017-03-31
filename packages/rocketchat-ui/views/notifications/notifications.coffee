import moment from 'moment'
import mime from 'mime-type/with-db'

Template.notifications.helpers
  subscribed: ->
    return isSubscribed(this._id)

  messagesHistory: ->
    hideMessagesOfType = []
    RocketChat.settings.collection.find({_id: /Message_HideType_.+/}).forEach (record) ->
      type = record._id.replace('Message_HideType_', '')
      switch (type)
        when 'mute_unmute'
          types = [ 'user-muted', 'user-unmuted' ]
        else
          types = [ type ]
      types.forEach (type) ->
        index = hideMessagesOfType.indexOf(type)

        if record.value is true and index is -1
          hideMessagesOfType.push(type)
        else if index > -1
          hideMessagesOfType.splice(index, 1)

    query =
      rid: this._id

    if hideMessagesOfType.length > 0
      query.t =
        $nin: hideMessagesOfType

    options =
      sort:
        ts: 1

    return ChatMessage.find(query, options)

  hasMore: ->
    return RoomHistoryManager.hasMore this._id

  hasMoreNext: ->
    return RoomHistoryManager.hasMoreNext this._id

  isLoading: ->
    return RoomHistoryManager.isLoading this._id

  windowId: ->
    return "chat-window-#{this._id}"

  unreadData: ->
    data =
      count: RoomHistoryManager.getRoom(this._id).unreadNotLoaded.get() + Template.instance().unreadCount.get()

    room = RoomManager.getOpenedRoomByRid this._id
    if room?
      data.since = room.unreadSince?.get()

    return data

  containerBarsShow: (unreadData, uploading) ->
    return 'show' if (unreadData?.count > 0 and unreadData.since?) or uploading?.length > 0

  formatUnreadSince: ->
    if not this.since? then return

    return moment(this.since).calendar(null, {sameDay: 'LT'})

  flexData: ->
    flexData =
      tabBar: Template.instance().tabBar
      data:
        rid: '324'

    return flexData

  viewMode: ->
    viewMode = Meteor.user()?.settings?.preferences?.viewMode
    switch viewMode
      when 1 then cssClass = 'cozy'
      when 2 then cssClass = 'compact'
      else cssClass = ''
    return cssClass

  selectable: ->
    return Template.instance().selectable.get()

touchMoved = false

Template.notifications.events
  "click, touchend": (e, t) ->
    Meteor.setTimeout ->
      t.sendToBottomIfNecessaryDebounced()
    , 100

  "click .messages-container": (e) ->
    if Template.instance().tabBar.getState() is 'opened' and Meteor.user()?.settings?.preferences?.hideFlexTab
      Template.instance().tabBar.close()

  "touchstart .message": (e, t) ->
    touchMoved = false
    isSocialSharingOpen = false
    if e.originalEvent.touches.length isnt 1
      return

    if $(e.currentTarget).hasClass('system')
      return

    if e.target and e.target.nodeName is 'AUDIO'
      return

    if e.target and e.target.nodeName is 'A' and /^https?:\/\/.+/.test(e.target.getAttribute('href'))
      e.preventDefault()
      e.stopPropagation()

    message = this._arguments[1]
    doLongTouch = =>

      if window.plugins?.socialsharing?
        isSocialSharingOpen = true

        if e.target and e.target.nodeName is 'A' and /^https?:\/\/.+/.test(e.target.getAttribute('href'))
          if message.attachments?
            attachment = _.find message.attachments, (item) -> return item.title is e.target.innerText
            if attachment?
              socialSharing
                file: e.target.href
                subject: e.target.innerText
                message: message.msg
              return

          socialSharing
            link: e.target.href
            subject: e.target.innerText
            message: message.msg
          return

        if e.target and e.target.nodeName is 'IMG'
          socialSharing
            file: e.target.src
            message: message.msg
          return

      mobileMessageMenu.show(message, t, e, this)

    Meteor.clearTimeout t.touchtime
    t.touchtime = Meteor.setTimeout doLongTouch, 500

  "click .message img": (e, t) ->
    Meteor.clearTimeout t.touchtime
    if isSocialSharingOpen is true or touchMoved is true
      e.preventDefault()
      e.stopPropagation()

  "touchend .message": (e, t) ->
    Meteor.clearTimeout t.touchtime
    if isSocialSharingOpen is true
      e.preventDefault()
      e.stopPropagation()
      return

    if e.target and e.target.nodeName is 'A' and /^https?:\/\/.+/.test(e.target.getAttribute('href'))
      if touchMoved is true
        e.preventDefault()
        e.stopPropagation()
        return

      if cordova?.InAppBrowser?
        cordova.InAppBrowser.open(e.target.href, '_system')
      else
        window.open(e.target.href)

  "touchmove .message": (e, t) ->
    touchMoved = true
    Meteor.clearTimeout t.touchtime

  "touchcancel .message": (e, t) ->
    Meteor.clearTimeout t.touchtime

  "click .upload-progress-text > button": (e) ->
    e.preventDefault();
    Session.set "uploading-cancel-#{this.id}", true

  "click .unread-bar > button.mark-read": ->
    readMessage.readNow(true)

  "click .unread-bar > button.jump-to": (e, t) ->
    _id = t.data._id
    message = RoomHistoryManager.getRoom(_id)?.firstUnread.get()
    if message?
      RoomHistoryManager.getSurroundingMessages(message, 50)
    else
      subscription = ChatSubscription.findOne({ rid: _id })
      message = ChatMessage.find({ rid: _id, ts: { $gt: subscription?.ls } }, { sort: { ts: 1 }, limit: 1 }).fetch()[0]
      RoomHistoryManager.getSurroundingMessages(message, 50)


  "click .flex-tab .user-image > button" : (e, instance) ->
    instance.tabBar.open()
    instance.setUserDetail @username

  'click .user-card-message': (e, instance) ->
    roomData = Session.get('roomData' + this._arguments[1].rid)

    if RocketChat.Layout.isEmbedded()
      fireGlobalEvent('click-user-card-message', { username: this._arguments[1].u.username })
      e.preventDefault()
      e.stopPropagation()
      return

    if roomData.t in ['c', 'p', 'd']
      instance.setUserDetail this._arguments[1].u.username

    instance.tabBar.setTemplate('membersList')
    instance.tabBar.open()

  'scroll .wrapper': _.throttle (e, instance) ->
    if RoomHistoryManager.isLoading(@_id) is false and (RoomHistoryManager.hasMore(@_id) is true or RoomHistoryManager.hasMoreNext(@_id) is true)
      if RoomHistoryManager.hasMore(@_id) is true and e.target.scrollTop is 0
        RoomHistoryManager.getMore(@_id)
      else if RoomHistoryManager.hasMoreNext(@_id) is true and e.target.scrollTop >= e.target.scrollHeight - e.target.clientHeight
        RoomHistoryManager.getMoreNext(@_id)
  , 200

  'click .new-message': (e) ->
    Template.instance().atBottom = true
    Template.instance().find('.input-message').focus()

  'click .jump-recent button': (e, template) ->
    e.preventDefault()
    template.atBottom = true
    RoomHistoryManager.clear(template?.data?._id)

  'click .message': (e, template) ->
    if template.selectable.get()
      document.selection?.empty() or window.getSelection?().removeAllRanges()
      data = Blaze.getData(e.currentTarget)
      _id = data?._arguments?[1]?._id

      if !template.selectablePointer
        template.selectablePointer = _id

      if !e.shiftKey
        template.selectedMessages = template.getSelectedMessages()
        template.selectedRange = []
        template.selectablePointer = _id

      template.selectMessages _id

      selectedMessages = $('.messages-box .message.selected').map((i, message) -> message.id)
      removeClass = _.difference selectedMessages, template.getSelectedMessages()
      addClass = _.difference template.getSelectedMessages(), selectedMessages
      for message in removeClass
        $(".messages-box ##{message}").removeClass('selected')
      for message in addClass
        $(".messages-box ##{message}").addClass('selected')


Template.notifications.onCreated ->

  this.atBottom = if FlowRouter.getQueryParam('msg') then false else true
  this.unreadCount = new ReactiveVar 0

  this.selectable = new ReactiveVar false
  this.selectedMessages = []
  this.selectedRange = []
  this.selectablePointer = null

  this.flexTemplate = new ReactiveVar

  this.tabBar = new RocketChatTabBar();
  this.tabBar.showGroup('notifications');

  this.resetSelection = (enabled) =>
    this.selectable.set(enabled)
    $('.messages-box .message.selected').removeClass 'selected'
    this.selectedMessages = []
    this.selectedRange = []
    this.selectablePointer = null

  this.selectMessages = (to) =>
    if this.selectablePointer is to and this.selectedRange.length > 0
      this.selectedRange = []
    else
      message1 = ChatMessage.findOne this.selectablePointer
      message2 = ChatMessage.findOne to

      minTs = _.min([message1.ts, message2.ts])
      maxTs = _.max([message1.ts, message2.ts])

      this.selectedRange = _.pluck(ChatMessage.find({ rid: message1.rid, ts: { $gte: minTs, $lte: maxTs } }).fetch(), '_id')

  this.getSelectedMessages = =>
    messages = this.selectedMessages
    addMessages = false
    for message in this.selectedRange
      if messages.indexOf(message) is -1
        addMessages = true
        break

    if addMessages
      previewMessages = _.compact(_.uniq(this.selectedMessages.concat(this.selectedRange)))
    else
      previewMessages = _.compact(_.difference(this.selectedMessages, this.selectedRange))

    return previewMessages

Template.notifications.onDestroyed ->
  window.removeEventListener 'resize', this.onWindowResize

Template.notifications.onRendered ->

  wrapper = this.find('.wrapper')
  wrapperUl = this.find('.wrapper > ul')
  newMessage = this.find(".new-message")

  template = this

  messageBox = $('.messages-box')

  template.isAtBottom = (scrollThreshold) ->
    if not scrollThreshold? then scrollThreshold = 0
    if wrapper.scrollTop + scrollThreshold >= wrapper.scrollHeight - wrapper.clientHeight
      newMessage.className = "new-message background-primary-action-color color-content-background-color not"
      return true
    return false

  template.sendToBottom = ->
    wrapper.scrollTop = wrapper.scrollHeight - wrapper.clientHeight
    newMessage.className = "new-message background-primary-action-color color-content-background-color not"

  template.checkIfScrollIsAtBottom = ->
    template.atBottom = template.isAtBottom(100)
    readMessage.enable()
    readMessage.read()

  template.sendToBottomIfNecessary = ->
    if template.atBottom is true and template.isAtBottom() isnt true
      template.sendToBottom()

  template.sendToBottomIfNecessaryDebounced = _.debounce template.sendToBottomIfNecessary, 10

  template.sendToBottomIfNecessary()

  if not window.MutationObserver?
    wrapperUl.addEventListener 'DOMSubtreeModified', ->
      template.sendToBottomIfNecessaryDebounced()
  else
    observer = new MutationObserver (mutations) ->
      mutations.forEach (mutation) ->
        template.sendToBottomIfNecessaryDebounced()

    observer.observe wrapperUl,
      childList: true
  # observer.disconnect()

  template.onWindowResize = ->
    Meteor.defer ->
      template.sendToBottomIfNecessaryDebounced()

  window.addEventListener 'resize', template.onWindowResize

  wrapper.addEventListener 'mousewheel', ->
    template.atBottom = false
    Meteor.defer ->
      template.checkIfScrollIsAtBottom()

  wrapper.addEventListener 'wheel', ->
    template.atBottom = false
    Meteor.defer ->
      template.checkIfScrollIsAtBottom()

  wrapper.addEventListener 'touchstart', ->
    template.atBottom = false

  wrapper.addEventListener 'touchend', ->
    Meteor.defer ->
      template.checkIfScrollIsAtBottom()
    Meteor.setTimeout ->
      template.checkIfScrollIsAtBottom()
    , 1000
    Meteor.setTimeout ->
      template.checkIfScrollIsAtBottom()
    , 2000

  wrapper.addEventListener 'scroll', ->
    template.atBottom = false
    Meteor.defer ->
      template.checkIfScrollIsAtBottom()

  $('.flex-tab-bar').on 'click', (e, t) ->
    Meteor.setTimeout ->
      template.sendToBottomIfNecessaryDebounced()
    , 50

  rtl = $('html').hasClass('rtl')

  updateUnreadCount = _.throttle ->
    messageBoxOffset = messageBox.offset()

    if rtl
      lastInvisibleMessageOnScreen = document.elementFromPoint(messageBoxOffset.left+messageBox.width()-1, messageBoxOffset.top+1)
    else
      lastInvisibleMessageOnScreen = document.elementFromPoint(messageBoxOffset.left+1, messageBoxOffset.top+1)

    if lastInvisibleMessageOnScreen?.id?
      lastMessage = ChatMessage.findOne lastInvisibleMessageOnScreen.id
      if lastMessage?
        subscription = ChatSubscription.findOne rid: template.data._id
        count = ChatMessage.find({rid: template.data._id, ts: {$lte: lastMessage.ts, $gt: subscription?.ls}}).count()
        template.unreadCount.set count
      else
        template.unreadCount.set 0
  , 300

  readMessage.onRead (rid) ->
    if rid is template.data._id
      template.unreadCount.set 0

  wrapper.addEventListener 'scroll', ->
    updateUnreadCount()

  # salva a data da renderização para exibir alertas de novas mensagens
  $.data(this.firstNode, 'renderedAt', new Date)
