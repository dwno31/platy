class FrontController < ApplicationController

require 'browser'

before_action :mobile_check, only:[:index]

	def index
		@category_list = ["우드트레이","볼","플레이트","커트러리",'컵','티팟','유리','티세트','커피','홈세트','트레이','매트','키친웨어','패브릭','소품']
		@purpose_list = ['한식','양식','면','혼밥','술','홈카페','디저트','홈파티','어린이','신혼','선물','조리']
		@category_list = @category_list + @purpose_list
		@style_list = ['럭셔리','로맨틱','클래식','유니크','엔틱','핸드메이드','일본','북유럽','폴란드','심플','모던','일러스트','귀여운','컬러풀','내츄럴']
		@render_hash = {:스타일=>@style_list,:카테고리=>@category_list}
		filter_tag = []
		index_product = []
		#유저가 그냥 넘어갔을때 보여주는 상품리스트, 프로덕트 레코드 어레이를 리턴해서 인덱스 프로덕트에 저장
		if current_user.nil?||current_user.prefer.nil?
      index_product = prefer_scenario(nil)
      logger.info "index-nil"
    else
      index_product = prefer_scenario(current_user.prefer)
    end
    logger.info index_product.inspect

		productlist(index_product)
    userlikelist(current_user)
    logger.info @prefer_tags
	end

	def table
		@merchants = Merchants.all
	end

	def pcindex

	end

	def search_toggle
    type = params[:type]
		if type == "item"
      if params[:toggle]=="1"
      render partial: "front/items/item_search"
      else
      @prefer_tags = session[:prefer_tags]
      render partial: "front/items/notibar"
			end
		elsif type== 'shop'
			if params[:toggle]=="1"
				render partial: "front/browse/shop_search"
			else
				render partial: "front/browse/tag_browser"
			end
		end
	end

	def search_shop
		userlikelist(current_user)
		keyword = params[:keyword]
		@merchant = Merchant.where("title like ? or hashtag like ?","%#{keyword}%","%#{keyword}%").order(rating: :desc)


		render partial: "front/browse/contents"
	end
  def search_item
		userlikelist(current_user)
		keyword = params[:keyword]

		@records = Product.where("title like ? or category like ? or hashtag like ?","%#{keyword}%","%#{keyword}%","%#{keyword}%").order(rating: :desc)
		@merchant_record = Merchant.where("title like ?","%#{keyword}%").map{|x|x.products.order(rating: :desc)}
		@product1 = []
		@product2 = []
		tog = false

		@records.each do |record|
			case tog
				when false
					@product1.push(record) #홀수는 여기다 넣고
				when true
					@product2.push(record) #짝수는 여기다 넣어서 렌더링으로 넘겨준다
			end
			tog = !tog
		end

		@merchant_record.each do |relation|
			relation.each do |record|
			case tog
				when false
					@product1.push(record) #홀수는 여기다 넣고
				when true
					@product2.push(record) #짝수는 여기다 넣어서 렌더링으로 넘겨준다
			end
			tog = !tog
				end
		end

		render partial: "front/items/contents"
  end

	def section_load
		userlikelist(current_user)
		menu = params[:menu]
		case menu
			when "shop"
				shoplist(nil)
				render partial: "front/browse/contents-frame"
			when "likeshop"
				if current_user.nil?
					shoplist(false)
				else
					shoplist(current_user)
				end
				render partial: "front/likelist/contents-shop-frame"
			when "product"
				logger.info "hello...?"
				if current_user.nil?||current_user.prefer.nil?
					prefer_tag = nil
				elsif
					prefer_tag = current_user.prefer
				end
				call_products = prefer_scenario(prefer_tag)
        @prefer_tags = session[:prefer_tags]
				logger.info session[:prefer_tags]
				productlist(call_products)
				render partial: "front/items/contents-frame"
			when "likeitem"
				likelist(current_user)
				render partial: "front/likelist/contents-item-frame"
      when "home"
        @head_tag = ["기획전","특가상품","작가추천","인기 Top10","기간할인"]
				render partial: "front/home/contents-frame"
		end
	end

	def product_rcmd
		input_id = params[:id].to_i
		@input_record = Product.find(input_id)
		rcmd_product = []
		category = @input_record.category.split(',')
		hashtag = @input_record.hashtag.split(',')
		colors = @input_record.color.split(',')

		hashtag.each do |tag|
			colors.each do |color|
				Product.where("hashtag like ? and rating=? and color like ?","%#{tag}%",1,"%#{color}%").order("RAND()").map{|record| rcmd_product.push(record)}
			end
		end

		userlikelist(current_user)
		productlist(rcmd_product.uniq)
		render partial: "front/modal/product_rcmd", layout: false
	end

	def contents_reload
		userlikelist(current_user)
		section_type = params[:section]
		case section_type
			when "shop"
				if params[:id].nil?
					@merchant = Merchant.all
				else
					input_tags = params[:id].split(',')
					input_tags.shift #destroy first one
					logger.info input_tags
					@merchant = []
					input_tags.each do |tag|
						@merchant = @merchant + Merchant.where("category like ?","%#{tag}%")
					end
					@merchant = @merchant.uniq
				end

				render partial: "front/browse/contents", layout: false
      when "item"
        if params[:color].nil?
					input_color = []
				else
					input_color = params[:color].split(',').map{|x|"%#{x}%"}
				end
				if params[:id].nil?
					@product = Product.order(rating: :desc)
				elsif params[:hashtag].nil?
					input_tags = params[:id].split(',')
					input_tags.shift #destroy first one
					logger.info input_tags
					@product = []
					input_tags.each do |tag|
						@product = @product + Product.where("category like ?","%#{tag}%").order(rating: :desc)
					end
					@product = @product.uniq
				else
					input_category = params[:id].split(',')[0]
					hashtag = params[:hashtag].gsub('undefined','').split(',').reject{|c|c.empty?}
					input_style = params[:hashtag].split(',')[0]
					input_purpose = params[:hashtag].split(',')[1]
					if hashtag.length==2
						@product = Product.where("category like ? and (hashtag like ? or hashtag like ?)","%#{input_category}%","%#{input_style}%","%#{input_purpose}%").order(rating: :desc)
					else
						@product = Product.where("category like ? and (hashtag like ?)","%#{input_category}%","%#{hashtag[0]}%").order(rating: :desc)
					end

				end
				product_with_color = []

				input_color.each do |color|
					product_with_color.push(@product.where("color like ?",color))
				end

				if product_with_color.empty?

				else
					@product = product_with_color.inject{|sum,x|sum+x}
				end

				logger.info @product.pluck(:color)
				productlist(@product.uniq)
				tags = [input_category,input_style,input_purpose]
				session[:prefer_tags] = tags
				@prefer_tags = tags


				render partial: "front/items/contents-frame", layout: false
		end

	end

	def shop_product
		userlikelist(current_user)
		@product1 = []
		@product2 = []
		tog = false
		if !params[:id].nil?
			@merchant = Merchant.find(params[:id].to_i)
		end
		@merchant.products.each do |record|
			case tog
				when false
					@product1.push(record) #홀수는 여기다 넣고
				when true
					@product2.push(record) #짝수는 여기다 넣어서 렌더링으로 넘겨준다
			end
			tog = !tog
		end
		render partial:"front/modal/shop_product",layout:false
	end

	def slide_tag
		slide_type = params[:slide]

		if slide_type =="shop"
			render partial:"front/browse/tag_browser", layout:false
		elsif slide_type =="item"
			render partial:"front/items/tag_browser", layout:false
		end

	end

	def slide_contents
		userlikelist(current_user)
		slide_type = params[:slide]
		index = params[:index]
    hashtag = params[:hashtag].gsub('undefined','').split(',').reject{|c|c.empty?}
		input_color = params[:color].split(',').map{|x|"%#{x}%"}
		page = params[:page].to_i
    product_with_color = []
    logger.info "slidecontents"
		logger.info hashtag.empty?

		if slide_type =="shop"	#샵이 불리면 그냥 샵리스트를 불러주고 추가적인 처리는 contents reload메소드에서
			render partial:"front/browse/contents", layout:false
		elsif slide_type =="item"	#아이템이 불리면 인풋되는 인덱스/페이지에 따라서 아이템을 호출해서 렌더로 던져준다
			start_number = page*24
			if index=="index" && hashtag.empty?
				if current_user.nil?||current_user.prefer.nil?
					prefer_tag = nil
				else
					prefer_tag = current_user.prefer
				end
				@product = prefer_scenario(prefer_tag)
				logger.info @product.size
			else
				index = index.gsub('index','')
				logger.info hashtag
				if hashtag.length == 2
					@product = Product.where("category like ? and (hashtag like ? or hashtag like ?)","%#{index}%","%#{hashtag[0]}%","%#{hashtag[1]}%").order(rating: :desc)
				else
					@product = Product.where("category like ? and hashtag like ?","%#{index}%","%#{hashtag[0]}%").order(rating: :desc) #추후 인덱스에 맞는것만 불러오게 수
				end
				logger.info @product.size

			end

			product_with_color = []

			input_color.each do |color|
				product_with_color.push(@product.where("color like ?",color))
			end

			if product_with_color.empty?

			else
				@product = product_with_color.inject{|sum,x|sum+x}
			end

			@product = @product.uniq

			@records = (start_number..start_number+23).to_a.map{|x|@product[x]}

			@product1 = []
			@product2 = []
			tog = false

			@records.each do |record|
				case tog
					when false
						@product1.push(record) #홀수는 여기다 넣고
					when true
						@product2.push(record) #짝수는 여기다 넣어서 렌더링으로 넘겨준다
				end
				tog = !tog
      end

			@product1.compact!
			@product2.compact!

			if (@product1.empty?)&(@product2.empty?)
				render plain: "nil"
			else
				render partial:"front/items/contents", layout:false
			end
		end

	end

	def bridge

		input = params[:id]
		@record = Product.find(input.to_i)
		#@record.counter = @record.counter +1;
		#@record.save

	end

	def outlink

		input = params[:id]
		@record = Merchant.find(input.to_i)
		@device_check = browser.platform.ios?

	end


