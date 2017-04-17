class BackendController < ApplicationController
  require 'open-uri'

	def db_input
		input = params[:input_textarea]
		
		table = input.split("\r\n")
		table.each do |line|
			i = 0
			if params[:table]=="merchant"
        record = Merchant.new
        line.split("\t").each do |att|

          case i
            when 0
              record.ranknumber = att.to_i
            when 1
              logger.info att
              if att == 'ㅇ'
                att = 1
              elsif att == 'ㅇㅇ'
                att = 2
              elsif att == 'ㅇㅇㅇ'
                att = 3
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

			else
				record = Product.new
				line.split("\t").each do |att|
					case i
            when 0
              logger.info att
							record.merchant_id = Merchant.find_by(:title=>att).id
						when 1
							record.title = att
						when 2
							record.price = att.to_i
						when 3
							record.img_url = att
						when 4
							record.url = att
            when 5
              record.category = att.gsub(/ /,'')
            when 6
              record.hashtag = att.gsub(/ /,'')
            when 7
              record.hashtag = att.gsub(/ /,'')
            when 8
              record.hashtag = att.gsub(/ /,'')
					end

					i = i+1;

				end

				record.save

			end
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

  def db_product_destroy
    Product.destroy_all
    redirect_to "/db_admin"
  end

  def img_reproduce
    input_type = params[:type]
    input_id = params[:id].to_i

    case input_type
      when "merchant"
        record = Merchant.find(input_id).thumbnail
      when "product"
        record = Product.find(input_id).img_url
    end

    if record == ""
      encode_text = 'nothumbnail'
    elsif record.nil?
      encode_text = 'nothumbnail'
    else
      encode_text = Base64.encode64(open(record).read).gsub(/\n/,'')
      record = "data:image/png;base64,"+encode_text
    end

    render :json => {:url=>record}
  end
end
