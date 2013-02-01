require 'rubygems'
require 'csv-mapper'
require 'open-uri'


class TemplatesController < ApplicationController

	include CsvMapper

	# GET /generate_template
	# GET /generate_template.json
	def index
 
		csv_file = ""

		# Copy the csv file localy through HTTP
		open('orders_export.csv', 'wb') do |file|
  			csv_file << open('http://betatopa.nextmp.net/orders_export/orders_export.csv').read
		end

		# Load the source csv file
		orders_export = import(csv_file) do
		  read_attributes_from_file
		end

		orders_line = 2

		while !orders_export[orders_line].nil? do
			
			p orders_export[orders_line].salesorderno
			p orders_export[orders_line].orderdate
			p orders_export[orders_line].emailaddress
			p orders_export[orders_line].ardivisionno
			p orders_export[orders_line].paymenttype
			p orders_export[orders_line].billtoname
			p orders_export[orders_line].billtoaddress1
			p orders_export[orders_line].billtocity
			p orders_export[orders_line].billtostate
			p orders_export[orders_line].billtozipcode
			p orders_export[orders_line].billtocountrycode
			p orders_export[orders_line].shiptoname
			p orders_export[orders_line].shiptoaddress1
			p orders_export[orders_line].shiptocity
			p orders_export[orders_line].shiptostate
			p orders_export[orders_line].shiptozipcode
			p orders_export[orders_line].shiptocountrycode

			orders_line += 1

		end


		# Finally, execute the SQL query on the middle-tier database
 
		# Accessing this view launch the service automatically
		respond_to do |format|
			format.html # index.html.erb
		end

	end

end
