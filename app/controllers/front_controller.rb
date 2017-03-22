class FrontController < ApplicationController

require 'browser'

#before_action :mobile_check, only:[:index]

	def index
		@head_tag = ["모던한","북유럽","폴란드","핸드메이드","일본식","귀여운","클래식","한식"]
		@merchant= Merchant.all

	end

	def table
		@merchants = Merchants.all
	end

	def pcindex

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
