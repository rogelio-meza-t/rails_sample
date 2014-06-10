def operator_can_do_only_n_simultaneous_tours(n, more = {})
  more.merge(scheduled_tour_availability_policy: :only_n_simultaneous_tours,
             scheduled_tour_availability_policy_parameters: {n: n}.to_json)
end
