require 'set'

module Api

  class ApiRequest
    attr_reader :sales_channel
    
    def initialize(request_parameters, sales_channel)
      
      @params, @sales_channel = request_parameters, sales_channel
    end

    def required_params; subclass_must_implement; end
    def valid?; complete?; end
    def error_message; subclass_must_implement; end

    private

    def complete?
      required = required_params.to_set
      actual = @params.keys.to_set
      actual.superset?(required)
    end
  end

  class ApiProcessor
    def initialize(listener, callbacks = {})
      @listener = listener
      @callbacks = callbacks
    end

    def process(request)
      if request.valid?
        success(request)
      else
        invalid_request(request)
      end
    end

    protected

    def result(request)
      subclass_must_implement
    end

    def success(request)
      res = result(request)
      call_back(:log_success, res)
      call_back(:success, res)
    end
    
    def invalid_request(request)
      call_back(:log_invalid_request, request.error_message)
      call_back(:invalid_request, request.error_message)
    end
    
    def call_back(message, *args)
      @listener.send(@callbacks[message], args)
    end
    
  end
  
  
  class ApiProcessorEmbed
    def initialize(listener, callbacks = {})
      @listener = listener
      @callbacks = callbacks
    end

    def process(request)
      if request.valid?
        success(request)
      else
        invalid_request(request)
      end
    end

    protected

    def result(request)
      subclass_must_implement
    end

    def success(request)
      res = result(request)
      call_back(:log_success, res)
      call_back(:success, res)
    end
    
    def invalid_request(request)
      call_back(:log_invalid_request, request.error_message)
      call_back(:invalid_request, request.error_message)
    end
    
    def call_back(message, *args)
      @listener.send(@callbacks[message], *args)
    end
 
  end
  
end
