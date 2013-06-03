# Usage
# window.notifications = new NotificationDropdown el: $('.notifications'), limit: 5

class window.NotificationDropdown
  constructor: (options) -> 
    {@el, @limit} = options

    @template = "<a href='#' class='toggleDropdown'>View Notifications</a><ol id='notification_dropdown'></ol>"

    @render()

  render: =>
    @el.html(@template).attr('tabindex', 0)

    @el.on 'click', '.toggleDropdown', @toggle
    $(window).on 'click', @blurNotifications

  isActive: =>
    @el.hasClass('notifications_active')

  toggle: (event)=>
    event.preventDefault() if event?

    @el.toggleClass('notifications_active')

  hide: =>
    @el.removeClass('notifications_active')
    $(window).off 'click', @blurNotifications

  blurNotifications: (event)=>
    if @isActive() and !jQuery.inArray(@el, $(event.target).parents())
      @toggle()