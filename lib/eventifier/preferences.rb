class Eventifier::Preferences
  def initialize(user)
    @user = user
  end

  def to_hashes
    keys.collect do |key|
      {
        :key   => key,
        :label => label_for(key),
        :value => value_for(key)
      }
    end
  end

  private

  attr_reader :user

  def keys
    @keys ||= begin
      hash = Eventifier::NotificationMapping.notification_mappings
      hash.keys.collect { |key|
        hash[key].collect { |value|
          (key.split('.') + ['notify', Eventifier::Relationship.new(user, value).key]).join('_')
        }
      }.flatten
    end
  end

  def label_for(key)
    I18n.translate :"events.labels.preferences.#{key}", default: key
  end

  def settings
    @settings ||= Eventifier::NotificationSetting.for_user user
  end

  def value_for(key)
    settings.preferences['email'].nil?      ||
    settings.preferences['email'][key].nil? ||
    settings.preferences['email'][key]
  end
end
