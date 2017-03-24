class BackendController < ApplicationController

	def db_input
		input = params[:input_textarea]
		
		table = input.split("\r\n")
		table.each do |line|
			record = Merchant.new		
			i = 0
			line.split("\t").each do |att| 
				
				case i
					when 0
						record = Merchant.new(ranknumber:att.to_i)
					when 1
						logger.info att
						if att == 'ㅇ'
							att = 1
						elsif att == 'ㅇㅇ'
							att = 2
						else
							att = 0
						end
						record.rating = att
					when 2
						record.title = att
					when 3
						record.category = att
					when 4
						record.hashtag = att
					when 5
						record.explain = att
					when 6
						if att.include?("http://")
							record.thumbnail = att
						else
							#record.thumbnail = "http://" +att
							record.thumbnail= att
						end
					when 7
						if att.include?("http://")
							record.url = att
						else
							record.url = "http://" +att
						end
				end

				i = i+1;
			
			end

			record.save
		end
		
		redirect_to "/db_admin"
	end

	def db_delete
		input = params[:id]
		record = Merchant.find(input.to_i)
		record.destroy
		redirect_to "/db_admin"
	end
	
	def db_destroy
		Merchant.destroy_all
		redirect_to "/db_admin"

	end

end
