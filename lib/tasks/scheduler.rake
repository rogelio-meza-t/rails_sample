task :send_reminders => :environment do
    TourOperator.send_daily_emails
end

task :delete_unpaid_reservations => :environment do
    Reservation.delete_unpaid_reservations
end