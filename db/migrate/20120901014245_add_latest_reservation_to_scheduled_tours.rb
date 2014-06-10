class AddLatestReservationToScheduledTours < ActiveRecord::Migration
  def up
    add_column :scheduled_tours, :latest_api_reservation, :datetime
    
    ScheduledTour.all.each do |st|
      datetime_of_tour = DateTime.new(st.date.year, st.date.month, st.date.day, 
      st.product.start_time.hour,
      st.product.start_time.min)
      datetime_of_tour = datetime_of_tour.
        change(:offset => datetime_of_tour.in_time_zone('Santiago').formatted_offset)

      latest_reservation = datetime_of_tour - st.product.min_api_reservation_hours.hours
        
      st.latest_api_reservation = latest_reservation
      st.save
    end
  end
  
  def down
    remove_column :scheduled_tours, :latest_api_reservation
  end
end
