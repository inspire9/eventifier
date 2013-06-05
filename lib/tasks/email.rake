namespace :email do
  task :deliver => :environment do
    Eventifier::Delivery.deliver
  end
end
