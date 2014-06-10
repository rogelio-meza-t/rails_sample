module Api
  class ReservationsController < ApiController

    def create
      processor = ReservationProcessor.new(self, success: :successfully_reserved,
                                                 invalid_request: :invalid_reservation_request,
                                                 log_success: :log_success,
                                                 log_invalid_request: :log_invalid_reservation_request)
      processor.process(ReservationRequest.new(params, current_sales_channel))
    rescue
      render status: 500, json: {reservation:{error: 'There has been an unexpected error'}}
    end

    def successfully_reserved(reservation)
      # make this delayed via SalesChannelMailer.delayed...
      SalesChannelMailer.new_reservation(current_sales_channel, reservation).deliver
      TourOperatorMailer.new_reservation(current_sales_channel, reservation).deliver
      render json: {reservation: {confirmation_number: reservation.reference, date: reservation.scheduled_tour.date}}
    end

    def invalid_reservation_request(error_message)
      render status: 406, json: { reservation: {error: error_message } }
    end
    
    # This isn't entirely needed, but for consistency
    def log_success(reservation)
      RequestLog.create(key: 'api_reservation_success', sales_channel: current_sales_channel, url: request.fullpath, value: reservation.reference)
    end
    
    def log_invalid_reservation_request(error_message)
      RequestLog.create(key: 'api_reservation_error', sales_channel: current_sales_channel, url: request.fullpath, value: error_message)
    end
  end
  
  
end
