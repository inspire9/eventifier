json.last_read_at current_user.notifications_last_read_at.to_i
json.notifications @notifications do |notification|
  json.(notification, :id)
  json.created_at notification.created_at.to_i
  json.html render_partial_view(notification, :dropdown)
end