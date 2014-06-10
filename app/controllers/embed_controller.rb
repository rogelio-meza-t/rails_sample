
class EmbedController < ApplicationController
  require 'api/scheduled_tour_search_processor'
  layout "iframe"

  # TODO
  # - provide better messaging for errors
  # - delete reservation if window closed and not paid?
  # - style form error messages
  # - add place of stay to form?
  # - add helper text to form inputs?
  # - Hide Kuotus in user reservation email
  # - make paypal a chained payment
  # - Fix long title issues
  # - research paypal refunds
  # - send emails from tour provider info
  # - remove price column
  
  before_filter :set_p3p, :set_values, :set_locale, :set_currency
  
  def set_values
    session[:search_url] = "/embed/?toguid=" + request[:toguid].to_s if session[:seach_url].to_s.eql? ''
    
    @guid = request[:toguid]
  end
  
  def set_currency
    if not session[:currency]
      session[:currency] = ProductPrice.valid_paypal_currency?(params[:currency]) ? params[:currency] : "USD"     
    else
      session[:currency] = ProductPrice.valid_paypal_currency?(params[:currency]) ? params[:currency] : session[:currency]
    end    
    @currency = session[:currency]
  end
  
  def set_locale
    if not session[:locale]
      I18n.locale = params[:locale] || I18n.default_locale
      session[:locale] = I18n.locale
      @locale = I18n.locale
    else
      I18n.locale = params[:locale] || session[:locale]
      session[:locale] = I18n.locale
      @locale = I18n.locale
    end
  end

  def set_p3p  
    headers['P3P'] = 'CP="ALL DSP COR CURa ADMa DEVa OUR IND COM NAV"'  
  end 
  
  def set_buy_currency(tour)
    valid_currency = true
    session.delete(:default_currency)
    tour.price_descriptions.each do |pd|
      a = pd.product_prices.map{|v| v[:currency_code]}
      if !a.include? session[:currency]
        session[:default_currency] = session[:currency]
        session[:currency] = 'USD'
        @currency = session[:currency]
        break
      end
    end
  end
  
  def index
    callbacks = {
      success: :render_success,
      invalid_request: :render_invalid_request,
      model_objects: :fetch_tours,
      log_success: :log_success,
      log_invalid_request: :log_invalid_request
    }
    Api::ProductsSearchProcessor.new(self, callbacks, Api::ProductSearchModelExhibit.new).
          process(Api::ProductsEmbedSearchRequest.new(@guid))
  end

  def fetch_tours(foo)
    Product.owned_by_tour_operator(@guid)
  end
  
  def apply_filter
  
  end
  
  def render_invalid_request(error_message)
    flash.now[:notice] = error_message
    render "index"
  end

  def render_invalid_request_show(error_message)
    flash.now[:notice] = error_message
    render "index"
  end
  
  def render_success(tours)
    @tours_by_priority = tours.flatten!
      .reject(&:missing_translation?)
      .reject(&:missing_usd_price?)
    render "index"
  end
  
  def log_success(result)
    puts "Successful Embed Request #{result.length}"
    #RequestLog.create(key: 'api_search_success', sales_channel: current_sales_channel, url: request.fullpath, value: result.length)
  end
  def log_success_show(result)
    puts "Successful ScheduledTour Request #{result.length}"
    #RequestLog.create(key: 'api_search_success', sales_channel: current_sales_channel, url: request.fullpath, value: result.length)
  end
  
  def log_invalid_request(error_message)
    puts "Invalid Embed Request #{error_message}"
    #RequestLog.create(key: 'api_search_error', sales_channel: current_sales_channel, url: request.fullpath, value: error_message)
  end

  def log_invalid_request_show(error_message)
    puts "Invalid ScheduledTour Request #{error_message}"
    #RequestLog.create(key: 'api_search_error', sales_channel: current_sales_channel, url: request.fullpath, value: error_message)
  end
  
  def new_reservation
    require 'uuidtools'
    @tour = ScheduledTour.all_of(TourOperator.where("guid = ?", params[:toguid]).first)
              .find(params[:id])
      
    @tickets_parsed = params['tickets'].split(',').each.map{|t| t.split(':')}
    @tickets = params['tickets']
    @rez = Reservation.new
    @rez.scheduled_tour = @tour
    @rez.guid = UUIDTools::UUID.timestamp_create().to_s
    
    @total = @rez.total_price(@tickets_parsed, @currency)

    @number_of_people = params[:people]
    session[:location] = "embed"
    session[:guid] = request[:toguid]
  end
  
  def edit_reservation
    @tickets_parsed = params['tickets'].split(',').each.map{|t| t.split(':')}
    @tickets = params['tickets']
    
    @rez = Reservation.find_by_guid(params[:guid])
    @tour = @rez.scheduled_tour   
    @number_of_people = params[:people]
    render :action => 'new_reservation'
  end
  
  def update_reservation
    @rez = Reservation.find_by_guid(params[:guid])
    @number_of_people = params[:people]
    @tickets_parsed = params['tickets'].split(',').each.map{|t| t.split(':')}
    @tickets = params['tickets']
    
    @tour = @rez.scheduled_tour
    if @rez.update_attributes(params[:reservation])    
      pay_response = request_paykey(@rez, @currency, @tickets_parsed)
      if pay_response.success?
        @rez.paykey = pay_response['payKey']
        @rez.save
        @payment_url = pay_response.approve_paypal_payment_url(:type => "mini")
        render :action => 'review_reservation'
      else
        puts "Bad Paypal response: #{pay_response}"
        ReservationMailer.on_paypal_failure(@rez, pay_response, @tickets_parsed).deliver 
        render :action => 'new_reservation'
      end
    else
      render :action => 'new_reservation'
    end
  end
  
  def create_reservation
    @number_of_people = params[:reservation][:number_of_people]
    @tickets_parsed = params['tickets'].split(',').each.map{|t| t.split(':')}
    @tickets = params['tickets']
    
    @toguid = params[:toguid]
    @tour = ScheduledTour.find(params[:id])
    if @tour.has_room_for?(params[:reservation][:number_of_people].to_i)
      
      params[:reservation][:phone] = (params[:phone_pre] || '')  + ' ' + (params[:reservation][:phone] || '')
      @rez = @tour.reservations.build(params[:reservation])
      #@rez = Reservation.new(params[:reservation])
      #@rez.scheduled_tour = ScheduledTour.find(@rez.scheduled_tour_id)
      @rez.paid = false
      
      if @rez.save
        pay_response = request_paykey(@rez, @currency, @tickets_parsed)    
        if pay_response.success?
          @rez.paykey = pay_response['payKey']
          @rez.save
          @payment_url = pay_response.approve_paypal_payment_url(:type => "mini")
          render :action => 'review_reservation'
    
        else
          puts "Bad Paypal response: #{pay_response}"
          ReservationMailer.on_paypal_failure(@rez, pay_response, @tickets_parsed).deliver
          flash[:notice] = t('embed.new_reservation.paypal_fail')
          render :action => 'new_reservation'
        end
      else
        render :action => 'new_reservation'
      end
    else
      @rez = @tour.reservations.build(params[:reservation])
      flash[:notice] = I18n.t("not_able_to_make_reservation")
      render :action => 'new_reservation'
      end
  end
  def show
    @selected_tour = Product.find_by_id(request[:pid])
    set_buy_currency(@selected_tour)
    @pid = request[:pid]

    callbacks = {
      success: :render_success_show,
      invalid_request: :render_invalid_request_show,
      model_objects: :fetch_tours_show,
      log_success: :log_success_show,
      log_invalid_request: :log_invalid_request_show
    }
    Api::ScheduledToursSearchProcessor.new(self, callbacks, Api::ScheduledTourSearchJsonExhibit.new).
          process(Api::ScheduledToursEmbedSearchRequest.new(params, nil))

  end

  def render_success_show(tours)
    @available_tours = tours
    render "show"
  end

  def fetch_tours_show(date_range, to)
    ScheduledTour.all.select{|st| st.product_id == @pid.to_i}
  end

  def complete
    @rez = Reservation.find_by_guid(params[:guid])
    @tickets_parsed = params['tickets'].split(',').each.map{|t| t.split(':')}
    @tickets = params['tickets']
  end
  
  def poll
    # find payment key by guid
    @tickets_parsed = params['tickets'].split(',').each.map{|t| t.split(':')}
    @tickets = params['tickets']
    rez = Reservation.find_by_guid(params[:guid])
    if rez.nil? 
      render :json => {'state' => 'error'}
    end
    
    detail_request = PaypalAdaptive::Request.new
    data = {
      'requestEnvelope' => {'errorLanguage' => 'en_US'},
      'payKey' => rez.paykey
    }
    detail_response = detail_request.payment_details(data)
    
    if detail_response['status'] == 'COMPLETED' and !rez.paid
      rez.paid = true
      rez.save
      TourOperatorMailer.new_embed_reservation(rez, @currency, @tickets_parsed).deliver
      ReservationMailer.new_embed_reservation(rez, @currency, @tickets_parsed).deliver
    end
    render :json => {'state' => detail_response['status']}
  end
  
  def ipn
    @tickets_parsed = params['tickets'].split(',').each.map{|t| t.split(':')}
    @tickets = params['tickets']
    rez = Reservation.find_by_paykey(params[:pay_key])
    if rez
      ipn = PaypalAdaptive::IpnNotification.new
      ipn.send_back(request.raw_post)
      
      if ipn.verified?
        if params[:status] == 'COMPLETE' and !rez.paid
          rez.paid = true
          rez.save
          # TODO this could potentially result in double email, need to queue emails and check if 
          # an entry already exists
          TourOperatorMailer.new_embed_reservation(rez, @currency, @tickets_parsed).deliver
          ReservationMailer.new_embed_reservation(rez, @currency, @tickets_parsed).deliver
        end
      end 
    end
    render nothing: true
  end
  
  # https://www.x.com/developers/paypal/documentation-tools/api/Pay-api-operation acceptable currency codes
  # sandbox account: dan_1349469084_per@kuotus.com:foobar123
  def request_paykey(rez, currency, tickets)
    
    total = rez.total_price(tickets, currency)    
    total = total.format(:symbol => false, :separator => ".", :delimiter => false)
    email = rez.scheduled_tour.product.tour_operator.paypal_email
    if email.blank?
      email = 'beatriz@kuotus.com'
    end
    pay_request = PaypalAdaptive::Request.new
    data = {
      'requestEnvelope' => {'errorLanguage' => 'en_US'},
      'currencyCode' => currency,
      'receiverList' =>
        { 'receiver' => [
          {'email' => email, 
           'amount' => total.to_s
          }
        ]},
      'actionType' => 'PAY',
      'returnUrl' => "#{root_url}embed/paid",
      'cancelUrl' => "#{root_url}embed/cancelled",
      'ipnNotificationUrl' => "#{root_url}embed/ipn"
      }
    # Use localtunnel 3000 if we need to do callbacks in dev
    pay_request.pay(data)   
  end
  
  def tandc
    @tour_operator = TourOperator.find_by_guid(params[:toguid])
    render :layout => false
  end

end
