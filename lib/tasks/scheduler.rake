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

task :products_export => :environment do
	
	puts "Products export started."
	puts "COPY (SELECT * FROM im1_inventorymasterfile ) TO STDOUT with CSV HEADER" | psql -o '/tmp/source.csv' d1uoa7pu2d1ssk
	puts "Products export completed."

end

