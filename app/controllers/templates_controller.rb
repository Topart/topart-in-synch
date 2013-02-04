require 'rubygems'
require 'sequel'
require 'csv-mapper'
require 'open-uri'


class TemplatesController < ApplicationController

	include CsvMapper

	# GET /generate_template
	# GET /generate_template.json
	def to_mas_so_sales_order_header
 
		csv_content = ""

		# Copy the csv file localy through HTTP
		open('orders_export.csv', 'wb') do |file|
  			csv_content << open('http://betatopa.nextmp.net/orders_export/ToMAS_SO_SalesOrderHeader.csv').read
		end

		file_name = "ToMAS_SO_SalesOrderHeader.csv";
		csv_file = File.open(file_name, "w")
		csv_file.puts csv_content
		csv_file.close

		# Load the source csv file
		orders_export = import(csv_file) do
		  read_attributes_from_file
		end
		

		orders_line = 2


		# Finally, execute the SQL query on the middle-tier database
		# connect to an in-memory database
		db_connection = Sequel.connect('postgres://zlqmruskgjfmsn:ZL1exeZYZEVN9O9E0qTQ8uKBmX@ec2-23-21-176-133.compute-1.amazonaws.com:5432/dajd8d3f0o9thb')

		# create a dataset from the items table
		com_tomas_so_salesorderhdr = db_connection[:com_tomas_so_salesorderhdr]


		while !orders_export[orders_line].nil? do
			
			salesorderno = orders_export[orders_line].salesorderno
			orderdate = orders_export[orders_line].orderdate
			emailaddress = orders_export[orders_line].emailaddress
			ardivisionno = orders_export[orders_line].ardivisionno
			paymenttype = orders_export[orders_line].paymenttype
			billtoname = orders_export[orders_line].billtoname
			billtoaddress1 = orders_export[orders_line].billtoaddress1
			billtocity = orders_export[orders_line].billtocity
			billtostate = orders_export[orders_line].billtostate
			billtozipcode = orders_export[orders_line].billtozipcode
			billtocountrycode = orders_export[orders_line].billtocountrycode
			shiptoname = orders_export[orders_line].shiptoname
			shiptoaddress1 = orders_export[orders_line].shiptoaddress1
			shiptocity = orders_export[orders_line].shiptocity
			shiptostate = orders_export[orders_line].shiptostate
			shiptozipcode = orders_export[orders_line].shiptozipcode
			shiptocountrycode = orders_export[orders_line].shiptocountrycode
			shipvia = orders_export[orders_line].shipvia

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

			# Map the ARDivision info
			if ardivisionno == "NOT LOGGED IN" or ardivisionno == "General"
				ardivisionno = "00"
			end
			# Got to add the retail (01) and trade (02) divisions

			# Populate the table
			com_tomas_so_salesorderhdr.insert(:salesorderno => salesorderno, :orderdate => orderdate, :emailaddress => emailaddress, :ardivisionno => ardivisionno,
				:shipvia => shipvia,
				:paymenttype => paymenttype, :billtoname => billtoname, :billtoaddress1 => billtoaddress1, :billtocity => billtocity, :billtostate => billtostate,
				:billtozipcode => billtozipcode, :billtocountrycode => billtocountrycode, :shiptoname => shiptoname, :shiptoaddress1 => shiptoaddress1,
				:shiptocity => shiptocity, :shiptostate => shiptostate, :shiptozipcode => shiptozipcode, :shiptocountrycode => shiptocountrycode)

			orders_line += 1

		end

		# print out the number of records
		puts "Item count: #{com_tomas_so_salesorderhdr.count}"
 
		# Accessing this view launch the service automatically
		respond_to do |format|
			format.html # index.html.erb
		end

	end


	def to_mas_so_sales_order_detail
 
		csv_content = ""

		# Copy the csv file localy through HTTP
		open('ToMas_SO_SalesOrderDetail.csv', 'wb') do |file|
  			csv_content << open('http://betatopa.nextmp.net/orders_export/ToMas_SO_SalesOrderDetail.csv').read
		end

		file_name = "ToMas_SO_SalesOrderDetail.csv";
		csv_file = File.open(file_name, "w")
		csv_file.puts csv_content
		csv_file.close

		# Load the source csv file
		orders_export = import(csv_file) do
		  read_attributes_from_file
		end
		

		orders_line = 2


		# Finally, execute the SQL query on the middle-tier database
		db_connection = Sequel.connect('postgres://zlqmruskgjfmsn:ZL1exeZYZEVN9O9E0qTQ8uKBmX@ec2-23-21-176-133.compute-1.amazonaws.com:5432/dajd8d3f0o9thb')

		# create a dataset from the items table
		com_tomas_so_salesorderdetl = db_connection[:com_tomas_so_salesorderdetl]


		while !orders_export[orders_line].nil? do
			
			salesorderno = orders_export[orders_line].salesorderno
			sequenceno = orders_export[orders_line].sequenceNo
			itemcode = orders_export[orders_line].itemcode
			itemtype = orders_export[orders_line].itemtype
			quantityorderedoriginal = orders_export[orders_line].quantityorderedoriginal
			originalunitprice = orders_export[orders_line].originalunitprice

			# Populate the table
			com_tomas_so_salesorderdetl.insert(:salesorderno => salesorderno, :sequenceno => sequenceno, :itemcode => itemcode, :itemtype => itemtype,
				:quantityorderedoriginal => quantityorderedoriginal, :originalunitprice => originalunitprice)

			orders_line += 1

		end

		# print out the number of records
		puts "Item count: #{com_tomas_so_salesorderdetl.count}"
 
		# Accessing this view launch the service automatically
		respond_to do |format|
			format.html # index.html.erb
		end

	end

end
