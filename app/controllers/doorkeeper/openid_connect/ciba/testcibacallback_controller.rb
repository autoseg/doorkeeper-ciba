# frozen_string_literal: true

module Doorkeeper
  module OpenidConnect
  	module Ciba
		# controller for /backchannel/authorize
	    class TestcibacallbackController < ::ApplicationController

		# JUST TO TEST / DEBUG THE CIBA CALLBACK
	    def testcibacallback
			
			::Rails.logger.info("\n##### testcibacallback BEGIN ####################################")
			::Rails.logger.info("##### HEADERS ###################################################")
			::Rails.logger.info(request.headers.to_h.select { |k,v|
					  ['HTTP','CONTENT','AUTHORIZATION'].any? { |s| k.to_s.starts_with? s }
					}.to_s)
			::Rails.logger.info("##### HEADERS ###################################################")
			
			::Rails.logger.info("##### PARAMS ####################################################")
			::Rails.logger.info(params.to_s)
			::Rails.logger.info("##### PARAMS ####################################################")
			
			::Rails.logger.info("##### BODY ######################################################")
			::Rails.logger.info(request.body.read)
			::Rails.logger.info("##### BODY ######################################################")
			
			::Rails.logger.info("##### testcibacallback END ######################################\n")

			render json: {'test': 'ok'}, status:200
	    end
	  end
	end
  end
end









