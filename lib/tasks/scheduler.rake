desc "This task is called by the Heroku scheduler add-on"

task :orders_export => :environment do
  p TemplatesController.new.index
end
