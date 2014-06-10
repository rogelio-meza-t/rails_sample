# -*- coding: utf-8 -*-
class ReservationMailer < ActionMailer::Base

  layout 'common_mailer'
  
  helper :date_time
  
  default :from => "Kuotus Team <info@kuotus.com>"
  
  def new_embed_reservation(reservation, currency, tickets)
    Rails.logger.info "new reservation #{I18n.locale}"
    @reservation = reservation
    @currency = currency
    @tickets_parsed = tickets
    @supress_footer = true
    mail(:from => "#{reservation.scheduled_tour.product.tour_operator.name} <#{reservation.scheduled_tour.product.tour_operator.email}>", 
         :reply_to => reservation.scheduled_tour.product.tour_operator.email,
         :to => reservation.email, 
         :subject => I18n.t('reservation_mailer.new_embed_reservation.subject', :operator_name => reservation.scheduled_tour.product.tour_operator.name))
  
  end
  
  def on_paypal_failure(reservation, message, tickets)
    @reservation = reservation
    @mes = message
    @tickets_parsed = tickets
    Rails.logger.info "Paypal reservation failure: #{message}"
    mail( :to => "Kuotus Team <info@kuotus.com>",
          :reply_to => reservation.scheduled_tour.product.tour_operator.email,
          :subject => "Paypal reservation failure")
  end
end