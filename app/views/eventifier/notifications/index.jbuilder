json.array! @notifications do |notification|
  json.id notification.id
  json.html render_partial_view(notification, :dropdown)
end