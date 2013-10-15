require 'rubygems'
require 'sequel'
require 'csv-mapper'
require 'open-uri'


class TemplatesController < ApplicationController

	include CsvMapper

	def truncate_digits(number, digits)

		a = (( (number * 10**digits).to_i ).to_f / (10**digits).to_f).to_f
		b = a.to_i
		c = (a - b).to_f

		result = (c * 10**digits).to_i

		return result

	end


	def products_export

		db_connection_production = Sequel.connect('postgres://wmstzwyvztebck:Ip_u0EC3coXXQxHdwzfDQiWxcI@ec2-107-22-169-45.compute-1.amazonaws.com:5432/d1uoa7pu2d1ssk')
		# create a dataset from the items table
		im1_inventorymasterfile = db_connection_production[:im1_inventorymasterfile]

		file_name = "tmp/source.csv";
		csv_file = File.open(file_name, "w")
		csv_content = ""

		#product_counter = 0

		@csv_array = db_connection_production.fetch("SELECT * FROM im1_inventorymasterfile WHERE itemnumber='DBK 6648'").all
		
		@csv_array.each do |row|

			csv_content << row[:itemnumber]

		end

		csv_file.puts csv_content
		csv_file.close
 

	end


	# GET /generate_template
	# GET /generate_template.json
	def to_mas_so_sales_order_header
 
		csv_content = ""

		# Copy the csv file localy through HTTP
		open('orders_export.csv', 'wb') do |file|
  			csv_content << open('http://topartco.nextmp.net/orders_export/ToMAS_SO_SalesOrderHeader.csv').read
		end

		file_name = "ToMAS_SO_SalesOrderHeader.csv";
		csv_file = File.open(file_name, "w")
		csv_file.puts csv_content
		csv_file.close

		# Load the source csv file
		orders_export = import(csv_file) do
		  read_attributes_from_file
		end
		

		orders_line = 0


		# Finally, execute the SQL query on the middle-tier database
		# connect to an in-memory database
		#db_connection_test = Sequel.connect('postgres://zlqmruskgjfmsn:ZL1exeZYZEVN9O9E0qTQ8uKBmX@ec2-23-21-176-133.compute-1.amazonaws.com:5432/dajd8d3f0o9thb')
		db_connection_production = Sequel.connect('postgres://wmstzwyvztebck:Ip_u0EC3coXXQxHdwzfDQiWxcI@ec2-107-22-169-45.compute-1.amazonaws.com:5432/d1uoa7pu2d1ssk')

		# create a dataset from the items table
		com_tomas_so_salesorderhdr = db_connection_production[:com_tomas_so_salesorderhdr]
		#frommasar_customer = db_connection_production[:frommasar_customer]

		while !orders_export[orders_line].nil? do
			
			weborderid = orders_export[orders_line].weborderid
			customerid = orders_export[orders_line].customerid
			customerpono = orders_export[orders_line].customerpono
			salesorderno = orders_export[orders_line].salesorderno
			orderdate = orders_export[orders_line].orderdate
			emailaddress = orders_export[orders_line].emailaddress

			ardivisionno = orders_export[orders_line].ardivisionno
			shipvia = orders_export[orders_line].shipvia
			paymenttype = orders_export[orders_line].paymenttype
			warehousecode = orders_export[orders_line].warehousecode
			taxschedule = orders_export[orders_line].taxschedule

			billtoname = orders_export[orders_line].billtoname

			billtoaddress1 = orders_export[orders_line].billtoaddress1
			billtoaddress2 = orders_export[orders_line].billtoaddress2
			billtoaddress3 = orders_export[orders_line].billtoaddress3
			billtocity = orders_export[orders_line].billtocity

			billtostate = orders_export[orders_line].billtostate
			billtozipcode = orders_export[orders_line].billtozipcode
			billtocountrycode = orders_export[orders_line].billtocountrycode
			shiptoname = orders_export[orders_line].shiptoname

			shiptoaddress1 = orders_export[orders_line].shiptoaddress1
			shiptoaddress2 = orders_export[orders_line].shiptoaddress2
			shiptoaddress3 = orders_export[orders_line].shiptoaddress3

			shiptocity = orders_export[orders_line].shiptocity
			shiptostate = orders_export[orders_line].shiptostate
			shiptozipcode = orders_export[orders_line].shiptozipcode
			shiptocountrycode = orders_export[orders_line].shiptocountrycode
			
			customerno = ""

			# If the customer id already exists in the frommasar_customer table where the email address is the same, use that as CustomerNO
			db_connection_production.fetch("SELECT customerno FROM frommasar_customer WHERE emailaddress = ?", emailaddress) do |row|
  				customerno = row[:customerno]
			end

			# otherwise, we fill the Magento customer id with leading 0's
			if customerno.empty?
				customerno = customerid
			end

			# Map the shipping info
			if shipvia == "Delivery option - Fedex Groud"
				shipvia = "FE GROUND"
			end

			if shipvia == "Delivery option - Fedex 2-day"
				shipvia = "FE 2 DAY"
			end

			if shipvia == "Delivery option - Fedex Overnight"
				shipvia = "FE STD OVRNIGHT"
			end

			if shipvia == "Free Shipping - Free"
				shipvia = "FREE"
			end

			# Map the ARDivision info
			if ardivisionno == "NOT LOGGED IN" or ardivisionno == "General"
				ardivisionno = "00"
			end
			# Got to add the retail (01) and trade (02) divisions

			# Check if the sales order number is not already there. If not, insert the new record, otherwise update it
			record = com_tomas_so_salesorderhdr.where(:salesorderno => salesorderno)

			if !record.empty?
				# Update existing records
				record.update(:orderdate => orderdate, :emailaddress => emailaddress, :ardivisionno => ardivisionno,
				:shipvia => shipvia, :customerno => customerno, :customerpono => customerpono,
				:paymenttype => paymenttype, :billtoname => billtoname, :billtoaddress1 => billtoaddress1, :billtoaddress2 => billtoaddress2, :billtoaddress3 => billtoaddress3,
				:billtocity => billtocity, :billtostate => billtostate,
				:billtozipcode => billtozipcode, :billtocountrycode => billtocountrycode, :shiptoname => shiptoname, :shiptoaddress1 => shiptoaddress1, 
				:shiptoaddress2 => shiptoaddress2, :shiptoaddress3 => shiptoaddress3,
				:shiptocity => shiptocity, :shiptostate => shiptostate, :shiptozipcode => shiptozipcode, :shiptocountrycode => shiptocountrycode,
				:warehousecode => warehousecode, :taxschedule => taxschedule, :weborderid => weborderid)
			else

			# Populate the table
			com_tomas_so_salesorderhdr.insert(:salesorderno => salesorderno, :orderdate => orderdate, :emailaddress => emailaddress, :ardivisionno => ardivisionno,
				:shipvia => shipvia, :customerno => customerno, :customerpono => customerpono,
				:paymenttype => paymenttype, :billtoname => billtoname, :billtoaddress1 => billtoaddress1, :billtoaddress2 => billtoaddress2, :billtoaddress3 => billtoaddress3,
				:billtocity => billtocity, :billtostate => billtostate,
				:billtozipcode => billtozipcode, :billtocountrycode => billtocountrycode, :shiptoname => shiptoname, :shiptoaddress1 => shiptoaddress1,
				:shiptoaddress2 => shiptoaddress2, :shiptoaddress3 => shiptoaddress3,
				:shiptocity => shiptocity, :shiptostate => shiptostate, :shiptozipcode => shiptozipcode, :shiptocountrycode => shiptocountrycode,
				:warehousecode => warehousecode, :taxschedule => taxschedule, :weborderid => weborderid)

			end

			orders_line += 1

		end

		# print out the number of records
		puts "Item count: #{com_tomas_so_salesorderhdr.count}"
 

	end

	def pick_retail_sheet(sku_code)
		
		retail_csv_content = ""
		retail_file_name = ""

		open('retail_master.csv', 'wb') do |file|

			if sku_code == "PR"
  				retail_csv_content << open('http://topartco.nextmp.net/orders_export/retail_master_paper.csv').read
  				retail_file_name = "retail_master_paper.csv";
  			end

  			if sku_code == "CV"
  				retail_csv_content << open('http://topartco.nextmp.net/orders_export/retail_master_canvas.csv').read
  				retail_file_name = "retail_master_canvas.csv";
  			end
		end

		retail_csv_file = File.open(retail_file_name, "w")
		retail_csv_file.puts retail_csv_content
		retail_csv_file.close

		# Load the retail csv file
		retail_master = import(retail_csv_file) do
		  read_attributes_from_file
		end

		return retail_master

	end


	def to_mas_so_sales_order_detail
 
		csv_content = ""

		# Copy the csv file localy through HTTP
		open('ToMas_SO_SalesOrderDetail.csv', 'wb') do |file|
  			csv_content << open('http://topartco.nextmp.net/orders_export/ToMas_SO_SalesOrderDetail.csv').read
		end

		file_name = "ToMas_SO_SalesOrderDetail.csv";
		csv_file = File.open(file_name, "w")
		csv_file.puts csv_content
		csv_file.close

		# Load the source csv file
		orders_export = import(csv_file) do
		  read_attributes_from_file
		end
		

		orders_line = 0


		# Finally, execute the SQL query on the middle-tier database
		#db_connection_test = Sequel.connect('postgres://zlqmruskgjfmsn:ZL1exeZYZEVN9O9E0qTQ8uKBmX@ec2-23-21-176-133.compute-1.amazonaws.com:5432/dajd8d3f0o9thb')
		db_connection_production = Sequel.connect('postgres://wmstzwyvztebck:Ip_u0EC3coXXQxHdwzfDQiWxcI@ec2-107-22-169-45.compute-1.amazonaws.com:5432/d1uoa7pu2d1ssk')

		# create a dataset from the details table
		com_tomas_so_salesorderdetl = db_connection_production[:com_tomas_so_salesorderdetl]

		# create a dataset from the from MAS sales order history header table. Used to avoid data re-population
		com_frommas_so_salesorderhisthdr = db_connection_production[:com_frommas_so_salesorderhisthdr]

		# create a dataset from the items table
		im1_inventorymasterfile = db_connection_production[:im1_inventorymasterfile]



		orders_line = 0

		while !orders_export[orders_line].nil? do
			
			weborderid = orders_export[orders_line].weborderid
			salesorderno = orders_export[orders_line].salesorderno
			sequenceno = orders_export[orders_line].sequenceno
			p sequenceno
			
			itemcode = orders_export[orders_line].itemcode
			itemcodedesc = orders_export[orders_line].itemcodedesc
			itemtype = orders_export[orders_line].itemtype
			quantityorderedoriginal = orders_export[orders_line].quantityorderedoriginal
			originalunitprice = orders_export[orders_line].originalunitprice
			dropship = "Y"

			substrate = orders_export[orders_line].substrate
			width = orders_export[orders_line].width
			height = orders_export[orders_line].length
			
			border = orders_export[orders_line].border
			fs = orders_export[orders_line].fs
			embellish = orders_export[orders_line].embellish
			wrap = orders_export[orders_line].wrap
			link = orders_export[orders_line].link

			covering = orders_export[orders_line].covering
			edge = orders_export[orders_line].edge



			# Info needed to retrieve the correct UI cost: image source, sku

			image_ui = width.to_i + height.to_i
			fsm_width = 0
			fsm_height = 0

			if width.include?('.')
				fsm_width = truncate_digits(width.to_f, 2)
			else
				fsm_width = 0
			end

			if height.include?('.')
				fsm_height = truncate_digits(height.to_f, 2)
			else
				fsm_height = 0
			end

			udf_imsource = ""
  			udf_ratiodec = ""
  			udf_entitytype = ""

			db_connection_production.fetch("SELECT udf_imsource, udf_ratiodec, udf_entitytype FROM im1_inventorymasterfile WHERE itemnumber = ?", itemcode) do |row|
	  			udf_imsource = row[:udf_imsource]
	  			udf_ratiodec = row[:udf_ratiodec].to_f
	  			udf_entitytype = row[:udf_entitytype]
			end


			# Scan each line in the correct retail master sheet
			retail_line = 0
			unitcost = 0

			# Select the correct retail sheet, depending on the substrate

			p "begin_"
			p substrate
			p "_end"

			retail_master = pick_retail_sheet(substrate)

			while !retail_master[retail_line].nil? do

				# If Poster or digital Paper
				if udf_entitytype == "Poster" or (udf_entitytype == "Image" and substrate == "PR")

					imagesource = retail_master[retail_line].imagesource
					ratiodec = retail_master[retail_line].ratiodec.to_f
					ui = retail_master[retail_line].ui.to_i
					imagesqin = retail_master[retail_line].imagesqin.to_f
					rolledpapertaruicost = retail_master[retail_line].rolledpapertaruicost.to_f

					if imagesource == udf_imsource and ratiodec == udf_ratiodec and ui == image_ui

						if imagesource != "Old World"

							unitcost = ui * rolledpapertaruicost
							break

						else

							unitcost = imagesqin * rolledpapertaruicost
							break

						end

					end

				end



				# If digital canvas
				if (udf_entitytype == "Image" and substrate == "CV")

					imagesource = retail_master[retail_line].imagesource
					ratiodec = retail_master[retail_line].ratiodec.to_f
					imagesqin = retail_master[retail_line].imagesqin.to_f

					border_treatment_code = retail_master[retail_line].skucode.to_f
					
					ui = 0
					uicost = 0.0

					if border_treatment_code == "WH"
						ui = retail_master[retail_line].wh_ui.to_i
						uicost = retail_master[retail_line].wh_uicost.to_f
					end

					if border_treatment_code == "BL"
						ui = retail_master[retail_line].bl_ui.to_i
						uicost = retail_master[retail_line].bl_uicost.to_f
					end

					if border_treatment_code == "MR"
						ui = retail_master[retail_line].mr_ui.to_i
						uicost = retail_master[retail_line].mr_uicost.to_f
					end
					
					# Now also identify the exact type of border treatment
					if border_treatment_code == border
						
						if imagesource == udf_imsource and ratiodec == udf_ratiodec and ui == image_ui

							if imagesource != "Old World"

								unitcost = ui * uicost
								break

							else

								unitcost = imagesqin * uicost
								break

							end

						end

					end					


				end



				if udf_entitytype == "Frame" or udf_entitytype == "Stretch" or udf_entitytype == "Mat"



				end

				retail_line = retail_line + 1

			end	



			# Check if the sales order number is not already there. If not, insert the new record, otherwise update it
			record = com_frommas_so_salesorderhisthdr.where(:weborderid => weborderid)

			# If there is no record in InSynch with the same WebOrderId, then populate the database with this record
			if record.empty?
				com_tomas_so_salesorderdetl.insert(:salesorderno => salesorderno, :sequenceno => sequenceno, :itemcode => itemcode, :itemcodedesc => itemcodedesc, 
					:itemtype => itemtype, :quantityorderedoriginal => quantityorderedoriginal, :originalunitprice => originalunitprice, :dropship => dropship,
					:substrate => substrate,
					:width => width.to_i, :height => height.to_i, :border => border, :fs => fs, :embellish => embellish, :wrap => wrap, :link => link,
					:covering => covering, :edge => edge, :unitcost => unitcost, :fsm_width => fsm_width, :fsm_height => fsm_height)
			end

			orders_line += 1

		end

		# print out the number of records
		puts "Item count: #{com_tomas_so_salesorderdetl.count}"
 
		# Accessing this view launch the service automatically
		#respond_to do |format|
		#	format.html # index.html.erb
		#end

	end

end
