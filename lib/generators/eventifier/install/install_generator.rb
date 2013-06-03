require 'rails/generators/active_record'

module Eventifier
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_event_tracking
        copy_file "event_tracking.rb", "app/models/event_tracking.rb"
      end

      def copy_language
        copy_file "events.en.yaml", "config/locales/events.en.yaml"
      end
    end
  end
end
