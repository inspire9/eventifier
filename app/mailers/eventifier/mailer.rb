class Eventifier::Mailer < ::ActionMailer::Base
  include Eventifier::Mailers::Helpers

  helper 'eventifier/notification'
  helper 'eventifier/path'

  default :from => Eventifier.mailer_sender

  def notifications(user, records)
    eventifier_mail(user, records, :notifications)
  end
end
