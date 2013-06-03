class Eventifier::Mailer < ::ActionMailer::Base
  include Eventifier::Mailers::Helpers

  def notifications(record)
    eventifier_mail(record, :notifications)
  end
end