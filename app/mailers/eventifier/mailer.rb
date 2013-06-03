require_relative '../../helpers/notification_helper'

class Eventifier::Mailer < ::ActionMailer::Base
  include Eventifier::Mailers::Helpers

  def notifications(record)
    eventifier_mail(record, :notifications)
  end
end