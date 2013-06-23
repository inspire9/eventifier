module Eventifier
  class Ghost < ActiveRecord::Base
    validates :ghost_class, :presence => true
    validates :ghost_id,    :presence => true
    validates :data_hash,   :presence => true

    serialize :data_hash

    def self.create_from_object object
      create :ghost_class => object.class.name, :ghost_id => object.id, :data_hash => object.serializable_hash
    end

    def ghost
      klass = Object.const_get(ghost_class)
      ghost_object = klass.new data_hash
      ghost_object.id = ghost_id

      ghost_object
    end
  end
end