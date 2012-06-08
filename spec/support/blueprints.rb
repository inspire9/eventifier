require 'machinist/active_record'
require 'eventifier'

Eventifier::Event.blueprint do
  user        { object.user || User.make! }
  eventable   { object.eventable || Post.make! }
  verb        { :update }
  change_data { { :date => [ 5.days.ago, 3.days.ago ] } }
end

Eventifier::Notification.blueprint do
  event { object.event || Eventifier::Event.make! }
  user  { object.user || User.make! }
end

Post.blueprint do
  title { "My amazing blog post" }
  body  { "A deep and profound analysis of life" }
end

User.blueprint do
  name  { "Billy #{sn}" }
  email { "billy#{sn}@email.com" }
end