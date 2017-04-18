class FrontController < ApplicationController

require 'browser'

#before_action :mobile_check, only:[:index]

	def index
		@head_tag = ["모던한","북유럽","브랜드","핸드메이드","일본식","귀여운","클래식","한식"]
    @merchant= Merchant.all.order('ranknumber ASC')
	end

	def table
		@merchants = Merchants.all
	end

	def pcindex

	end

	def section_load
		menu = params[:menu]
		case menu
			when "shop"
				shoplist(nil)
				render partial: "front/browse/contents-frame"
			when "product"
				productlist(nil)
				render partial: "front/items/contents-frame"
			when "like"
				likelist(nil)
				render partial: "front/items/contents"
			when "etc"
				render text: "not yet"
		end
	end

	def contents_reload
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
				if params[:id].nil?
					@product = Product.all
				else
					input_tags = params[:id].split(',')
					input_tags.shift #destroy first one
					logger.info input_tags
					@product = []
					input_tags.each do |tag|
						@product = @product + Product.where("category like ?","%#{tag}%")
					end
					@product = @product.uniq
				end

				productlist(@product)
				logger.info @product1
				render partial: "front/items/contents", layout: false
		end

	end

	def shop_product
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
		slide_type = params[:slide]
		index = params[:index]
		page = params[:page].to_i

		if slide_type =="shop"	#샵이 불리면 그냥 샵리스트를 불러주고 추가적인 처리는 contents reload메소드에서
			render partial:"front/browse/contents", layout:false
		elsif slide_type =="item"	#아이템이 불리면 인풋되는 인덱스/페이지에 따라서 아이템을 호출해서 렌더로 던져준다
			start_number = page*25
			if index=="index"
				@product = Product.all
			else
				@product = Product.where("category like ?","%#{index}%") #추후 인덱스에 맞는것만 불러오게 수정
			end
			@records = (start_number..start_number+24).to_a.map{|x|@product[x]}

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
				render text: "nil"
			else
				render partial:"front/items/contents", layout:false
			end
		end

	end

	def bridge

		input = params[:id]
		@record = Merchant.find(input.to_i)
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

	def shoplist(record)
		@head_tag = ["모던한","북유럽","브랜드","핸드메이드","일본식","귀여운","클래식","한식"]
		if record.nil?
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
		return @merchant
	end

	def productlist(record)
    @head_tag = ["머그","우드트레이","볼","플레이트","커트러리","소품","티세트","밥국그릇"]
    if record.nil?
      @product = Product.all
		else
			@product = record
		end
		logger.info @product
		start_number = 0
		prolong_number = 19
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
		@records = [Product.first]
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



end
