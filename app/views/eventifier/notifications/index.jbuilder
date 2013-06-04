json.array! @notifications do |notification|
  json.id notification.id
  json.html render(partial: partial_view(notification, :dropdown), object: notification.event, locals: { notification: notification, event: notification.event, object: notification.event.eventable })
end