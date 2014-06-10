# -*- coding: utf-8 -*-
class TourOperatorMailer < ActionMailer::Base

  layout 'common_mailer'
  
  helper :date_time
  
  default :from => "Kuotus Team <info@kuotus.com>"
  
  def daily_reminder(operator)
    @operator = operator
    @tomorrow = Date.today.tomorrow
    @tours = operator.tours_on(Date.today.tomorrow).find_all{|item| item.reservations.size > 0}
    mail(:to => operator.email, :subject => "Tu calendario Kuotus para mañana")
  end
  
  def new_reservation(sales_channel, reservation)
    Rails.logger.info "new reservation #{I18n.locale}"
    @channel = sales_channel
    @reservation = reservation
    @title = I18n.t('mail.new_reservation.title')
    mail(:to => reservation.scheduled_tour.product.tour_operator.email, :subject => I18n.t('mail.new_reservation.subject', :reservation_id => reservation.reference))
  end
  
  def new_embed_reservation(reservation, currency, tickets)
    Rails.logger.info "new embed reservation #{I18n.locale}"
    @reservation = reservation
    @currency = currency
    @tickets = tickets
    @title = I18n.t('mail.new_reservation.title')
    mail(:to => reservation.scheduled_tour.product.tour_operator.email, :subject => I18n.t('mail.new_reservation.subject', :reservation_id => reservation.reference))
  end
end