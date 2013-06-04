class Eventifier::NotificationMapping
  extend ObjectHelper

  def self.add(key, relation)
    notification_mappings[key] << relation
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

  def self.users_and_relations(event, key, &block)
    users = Hash.new { |hash, key| hash[key] = [] }

    find(key).each do |relation|
      method_from_relation(event.eventable, relation).each do |user|
        users[user] << relation
        users[user].uniq!
      end
    end

    users.each(&block)
  end

  private

  def self.notification_mappings
    @notification_mapppings ||= Hash.new { |hash, key|
      hash[key] = []
    }
  end
end
