json.array! @notifications do |notification|
  json.id notification.id
  json.html render(partial: partial_view(notification, :dropdown)
end