#for admin below


	def db_admin
		@merchants = Merchant.all
	end

	def db_input

	end

private

	def mobile_check
		logger.info browser.device.mobile?
		logger.info "필터걸림"

		if browser.platform.mac?
			
			redirect_to action:"pcindex"

		elsif browser.platform.windows?

			redirect_to action:"pcindex"
		end

	end

	def userlikelist(record)
		@userlikeshops = []
		@userlikeitems = []
		unless record.nil?
      @userlikeshops = current_user.userlikeshops.where(:active=>true).pluck(:merchant_id)
      @userlikeitems = current_user.userlikeitems.where("active=?",true).pluck(:product_id)
		end
	end

	def shoplist(record)
		@head_tag = ["모던한","북유럽","브랜드","핸드메이드","일본식","귀여운","클래식","한식"]
		if record.nil?
			@merchant = Merchant.all
		elsif record.is_a?(ActiveRecord::Base)
			@merchant = record.userlikeshops.where(:active=>true).map{|x|x.merchant}
		elsif record.kind_of?(String)
			input_tags = params[:id].split(',')
			input_tags.shift #destroy first one
			logger.info input_tags
			@merchant = []
			input_tags.each do |tag|
				@merchant = @merchant + Merchant.where("category like ?","%#{tag}%")
			end
			@merchant = @merchant.uniq
		elsif !record
			@merchant = []
		end
		return @merchant
	end

	def productlist(record)
    @head_tag = ["우드트레이","볼","플레이트","커트러리","홈세트","머그","소품","매트"]
    if record.nil?
      @product = Product.order(rating: :desc)
		else
			@product = record
		end
		start_number = 0
		prolong_number = 23
		#record_pool = Product.where() 추후 인덱스에 맞는것만 불러오게 수정
		@records = (start_number..start_number+prolong_number).to_a.map{|x|@product[x]}

		@product1 = []
		@product2 = []
		tog = false

		@records.each do |record|
			case tog
				when false
					@product1.push(record) #홀수는 여기다 넣고
				when true
					@product2.push(record) #짝수는 여기다 넣어서 렌더링으로 넘겨준다
			end
			tog = !tog
		end

    @product1.compact!
		@product2.compact!
	end

	def likelist(record)
		@records = []
		unless record.nil?
		@records = record.userlikeitems.where("active=?",true).reverse.map{|x|x.product}
		end
		@product1 = []
		@product2 = []
		tog = false

		@records.each do |record|
			case tog
				when false
					@product1.push(record) #홀수는 여기다 넣고
				when true
					@product2.push(record) #짝수는 여기다 넣어서 렌더링으로 넘겨준다
			end
			tog = !tog
		end
	end

	#prefer시나리오에 따라서 tag 를 받고(없으면 랜덤)product record array를 리턴해준다

  def prefer_scenario(tags)
		@category_list = ["우드트레이","볼","플레이트","커트러리",'컵','티팟','유리','티세트','커피','홈세트','트레이','매트','키친웨어','패브릭','소품']
		@purpose_list = ['한식','양식','면','혼밥','술','홈카페','디저트','홈파티','어린이','신혼','선물','조리']
		@category_list = @category_list+@purpose_list
		@style_list = ['럭셔리','로맨틱','클래식','유니크','엔틱','핸드메이드','일본','북유럽','폴란드','심플','모던','일러스트','귀여운','컬러풀','내츄럴']
    @color_hash = {"white"=>"#ffffff", "black"=>"#000000", "gray"=>"#999999", "brown"=>"#662200", "purple"=>"#b30086", "orange"=>"#ff9900", "mint"=>"#99ffdd", "green"=>"#00cc44", "blue"=>"#0000ff", "skyblue"=>"#99ddff", "glass"=>"url('/assets/glass.png')", "metal"=>"#f2f2f2", "gold"=>"url('/assets/gold.png')", "copper"=>"#cc9900", "mix"=>"url('/assets/mix.png')", "flower"=>"url('/assets/flower.png')", "stripe"=>"url('/assets/stripe.png')", "ivory"=>"#ffffcc", "khaki"=>"#666633", "beige"=>"#fffae6", "red"=>"#ff3300", "pink"=>"#ffb3ff", "wine"=>"#990033", "wood"=>"url('/assets/wood.png')", "yellow"=>"#ffff00"}
		prefer_tags = []
		prefer_product = []
		if tags.nil?&&session[:prefer_tags].nil?
			filter_tag = [@category_list.sample,@style_list.sample]
			session[:prefer] = filter_tag
			logger.info "2nil"
			logger.info filter_tag
    elsif tags.nil?
      filter_tag = session[:prefer_tags]
		elsif session[:prefer_tags].nil?
			filter_tag = eval(tags)
		end
		@prefer_tags = filter_tag

		Product.where("category like ? and hashtag like ?","%#{filter_tag[0]}%","%#{filter_tag[1]}%").each do |record|
			prefer_product.push(record)
		end


		session[:prefer_tags] = @prefer_tags
		logger.info session[:prefer_tags]
    logger.info prefer_product.size

		return prefer_product.uniq
	end


end
