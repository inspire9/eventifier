module Eventifier
  module Mailers
    module Helpers
      extend ActiveSupport::Concern

      included do
        attr_reader :scope_name, :resource
      end

      protected

      # Configure default email options
      def eventifier_mail(record, action)
        initialize_from_record(record)
        mail headers_for(action)
      end

      def initialize_from_record(record)
        @notification = record
        @event = record.event
      end

      def headers_for(action)
        headers = {
          :subject       => "You have received a notification",
          :from          => mailer_sender,
          :to            => @notification.user.email,
          :template_path => template_paths
        }

        unless headers.key?(:reply_to)
          headers[:reply_to] = headers[:from]
        end

        headers
      end

      def mailer_sender
        if default_params[:from].present?
          default_params[:from]
        else
          Eventifier.mailer_sender
        end
      end

      def template_paths
        self.class.mailer_name
      end

      # Setup a subject doing an I18n lookup. At first, it attemps to set a subject
      # based on the current mapping:
      #
      #   en:
      #     devise:
      #       mailer:
      #         confirmation_instructions:
      #           user_subject: '...'
      #
      # If one does not exist, it fallbacks to ActionMailer default:
      #
      #   en:
      #     devise:
      #       mailer:
      #         confirmation_instructions:
      #           subject: '...'
      #
      def translate(mapping, key)
        I18n.t(:"notifications_subject", :scope => [:devise, :mailer, key],
          :default => [:subject, key.to_s.humanize])
      end
    end
  end
end
