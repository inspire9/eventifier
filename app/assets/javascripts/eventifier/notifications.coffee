#= require eventifier/templates/dropdown
#= require eventifier/templates/settings

# Usage
#
# window.notifications = new NotificationDropdown
# or with options
# window.notifications = new NotificationDropdown trigger: '.notifications-toggle', pollTime: 60, limit: 10, push: true

# Options
# trigger - The selector for a dom element to add an onClick action to, which triggers the toggling of the notifications dropdown.  This is just the selector, not the jQuery object
# eg: new NotificationDropdown trigger: '.btn.notifications-toggle'
#
# limit (default: 5) - Limit the number of notifications to get in each load
#
# pollTime (default: 30) - Time in seconds between checks for new notifications
#
# push (default: false) - Enable HTML5 pushState for url changes. When set to true, onclick actions onto individual notifications are overriden and caught by either Backbone's history.nagivate (if Backbone is defined) or native browser history.pushState handler

class window.NotificationDropdown
  template: JST['eventifier/templates/dropdown']
  settingsTemplate: JST['eventifier/templates/settings']

  constructor: (options) ->
    {@trigger, @limit, @pollTime, @push} = options
    @trigger ||= '.notifications-toggle'
    @limit =    @limit || 5
    @pollTime = @pollTime || 30
    @push = @push || false

    [@notifications, @renderedNotifications, @unreadCount, @lastReadAt] = [[], [], 0, new Date()]

    @el = $(@template(@))

    @render()
    @loadMore(limit: 14)
    setTimeout =>
      @el.trigger 'poll'
    , @pollTime*1000

  render: =>
    @unsetEvents()
    @renderedNotifications = []
    @el.attr('tabindex', 0).appendTo $('body')

    @renderNotifications()
    # @checkVisibility()

    @setEvents()

  checkVisibility: =>
    @el.addClass("notifications-active").find('#notifications-dropdown').attr('opacity': 0)
    @el.find('#notifications-dropdown').offset (index, coords)=>
      coords.left = 10 if coords.left < 0
      if coords.left + @el.find('#notifications-dropdown').width() > $(window).width()
        coords.left = $(window).width() - @el.find('#notifications-dropdown').width() - 5

      @el.find('#notifications-dropdown').offset coords

      if @el.find('#notifications-dropdown').position().left > -@el.find('#notifications-dropdown').width()/2
        @el.find('#notifications-dropdown').addClass('left_nipple')

    @el.removeClass("notifications-active").find('#notifications-dropdown').attr('opacity': 1)

  setEvents: =>
    $('body').on 'click', @trigger, @toggleDropdown
    @el.on 'click', '.toggle-notifications-settings', @toggleSettings
    @el.on 'click', '#email_settings_default',   @defaultSettings
    @el.on 'click', '.save-settings',   @saveSettings
    @el.on 'addNotifications', @renderNotifications
    @el.on 'addNotifications', @setUnreadCount
    @el.on 'poll', @poll
    @el.find('.notifications-list-pane').on 'scroll', @scrolling
    $(window).on 'click', @blurNotifications
    if @push
      @el.on 'click', '#notifications-dropdown ol a', @pushUrl

    @

  unsetEvents: =>
    $('body').off 'click', @trigger, @toggleDropdown
    @el.off()

  pushUrl: (e)=>
    location = $(e.currentTarget).attr('href')
    location = $('<a />').attr(href: location).get(0).pathname if location.match /^https?\:\/\//

    Backbone?.history.navigate(location, true) || history.pushState({trigger: true}, '', location)
    @hide()

    false

  renderNotifications: =>
    @el.find(".none").remove() if @notifications.length > 0
    $.each @notifications, (index, notification)=>
      unless $.inArray(notification.id, @renderedNotifications) >= 0
        if new Date(notification.created_at) > @lastReadAt
          if @lastInserted?
            @lastInserted.after( @lastInserted = $("<li />")
              .addClass('unread')
              .html(notification.html)
            )
          else
            @el
              .find('ol')
              .prepend( @lastInserted = $("<li />")
                .addClass('unread')
                .html(notification.html)
            )
        else
          @el
          .find('ol')
          .append($("<li />").html(notification.html))
        @renderedNotifications.push notification.id

    @lastInserted = null

  isActive: =>
    @el.hasClass('notifications-active')

  isAlerting: =>
    @unreadCount > 0

  toggleDropdown: (e)=>
    e.preventDefault() if e?

    @el.toggleClass('notifications-active')
    @setLastRead()

  blurNotifications: (e)=>
    if @isActive() && $.inArray($(@trigger)[0], $(e.target).parents()) < 0 && $.inArray(@el.get(0), $(e.target).parents()) < 0
      @toggleDropdown()

  toggleSettings: (e)=>
    e.preventDefault() if e?
    $.ajax
      url: "/eventifier/preferences"
      success: (data)=>
        @el.find(".notifications-settings-pane").html(@settingsTemplate(settings: data))
        @defaultSettings() if @arrayFromObject($.makeArray(data)).default
    @el.toggleClass('notifications-show-settings')

  defaultSettings: =>
    @el.find(".notifications-settings-pane").toggleClass("disabled")
    @el.find("input:not([id='email_settings_default'])").each ->
      $(@).attr(disabled: !$(@).attr('disabled')).prop('checked', true)

  saveSettings: (e)=>
    e.preventDefault() if e?

    serializedSettings = {}
    @el.find("input:checked").each ->
      serializedSettings[@name] = @value

    $.ajax
      url: "/eventifier/preferences"
      type: "PUT"
      data: preferences: serializedSettings
      success: (data)=> @el.toggleClass('notifications-show-settings')
      error: -> alert "There was a problem saving your settings"

  hide: =>
    @el.removeClass('notifications-active')
    $(window).off 'click', @blurNotifications

  loadMore: (params = {})=>
    $.ajax
      url: "/eventifier/notifications"
      dataType: 'json'
      data: params
      success: @addNotifications
      error: => @el.off 'poll', @poll

  addNotifications: (data)=>
    @lastReadAt = new Date(data.last_read_at)
    new_notifications = $.grep(data.notifications, (notification)=>
      $.inArray(notification.id, $.map(@notifications, (n)->n.id)) < 0
    )
    @notifications = @notifications.concat new_notifications
    @el.off('scroll', 'ol', @scrolling) if data.notifications == []
    @el.trigger 'addNotifications'

  updateAlert: =>
    if @unreadCount == 0
      displayCount = null
      $(@trigger).removeClass('notifications-alerting')
    else
      displayCount = @unreadCount
      $(@trigger).addClass('notifications-alerting')

    $(@trigger).find(".notifications-alert").html(displayCount)
    $('title').html (index, old_html) ->
      if old_html.match /^\(\d+\).*/
        if displayCount > 0
          old_html.replace(/^\(\d+\)/, "(#{displayCount})");
        else
          old_html.replace(/^(\(\d+\))\s/, "");
      else
        if displayCount > 0
          "(#{displayCount}) #{old_html}"
        else
          old_html

  setUnreadCount: =>
    @unreadCount = $.grep(@notifications, (notification)=>
      new Date(notification.created_at) > @lastReadAt
    ).length

    @updateAlert()

    @unreadCount

  setLastRead: =>
    if @isAlerting()
      @lastReadAt = new Date()
      @setUnreadCount()
      $.post '/eventifier/notifications/touch'

  poll: =>
    @loadMore(recent: true, since: @lastLookTime())

    setTimeout =>
      @el.trigger 'poll'
    , @pollTime*1000

  oldestNotificationTime: =>
    Math.min.apply Math, $.map(@notifications, (notification)->
      notification.created_at
    )

  newestNotificationTime: =>
    if @notifications.length
      Math.max.apply Math, $.map(@notifications, (notification)->
        notification.created_at
      )
    else
      0

  lastLookTime: =>
    Math.max(@lastReadAt.getTime()/1000, @newestNotificationTime()/1000)

  scrolling: =>
    scrollWindow = @el.find('.notifications-list-pane')

    if (scrollWindow.scrollTop() + scrollWindow.innerHeight() >= scrollWindow[0].scrollHeight - 100)
      @loadMore(after: @oldestNotificationTime()/1000)

  arrayFromObject: (collection)->
    serializedObject = {}
    $.each collection, ->
      serializedObject[@key] = @value

    serializedObject
