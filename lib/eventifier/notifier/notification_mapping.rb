class Eventifier::NotificationMapping
  def self.add(key, relation)
    notification_mappings[key] << relation
  end

  def self.find(key)
    notification_mappings[key]
  end

  def self.all
    notification_mappings
  end

  def self.users_and_relations(event, key, &block)
    users = Hash.new { |hash, key| hash[key] = [] }

    find(key).each do |relation|
      Eventifier::Relationship.new(event.eventable, relation).users.each do |user|
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
