class FrontController < ApplicationController

require 'browser'

#before_action :mobile_check, only:[:index]

	def index
		@head_tag = ["모던한","북유럽","폴란드","핸드메이드","일본식","귀여운","클래식","한식"]
    @merchant= Merchant.all.order('ranknumber ASC')
	end

	def table
		@merchants = Merchants.all
	end

	def pcindex

	end

	def contents_reload
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
      render layout: false
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

end
