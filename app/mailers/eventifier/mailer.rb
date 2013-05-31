class Eventifier::Mailer < ::ActionMailer::Base
  include Eventifier::NotificationHelper

  def notifications(record)
    eventifier_mail(record, :notifications)
  end
end