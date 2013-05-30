class Eventifier::NotificationMapping
  def self.add(key, relation)
    notification_mappings[key] = relation
  end

  def self.find(key)
    notification_mappings[key]
  end

  def self.all
    notification_mappings
  end

  def self.users_for(event, key)
    method_from_relation(event.eventable, find(key))
  end

  private
  def self.method_from_relation object, relation
    if relation.kind_of?(Hash)
      method_from_relation(proc { |object, method| object.send(method) }.call(object, relation.keys.first), relation.values.first)
    else
      send_to = proc { |object, method| object.send(method) }.call(object, relation)
      send_to = send_to.kind_of?(Array) ? send_to : [send_to]
    end
  end

  def self.notification_mappings
    @notification_mapppings ||= {}
  end
end