module Api
  class ApiController < ApplicationController
    before_filter :check_api_key!
    after_filter  ->{ reset_session }

    private

    def check_api_key!
      render invalid_key unless sales_channel_signed_in?
    end

    def invalid_key
      { status: 401, json: { error: 'Provided API key is not valid' } }
    end

    def outer_level_key; subclass_must_implement; end 

    def render_success(jsonifiable)
      wrapped = wrap(jsonifiable)
      render json: wrapped
    end

    def render_invalid_request(error_message)
      render status: 406, json: wrap(error: error_message) 
    end

    private

    def wrap(hash)
      { outer_level_key => hash }
    end
  end
end
