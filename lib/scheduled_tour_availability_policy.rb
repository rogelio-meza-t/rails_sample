module ScheduledTourAvailabilityPolicy
  def self.for(tour_operator)
    policy, policy_params = operator_policy(tour_operator)
    send(policy, policy_params)
  end

  def self.all_tours_are_available(ignored)
    NoTourConflicts
  end

  def self.only_n_simultaneous_tours(params)
    OnlyNSimultaneousTours.new(params["n"])
  end

  class NoTourConflicts
    def self.filter(tours)
      tours
    end

    def self.allows_new_tour?(existing_tours, time_range)
      true
    end

    def self.would_be_within_simultaneous_tour_limit?(target_tour)
      true
    end

    def self.must_be_within_simultaneous_tour_limit(target_tour)
      Success(true)
    end

  end

  class OnlyNSimultaneousTours < Struct.new(:n)
    include DateTimeWrangler

    def filter(tours)
      tours.reject!{|tour| !in_reservation_time?(tour)}
      tours.reject!{|tour| !would_be_within_simultaneous_tour_limit?(tour)}

      partition_by_date(tours).flat_map do | one_days_worth | 
        filter_one_days_worth(one_days_worth)
      end
    end

    def self.allows_new_tour?(all_existing_tours, time_range)
      !time_ranges_exclude?(disallowed_times(all_existing_tours), time_range)
    end

    def would_be_within_simultaneous_tour_limit?(tour_to_be_reserved)
      return true if tour_to_be_reserved.has_reservations? or tour_to_be_reserved.exempt_from_schedule_policy?
      bad_times = disallowed_times(tour_to_be_reserved.date_family)
      !time_ranges_exclude?(bad_times, tour_to_be_reserved.time_range)
    end

    def must_be_within_simultaneous_tour_limit(tour_to_be_reserved)
      Either(would_be_within_simultaneous_tour_limit?(tour_to_be_reserved)).or(
         error: I18n.t("tour_operator.on_the_fly_tour.too_many_reservations")
      )
    end

    def in_reservation_time?(scheduled_tour)
      datetime_reservation = DateTime.now.in_time_zone(scheduled_tour.tour_operator.time_zone)
      last_time_to_reservation = DateTime.new(scheduled_tour.date.year, scheduled_tour.date.month, scheduled_tour.date.day, scheduled_tour.product_schedule.start_time.hour, scheduled_tour.product_schedule.start_time.min)
      last_time_to_reservation = last_time_to_reservation.change(:offset => last_time_to_reservation.in_time_zone(scheduled_tour.tour_operator.time_zone).formatted_offset)
      last_time_to_reservation = last_time_to_reservation - scheduled_tour.product.min_api_reservation_hours.hours
      last_time_to_reservation > datetime_reservation.to_datetime
    end
      
    def filter_one_days_worth(day_tours)
      # partition by always_allow, include always_allow in returned values
      always_allow, needs_rules = day_tours.partition(&:exempt_from_schedule_policy?)
      with_reservations, without_reservations = needs_rules.partition(&:has_reservations?)
      booked_ranges = fully_booked_times_of_the_day(with_reservations)
      always_allow + with_reservations + time_containers_allowed_by(without_reservations, booked_ranges)
    end

    def fully_booked_times_of_the_day(tours)
      n_way_overlaps(self.n, tours).collect do | overlap |
        time_range_intersection(overlap)
      end
    end

    private

    def disallowed_times(all_existing_tours)
      fully_booked_times_of_the_day(only_reserved(all_existing_tours))
    end

    def only_reserved(tours)
      tours.find_all(&:has_reservations?)
    end

  end


  private

  def self.operator_policy(tour_operator)
    stored_policy = tour_operator.scheduled_tour_availability_policy || :all_tours_are_available
    stored_params = tour_operator.scheduled_tour_availability_policy_parameters || "{}"
    [stored_policy, JSON.parse(stored_params)]
  end
end
