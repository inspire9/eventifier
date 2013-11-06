#= require hamlcoffee
#= require ./templates/dropdown
#= require ./templates/settings
# Usage
# window.notifications = new NotificationDropdown el: $('.notifications'), limit: 5

class window.NotificationDropdown
  template: JST['eventifier/templates/dropdown']
  settingsTemplate: JST['eventifier/templates/settings']

  constructor: (options) ->
    {@el, @limit, @pollTime, @push} = options
    @limit =    @limit || 5
    @pollTime = @pollTime || 15
    @push = @push || false


    [@notifications, @renderedNotifications, @unreadCount, @lastReadAt] = [[], [], 0, new Date()]

    @render()
    @loadMore(limit: 14)

  render: =>
    @el.html(@template(@)).attr('tabindex', 0)

    # @checkVisibility()
    @setEvents()
    @poll()

  checkVisibility: =>
    @el.addClass("notifications_active").find('#notification_dropdown').attr('opacity': 0)
    @el.find('#notification_dropdown').offset (index, coords)=>
      coords.left = 10 if coords.left < 0
      if coords.left + @el.find('#notification_dropdown').width() > $(window).width()
        coords.left = $(window).width() - @el.find('#notification_dropdown').width() - 5

      @el.find('#notification_dropdown').offset coords

      if @el.find('#notification_dropdown').position().left > -@el.find('#notification_dropdown').width()/2
        @el.find('#notification_dropdown').addClass('left_nipple')

    @el.removeClass("notifications_active").find('#notification_dropdown').attr('opacity': 1)

  setEvents: =>
    @el.on 'click', '.toggle_dropdown', @toggleDropdown
    @el.on 'click', '.toggle_settings', @toggleSettings
    @el.on 'click', '#email_settings_default',   @defaultSettings
    @el.on 'click', '.save_settings',   @saveSettings
    @el.on 'addNotifications', @renderNotifications
    @el.on 'addNotifications', @setUnreadCount
    @el.on 'poll', @poll
    @el.on 'scroll', 'ol', @scrolling
    $(window).on 'click', @blurNotifications
    if @push
      @el.on 'click', '#notification_dropdown ol a', @pushUrl

    @

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
            @lastInserted.after @lastInserted = $("<li />")
              .addClass('unread')
              .html(notification.html)
          else
            @el
              .find('ol')
              .prepend @lastInserted = $("<li />")
                .addClass('unread')
                .html(notification.html)
        else
          @el
          .find('ol')
          .append($("<li />").html(notification.html))
        @renderedNotifications.push notification.id

    @lastInserted = null

  isActive: =>
    @el.hasClass('notifications_active')

  isAlerting: =>
    @unreadCount > 0

  toggleDropdown: (event)=>
    event.preventDefault() if event?

    @el.toggleClass('notifications_active')
    @setLastRead()

  toggleSettings: (event)=>
    event.preventDefault() if event?
    $.ajax
      url: "/preferences"
      success: (data)=>
        @el.find("#settings_pane").html(@settingsTemplate(data))
        @defaultSettings() if @arrayFromObject($.makeArray(data)).default
    @el.toggleClass('show_settings')

  defaultSettings: =>
    @el.find("#settings_pane").toggleClass("disabled")
    @el.find("input:not([id='email_settings_default'])").each ->
      $(@).attr(disabled: !$(@).attr('disabled')).prop('checked', true)

  saveSettings: (event)=>
    event.preventDefault() if event?

    serializedSettings = {}
    @el.find("input:checked").each ->
      serializedSettings[@name] = @value

    $.ajax
      url: "/preferences"
      type: "PUT"
      data: preferences: serializedSettings
      success: (data)=> @el.toggleClass('show_settings')
      error: -> alert "There was a problem saving your settings"

  hide: =>
    @el.removeClass('notifications_active')
    $(window).off 'click', @blurNotifications

  blurNotifications: (event)=>
    if @isActive() and $.inArray(@el[0], $(event.target).parents()) < 0
      @toggleDropdown()

  loadMore: (params = {})=>
    $.ajax
      url: "/notifications"
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
      @el.removeClass('alerting')
    else
      displayCount = @unreadCount
      @el.addClass('alerting')

    @el.find(".notification_alert").html(displayCount)
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
      $.post '/notifications/touch'

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
    Math.max(@lastReadAt.getTime()/1000, @newestNotificationTime())

  scrolling: =>
    scrollWindow = @$el.find('ol')

    if (scrollWindow.scrollTop() + scrollWindow.innerHeight() >= scrollWindow[0].scrollHeight - 50)
      @loadMore(after: @oldestNotificationTime())

  arrayFromObject: (collection)->
    serializedObject = {}
    $.each collection, ->
      serializedObject[@key] = @value

    serializedObject
