json.array! @notifications do |notification|
  json.id notification.id
  json.html notification.to_s
end