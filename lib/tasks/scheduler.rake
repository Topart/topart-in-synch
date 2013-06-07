desc "This task is called by the Heroku scheduler add-on"

task :orders_header_export => :environment do
	
	puts "Cron export started."
	TemplatesController.new.to_mas_so_sales_order_header
	puts "Cron export completed."

end

task :orders_detail_export => :environment do
	
	puts "Cron export started."
	TemplatesController.new.to_mas_so_sales_order_detail
	puts "Cron export completed."

end

