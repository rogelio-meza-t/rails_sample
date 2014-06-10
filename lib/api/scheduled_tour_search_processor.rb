require 'api/processor'

module Api
  
  class ScheduledToursSearchRequest < ApiRequest
    
    def required_params
      #['first_date']
    end

    def error_message
      return "You must provide these parameters: #{required_params.to_sentence}." unless complete?
      return "Your date is incorrectly formatted." if (@params['last_date_inclusive'].nil?)
      return "Your dates are incorrectly formatted."
    end

    def valid?
      #super && parseable?('first_date')
      true
    end

    def params_for_fetch
      
      if @params['first_date']
        first_requested_date = parse('first_date')
      end
      
      if @params['last_date_inclusive']
        last_requested_date = parse('last_date_inclusive')
      else
         last_requested_date = first_requested_date
      end
     
      # wrap it in an array to make it compatible with all of the splatting it goes through
      [first_requested_date..last_requested_date]
      # Note that it is harmless if the last date is now before the first date.
      
    end

    private

    def parseable?(which)
      parse(which)
    rescue Exception
      false
    end

    def parse(which)
      Date.parse(@params[which])
    end
    
  end

  class ScheduledToursEmbedSearchRequest < ScheduledToursSearchRequest
    attr_accessor :to
    
    def initialize(request_parameters, sales_channel)
      
      super(request_parameters, sales_channel)
      @tour_operator = TourOperator.find_by_guid(@params['toguid'])
      puts "initializing #{@tour_operator}"
    end
    
    def required_params
      super << "toguid"
    end
    
    def error_message
      return I18n.t("embed.index.not_configured") unless @tour_operator.configured_for_iframe?
      return super
    end
    
    def valid?
      super && @tour_operator.configured_for_iframe?
    end
      
    def params_for_fetch
      params_from_super = super
      return params_from_super, @tour_operator
    end
  end
  
  class ScheduledToursSalesEmbedSearchRequest < ScheduledToursSearchRequest
    
    def required_params
      super << "scguid"
    end
    
    def error_message
      return I18n.t("embed.index.not_configured") unless @sales_channel.configured_for_iframe?
      return super
    end
    
    def valid?
      super && @sales_channel.configured_for_iframe?
    end
    
    def params_for_fetch
      params_from_super = super
      return params_from_super, @params['categories']
    end
    
  end
  
  class ScheduledToursSearchProcessor < ApiProcessorEmbed
    
    include DateTimeHelper
    include CurrencyHelper

    def initialize(listener, callbacks, exhibit=nil)
      super(listener, callbacks)
      @exhibit = exhibit || ScheduledTourSearchJsonExhibit.new
    end

    attr_writer :exhibit

    def result(request)
      @request = request
      result_from_tours(call_back(:model_objects, *request.params_for_fetch))
    end

    def result_from_tours(tours)
      retval = @exhibit.prepare(filtered_tours_for_search(tours))
    end

    private

    def filtered_tours_for_search(tours)
      grouped_tours = tours_used_by_policy(tours).group_by(&:tour_operator)
      policy_allowed_tours = grouped_tours.keys
        .select{ |t| t.active? }
        .select{ |t| @request.sales_channel.nil? or
                       @request.sales_channel.agreement_exempt? or
                       t.has_agreement_binding_with?(@request.sales_channel)}
        .flat_map do | tour_operator |
          ScheduledTourAvailabilityPolicy.for(tour_operator).filter(grouped_tours[tour_operator])
      end
      tours_worth_returning(policy_allowed_tours)
    end

    def tours_used_by_policy(tours)
      tours.reject(&:cancelled)      
    end

    def tours_worth_returning(tours)
      tours.reject(&:full?).reject(&:on_the_fly?)
    end
  end
end


  
