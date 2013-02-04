desc "This task is called by the Heroku scheduler add-on"

task :orders_export => :environment do
  TemplatesController.new.index
end
