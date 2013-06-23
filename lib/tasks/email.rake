namespace :eventifier do
  namespace :email do
    desc 'Send Eventifier notification emails'
    task :deliver => :environment do
      Eventifier::Delivery.deliver
    end
  end
end
