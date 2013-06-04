class Eventifier::Mailer < ::ActionMailer::Base
  include Eventifier::Mailers::Helpers

  helper 'eventifier/notification'
  helper 'eventifier/path'

  default :from => Eventifier.mailer_sender

  def notifications(record)
    eventifier_mail(record, :notifications)
  end
end
