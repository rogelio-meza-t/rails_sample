
module Api
  class ProductsController < ApiController
    require 'api/product_search_processor'
    def outer_level_key; :search_results; end

    def search

      callbacks = {
        success: :render_success,
        invalid_request: :render_invalid_request,
        model_objects: :fetch_tours,
        log_success: :log_success,
        log_invalid_request: :log_invalid_request
      }
      ProductsSearchProcessor.new(self, callbacks).
            process(ProductsSearchRequest.new(params, current_sales_channel))
    end

    def fetch_tours(date_range)
      Product.all
      #Product.in_date_range(date_range)
    end
    
    def log_success(result)
      RequestLog.create(key: 'api_search_success', sales_channel: current_sales_channel, url: request.fullpath, value: result.length)
    end
    
    def log_invalid_request(error_message)
      RequestLog.create(key: 'api_search_error', sales_channel: current_sales_channel, url: request.fullpath, value: error_message)
    end
  end
end
