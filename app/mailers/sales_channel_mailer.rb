# -*- coding: utf-8 -*-
class SalesChannelMailer < ActionMailer::Base
  
  layout 'common_mailer'
  
  helper :date_time

  default :from => "Kuotus Team <info@kuotus.com>"
  
  def new_reservation(sales_channel, reservation)
    Rails.logger.info "new reservation #{I18n.locale}"
    @channel = sales_channel
    @reservation = reservation
    @title = I18n.t('mail.new_reservation.title')
    mail(:to => sales_channel.contact_email, :subject => I18n.t('mail.new_reservation.subject', :reservation_id => reservation.reference))
  end
end