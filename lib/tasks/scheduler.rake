desc "This task is called by the Heroku scheduler add-on"

task :orders_export => :environment do
	
	puts "Cron export started."
	TemplatesController.new.index
	puts "Cron export completed."
	
end
