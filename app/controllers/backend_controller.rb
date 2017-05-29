class BackendController < ApplicationController
  require 'rest-client'
  require 'uri'
  require 'net/http'
  require 'socket'
  require 'open-uri'

  def userimage
    azure_blob_service = Azure::Blob::BlobService.new
    image = Userimage.new
    image.platy = params[:image_file]
    image.save

    redirect_to :back
  end

  def userlike
    type = params[:type]
    id = params[:id].to_i

    if type == "item"
      record = Userlikeitem.where("user_id=? and product_id=?",current_user.id,id).first_or_create
      record.user_id = current_user.id
      record.product_id = id
      record.active = !record.active
      record.save
    elsif type == "shop"
      record = Userlikeshop.where("user_id=? and merchant_id=?",current_user.id,id).first_or_create
      record.user_id = current_user.id
      record.merchant_id = id
      record.active = !record.active
      record.save
    end
    render plain: "success"
  end

  def userprefer
    input = params[:prefer]
    session[:prefer] = input
    if !current_user.nil?
      current_user.prefer = session[:prefer]
      current_user.save
    end
    render plain: session[:prefer]
  end

	def db_input
		input = params[:input_textarea]
		
		table = input.split("\r\n")
		table.each do |line|
			i = 0
      whole_att = line.split("\t")
			if params[:table]=="merchant"
        record = Merchant.where("title=?",whole_att[2]).first_or_create
        whole_att.each do |att|

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
        record = Product.where("title=? and img_url=?",whole_att[1],whole_att[3]).first_or_create
				whole_att.each do |att|
					case i
            when 0
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
              record.category = record.category+','+att.gsub(/ /,'')
            when 7
              record.hashtag = att.gsub(/ /,'')
            when 8
              record.rating = att.to_i
            when 9
              record.color = att.gsub(/ /,'')
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
    record_url = ""
    case input_type
      when "merchant"
        record = Merchant.find(input_id)
        record_img = record.thumbnail
      when "product"
        record = Product.find(input_id)
        record_img = record.img_url
    end

    if record == ""
      encode_text = 'nothumbnail'
    elsif record.nil?
      encode_text = 'nothumbnail'
    else
      begin
      encode_text = Base64.encode64(open(record_img).read).gsub(/\n/,'')
      rescue OpenURI::HTTPError => e
        # it's 404, etc. (do nothing)
        record.destroy
      else
      record_url = "data:image/png;base64,"+encode_text
      end
    end

    case input_type
      when "merchant"
        # record.update(:thumbnail=>record_url)
      when "product"
        # record.update(:img_url=>record_url)
    end

    render :json => {:url=>record_url}
  end

  def kakao
    # data = {'grant_type'=>'refresh_token','client_id'=>"{#{ENV['kakao_key']}}",'refresh_token'=>"#{params[:refresh]}"}
    logger.info params[:token]
    session['omniauth.state'] =  SecureRandom.hex(24)


    redirect_to "/users/auth/kakao/callback?code=#{params[:token]}&state=#{session['omniauth.state']}"
  end
end
