class FrontController < ApplicationController

require 'browser'
require 'nokogiri'
require 'open-uri'

before_action :mobile_check, only:[:index]

	def index
		@test = params[:test]
		@isApp = params[:isApp].to_i
		@uuid = params[:uuid]
		if !@uuid.nil?
			sign_in(Identity.where(:uid=>@uuid).take.user, scope: :user)
    end
		if @isApp==1&&!current_user.nil?
			@c_uuid = current_user.id
		end
		logger.info @isApp
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
		productlist(index_product,nil,nil)
    userlikelist(current_user)
    logger.info @prefer_tags
	end

	def table
		@merchants = Merchants.all
	end

	def pcindex

	end

	def like_status
    # parameter
		# request_type  : inquiry / modify
		# id user_id : int
		# type : product / shop

		id = params[:id].to_i
		request_type = params[:request_type]
		type = params[:type]
		user_id = params[:user_id].to_i
		output = {}

		#타입에 따라 id로 input을 호출하고 user_id와 함께 status를 확인, record를 선택하거나 생성한다
		if type == "product"
			input = Product.find(id)
			status_record = Userlikeitem.where("user_id=? and product_id=?",user_id,id).first_or_create
		elsif type=="shop"
			input = Merchant.find(id)
			status_record = Userlikeshop.where("user_id=? and product_id=?",user_id,id).first_or_create
		end

    #nil이라면 false로 바꿔서 업데이트
    if status_record.active == nil
			status_record.update(:active=>false)
		end

		#status를 변경하는 request라면 status 에다 not 한 값을 추가하고 save
		if request_type == "modify"
			status_record.update(:active=>!status_record.active) #nil이나 false 라면 true로 바뀐다
		end

		status = status_record.active

		output = {:type=>type, :status=>status}

		render json: output
	end

	def search_toggle
    type = params[:type]
		if type == "item"
      if params[:toggle]=="1"
      render partial: "front/items/item_search"
      else
      @prefer_tags = session[:prefer_style]+session[:prefer_category]
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

		@records = Product.where("title like ? or category like ? or hashtag like ? or id=?","%#{keyword}%","%#{keyword}%","%#{keyword}%",keyword.to_i).order(rating: :desc)
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
        @prefer_tags = session[:prefer_style]+session[:prefer_category]
				productlist(call_products,nil,nil)
				render partial: "front/items/contents-frame"
			when "likeitem"
				likelist(current_user)
				render partial: "front/likelist/contents-item-frame"
			when "home"
				@render_hash = {}

				Promotion.all.each do |record|
					@render_hash[record] = record.products.order(rating: :asc).last(2)
				end
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
		productlist(rcmd_product.uniq,nil,nil)
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
				@product = Product.where(:id=>nil)
        session[:prefer_category] = params[:id].split(',')
        session[:prefer_style] = params[:hashtag].gsub('undefined','').split(',')
				session[:color] = params[:color]
				hashtag = params[:hashtag].gsub('undefined','').split(',').reject{|c|c.empty?}[0]
        logger.info session[:prefer_style]
				logger.info params[:id].empty?
				logger.info "where"
        if params[:color].nil?
					input_color = session[:color].split(',').map{|x|"%#{x}%"}
				else
					input_color = params[:color].split(',').map{|x|"%#{x}%"}
				end
				if params[:id].nil?||params[:hashtag].nil?
          prefer_scenario(nil)
				elsif params[:hashtag].nil?
					input_tags = params[:id].split(',')
					input_tags.shift #destroy first one
					logger.info input_tags
					@product =[]
					input_tags.each do |tag|
						@product = @product + Product.where("category like ?","%#{tag}%").order(rating: :desc)
					end
					@product = @product.uniq
				elsif params[:id].empty?
					logger.info "hello!~"
					@product = Product.where("hashtag like ?","%#{hashtag}%").order(rating: :desc)
				else
					input_category = params[:id].split(',').map{|x|"%"+x+"%"}
					logger.info input_category

					input_category.each do |category|
						@product = @product.or(Product.where("hashtag like ? and category like ?","%#{hashtag}%",category))
					end

					@product =@product.order(rating: :desc)
				end
				product_with_color = []

				input_color.each do |color|
					product_with_color.push(@product.where("color like ?",color))
				end

				if product_with_color.empty?

				else
					@product = product_with_color.inject{|sum,x|sum+x}
				end

				productlist(@product.uniq,params[:sort_type],params[:sort_value])
				tags = params[:id].split(',').push(hashtag)
				@prefer_tags = tags
        logger.info @product.size


				render partial: "front/items/contents-frame", layout: false
		end

	end

	def product_sort
		mother_list = prefer_scenario(nil)
		userlikelist(current_user)
		productlist(mother_list,params[:sort_type],params[:sort_value])
		render partial: "front/items/contents", layout:false
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

	def promo_popup
		@input_record = Promotion.find(params[:id].to_i)
		productlist(@input_record.products,nil,nil)
    userlikelist(current_user)

    render partial:"front/modal/promotion",layout:false
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
		index = params[:index].gsub('index','').split(',')
    hashtag = params[:hashtag].gsub('undefined','').split(',').reject{|c|c.empty?}[0]
    if session[:color].nil?
			session[:color]=""
		end
		input_color = session[:color].split(',').map{|x|"%#{x}%"}
		page = params[:page].to_i
    product_with_color = []
    logger.info "slidecontents"
		logger.info hashtag
		logger.info index

		if slide_type =="shop"	#샵이 불리면 그냥 샵리스트를 불러주고 추가적인 처리는 contents reload메소드에서
			render partial:"front/browse/contents", layout:false
		elsif slide_type =="item"	#아이템이 불리면 인풋되는 인덱스/페이지에 따라서 아이템을 호출해서 렌더로 던져준다
			start_number = page*24
			if index.empty? && hashtag.nil?
				if current_user.nil?||current_user.prefer.nil?
					prefer_tag = nil
				else
					prefer_tag = current_user.prefer
				end
				@product = prefer_scenario(prefer_tag)
				logger.info @product.size
				logger.info "heeh"
			else
				@product = Product.where(:id=>0)
				index = index.map{|x|x.gsub('index','')}
				logger.info hashtag
				index.each do |category|
					@product = @product.or(Product.where("category like ? and hashtag like ?","%#{category}%","%#{hashtag}%"))
				end
				logger.info @product.size
				@product = @product.uniq.order(rating: :desc)
			end

			product_with_color = []

			input_color.each do |color|
				product_with_color.push(@product.where("color like ?",color))
			end

			if product_with_color.empty?

			else
				@product = product_with_color.inject{|sum,x|sum+x}
			end

			logger.info params[:sort_type]
      logger.info @product.size
			case params[:sort_type]
				when 'price'
					@product = @product.uniq.order("#{params[:sort_type]}":"#{params[:sort_value]}")
				when 'rating'
					@product = @product.uniq.order("#{params[:sort_type]}":"#{params[:sort_value]}")
				else
					@product = @product.uniq.order(rating: :desc)
			end
			logger.info start_number
			@records = (start_number..start_number+23).to_a.map{|x|@product[x]}.compact
			logger.info @records.compact.size
			logger.info @records.inspect
      if @records.compact.size != 0
				@records = Product.where(id: @records.map(&:id))
    	  productlist(@records,params[:sort_type],params[:sort_value])
				render partial:"front/items/contents", layout:false
      else
				render plain: "nil"
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

	def db_spider


	end

	def db_spider_result

		mainpage = params[:mainpage]
		category_list = params[:category]
		album_css = params[:album_css]
		product_title = params[:product_title]
		product_img = params[:product_img]
		product_price = params[:product_price]
		product_url = params[:product_url]
		encoding = params[:encoding]
		check = params[:check]
		dummy = params[:dummy]
		if dummy.nil?||dummy.empty?
			dummy = "dummy"
		end
		output = ""
		url_hash = {}
    page_array = []
		page_array_before = []
		url_hash_array = []
		toggle_odd = false
		pair_url = ""
		category_list.each do |url| #카테고리는 짝지어 들어온다
			if toggle_odd #파라미터 / 주소 부분을 분리하기 위한 홀짝 토글


				pms = url.split("&") #짝수 부분의 파라미터를 쪼개어 배열화
				pms.each_with_index do |pm,i| #페이지 넘버가 들어가는 부분은 제거하여 동적으로 따로 구성한다
					if pm.include?"page"
						pms.delete_at(i)
					end
				end

				page = 1 #페이지의 시작 번호, 1부터
				links = []

				while true #노코기리에서 긁어오는 결과값이 없어질때까지 루프를 돌린다

					page_url = pair_url + pms.join("&")+"&page="+page.to_s #기본 주소와 파라미터를 다시 조립한다
          logger.info page_url
					logger.info "에서 긁어옵니다"

					if encoding == "euc-kr"
						data = Nokogiri::HTML(open(page_url),nil,'euc-kr') #노코기리로 해당 url 데이터를 얻는다
					else
						data = Nokogiri::HTML(open(page_url)) #노코기리로 해당 url 데이터를 얻는다
					end

					album_items = data.css(album_css) #입력된 css 위치에 존재하는 item들을 모두 가져온다
          logger.info album_items.size
					logger.info 'mothjer'

					if album_items.empty? #item이 비어있다면 반복문을 종료한다
						break;
					end

					if check=="album"
						output = album_items[0]
						break
					elsif check=="hello"
						break
          end

					page_array_before = page_array #과거 값을 저장하고 초기화
					page_array = []
					album_items.each do |item| #해당 아이템들로부터 href attribute에 있는 link를 추출

						logger.info item
						logger.info "item ds"
						logger.info product_url
						link = item.css(product_url).attr('href')
						logger.info link.value

            http_check = mainpage.split('/') + link.value.split('/')
						link =http_check.uniq.join('/')

						item_title = item.css(product_title).text.gsub("\n","")
						item_new_whole = item.to_s.split("\"")
            logger.info item_new_whole
						item_img = item_new_whole[item_new_whole.index{|x|(x.include?("jpg")||x.include?("png"))&&!x.include?("#{dummy}")}]
						# item_img = item_new_whole.select{|x|x.include?"png"}.reject{|x|x.include?dummy}
						logger.info item_img
						if !item_img.include?'//'
							item_img = mainpage+item_img
						end
						item_price = item.css(product_price).text

            url_hash = {title:item_title, price:item_price, url:link, img:item_img}

						page_array.push(url_hash)	#새로운 값을 저장
						url_hash_array.push(url_hash)

            if check=="all"
							check = "hello"
              output = "링크:#{link} <br> 이름:#{item_title} <br> 가격:#{item_price} <br> 이미지:#{item_img}"
              break
						end
					end

					if page_array.pluck(:url) == page_array_before.pluck(:url)
						check = "hello"
					end
					page = page+1 #다음 페이지 탐색을 위해 페이지를 1 증가
				end


				toggle_odd = false
			else
				pair_url = url

				toggle_odd = true
			end

		end

		logger.info "result"
		logger.info url_hash_array.inspect
		@result = url_hash_array.uniq
		if output == ""
			render layout:false
		else
			render plain: output
		end

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

	def productlist(record,sort_type,sort_value)
    @head_tag = ["우드트레이","볼","플레이트","커트러리","홈세트","머그","소품","매트"]
    if record.nil?
      @product = Product.all
		elsif record.is_a?(Array)
			@product = Product.where(id: record.map(&:id))
		else
			@product = record
		end

		case sort_type
			when "rating"
				@product = @product.order("#{sort_type}":"#{sort_value}")
			when 'price'
				@product = @product.order("#{sort_type}":"#{sort_value}")
			when 'range'
				price_range = sort_value.split(',').map{|x|x.to_i}
        @product = @product.where("price >=? and price<=?",price_range[0],price_range[1])
      else
        @product = @product.order(rating: :desc)
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
		@product = Product.where(:id=>0)
		prefer_tags = []
		prefer_product = []
		if session[:prefer_style].nil?&&session[:prefer_category].nil?
			session[:prefer_style] = [@style_list.sample]
			session[:prefer_category] = [@category_list.sample]
			logger.info "2nil"
		end


    logger.info session[:prefer_category]
		logger.info session[:prefer_style]
		@prefer_tags = session[:prefer_category]+session[:prefer_style]


		session[:prefer_category].each do |category|
			@product = @product.or(Product.where("hashtag like ? and category like ? and color like ?","%#{session[:prefer_style][0]}%","%#{category}%","%#{session[:color]}%"))
		end
		if session[:prefer_category].empty?
			@product = Product.where("hashtag like ? and color like ?","%#{session[:prefer_style][0]}%","%#{session[:color]}%").order(rating: :desc)
		end


		prefer_product = @product
    logger.info prefer_product.size


		return prefer_product.uniq
	end


end
