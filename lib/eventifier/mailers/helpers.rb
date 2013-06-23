module Eventifier
  module Mailers
    module Helpers
      extend ActiveSupport::Concern

      included do
        attr_reader :scope_name, :resource
      end

      protected

      # Configure default email options
      def eventifier_mail(user, records, action)
        initialize_from_record(user, records)
        mail headers_for(action)
      end

      def initialize_from_record(user, records)
        @user, @notifications = user, records
      end

      def headers_for(action)
        headers = {
          :subject       => I18n.t(:email_subject, :scope => [:notifications]),
          :from          => mailer_sender,
          :to            => @user.email,
          :template_path => template_paths
        }

        headers[:reply_to] = headers[:from] unless headers.key?(:reply_to)

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
        I18n.t(:"notifications_subject", :scope => [:eventifier, :notifications, key],
          :default => [:subject, key.to_s.humanize])
      end
    end
  end
end
