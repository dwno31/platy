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


  def device_login
    input_id = params[:id]
    input_device = params[:device]
    status = ""
    login_user = ""

    login_identity = Identity.where(:uid=>input_id)

    if login_identity.empty?
      #유저 새로 만들어서 유저에 집어넣기
      new_identity = Identity.new
      new_identity.uid = input_id
      new_identity.provider = input_device

      new_user = User.new
      new_user.name = input_device
      new_user.email = input_id.to_s+"@device.login"
      new_user.password = Devise.friendly_token[0,20]
      new_user.save

      new_identity.user_id = new_user.id
      new_identity.save

      login_user= new_user
    else
      login_user = login_identity.take.user
    end

    sign_in(login_user, scope: :user)

    logger.info current_user.id
    render json: status
  end

  def device_likestatus
    uid = Identity.where(:uid=>params[:uid]).take.user.id
    pid = params[:productId].to_i
    type = params[:type]
    status = true

    check_status = current_user.userlikeitems.where("product_id=?",pid).first_or_create
    check_status.product_id = pid
    logger.info check_status.inspect
    logger.info check_status.active.to_s
    if check_status.active.nil? #nil일떄
      status = false
    elsif check_status.active == false #false일 떄
      logger.info "status falsㄷ래"
      status = false
    end

    if type == "toggle"
      status = !status
      logger.info "tolggle이래"
      check_status.active = status
      check_status.save
      ActionCable.server.broadcast("push_#{uid}", { pid: pid});
    end
    logger.info status

    if status
      status = 1
    else
      status = 0
    end


    render plain: status
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

      elsif params[:table]=="promotion"
        record = Promotion.where("title=? and banner_url=?",whole_att[0],whole_att[1]).first_or_create
        whole_att.each do |att|
          case i
            when 0
              record.title = att
            when 1
              record.banner_url = att
            when 2
              record.header_url = att
            when 3
              record.background = att
            when 4
              record.banner_background = att
          end

          i = i+1;

        end

        record.save
      elsif params[:table]=="promotion_product"
        record = Productswithpromotion.new
        whole_att.each do |att|
          case i
            when 0
              record.promotion_id = Promotion.find_by(:title=>att).id
            when 2
              product_record = Product.where(:title=>att).first_or_create
              product_record.merchant_id = Merchant.find_by(:title=>whole_att[1]).id
              product_record.title = att
              product_record.price = whole_att[4].gsub(/,/,'').to_i
              product_record.img_url = whole_att[6]
              product_record.url = whole_att[7]
              product_record.rating = whole_att[8].to_i
              product_record.save

              record.product_id = product_record.id
            when 5
              record.discount = att.gsub(/%/,'').to_i # 정수 ~~ 로 나온다 할인률이므로 가격표기는 1-할인률을 곱해서 floor(-2) 해서쓴다
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
							record.price = att.gsub(/,/,'').to_i
						when 3
              record.url = att
						when 4
              record.img_url = att
            when 5
              record.color = att.gsub(/ /,'')
            when 6
              record.hashtag = att.gsub(/ /,'')
            when 7
              record.category = att.gsub(/ /,'')
            when 8

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


  def feedback
    if params[:status].split(',').empty?
      status = session[:prefer_tags]
    else
      status = params[:status]
    end
    feedback = Feedback.new
    feedback.user_id = current_user
    feedback.location = params[:location]
    feedback.status = status
    feedback.request_type = params[:type]
    feedback.message = params[:message]
    feedback.save

    render :plain => "ok"
  end

  def kakao
    # data = {'grant_type'=>'refresh_token','client_id'=>"{#{ENV['kakao_key']}}",'refresh_token'=>"#{params[:refresh]}"}
    session['omniauth.state'] =  SecureRandom.hex(24)


    redirect_to "/users/auth/kakao/callback?code=#{params[:token]}&state=#{session['omniauth.state']}"
  end
end
