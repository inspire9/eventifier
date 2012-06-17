module Eventifier
  module GhostMixin

    extend ActiveSupport::Concern

    included do

      validates :ghost_class, :presence => true
      validates :ghost_id,    :presence => true
      validates :data_hash,   :presence => true
    end

    module ClassMethods
      def create_from_object object
        create :ghost_class => object.class.name, :ghost_id => object.id, :data_hash => object.serializable_hash
      end
    end

    def ghost
      klass = Object.const_get(ghost_class)
      ghost_object = klass.new data_hash
      ghost_object.id = ghost_id

      ghost_object
    end
  end
end