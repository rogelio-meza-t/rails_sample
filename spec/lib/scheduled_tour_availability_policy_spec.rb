require 'spec_helper'
require 'scheduled_tour_availability_policy'
require 'support/mocks'

describe ScheduledTourAvailabilityPolicy do
  context "policy lookup" do 
    it "produces, by default, a no-op" do
      operator = stub(:tour_operator,
                      scheduled_tour_availability_policy: nil,
                      scheduled_tour_availability_policy_parameters: nil)
      ScheduledTourAvailabilityPolicy.for(operator).should ==
        ScheduledTourAvailabilityPolicy::NoTourConflicts
    end

    it "filter functions can be named" do
      operator = stub(:tour_operator,
                     scheduled_tour_availability_policy: "all_tours_are_available",
                     scheduled_tour_availability_policy_parameters: "{}")
      ScheduledTourAvailabilityPolicy.for(operator).should ==
        ScheduledTourAvailabilityPolicy::NoTourConflicts
    end
    
    it "can_filter_according_to_n_simultaneous tours" do
      operator = stub(:tour_operator,
                      scheduled_tour_availability_policy: "only_n_simultaneous_tours",
                      scheduled_tour_availability_policy_parameters: {n: 2}.to_json)
      during {
        ScheduledTourAvailabilityPolicy.for(operator)
      }.behold! {
        ScheduledTourAvailabilityPolicy::OnlyNSimultaneousTours.
            should_receive(:new).with(2).
            and_return("instantiated class")
      }
      @result.should == "instantiated class"
    end
  end

  context "The NoTourConflict policy" do
    subject { ScheduledTourAvailabilityPolicy::NoTourConflicts }
    let(:tour) { stub(:tour) }
    
    it "filters no tours" do
      subject.filter([1, 2, 3]).should == [1, 2, 3]
    end
    
    it "always allows a new tour" do 
      subject.allows_new_tour?(["existing tours"], "any time range").should be_true
    end
    
    it "never thinks there's a violation of the simultaneous tour limit" do 
      subject.would_be_within_simultaneous_tour_limit?(tour).should be_true
    end
    
    it "has forgiving support for the Either monad" do 
      subject.must_be_within_simultaneous_tour_limit(tour).should be_success
    end
  end
    
  context "the n-simultaneous-tours policy" do
    klass = ScheduledTourAvailabilityPolicy::OnlyNSimultaneousTours
    one_date = Date.new(2012, 8, 1)
    another_date = Date.new(2012, 8, 2)
    just_hour = -> hour { Time.new(2012,8,1, hour) }
    
    context "filtering" do
      
      context "allows a one-person shop to offer two tours" do
        subject { klass.new(1) }
        
        it "by allowing both to be chosen if neither has" do 
          wed_1 = stub(:wed_1, date: one_date,
                               time_range: just_hour.(8)...just_hour.(17),
                               has_reservations?: false)
      
          wed_2 = stub(:wed_2, date: one_date,
                               time_range: just_hour.(8)...just_hour.(17),
                               has_reservations?: false)
      
          subject.filter([wed_1, wed_2]).should == [wed_1, wed_2]
        end

        it "and allowing the first booked to exclude the other" do
          wed_1 = stub(:wed_1, date: one_date,
                               time_range: just_hour.(8)...just_hour.(17),
                               has_reservations?: true)
      
          wed_unbooked = stub(:wed_unbooked, date: one_date,
                                             time_range: just_hour.(8)...just_hour.(17),
                                             has_reservations?: false)
      
          subject.filter([wed_1, wed_unbooked]).should == [wed_1]
        end

        it "does not allow tours on different days to conflict" do 
          wed_1 = stub(:wed_1, date: one_date,
                               time_range: just_hour.(8)...just_hour.(17),
                               has_reservations?: true)
      
          thu_unbooked = stub(:thu_unbooked, date: another_date,  # different
                                             time_range: just_hour.(8)...just_hour.(17),
                                             has_reservations?: false)
      
          subject.filter([wed_1, thu_unbooked]).should == [wed_1, thu_unbooked]
        end

        it "does not find tours in conflict if they are at different times" do
          morning_booked = stub(:morning_booked, date: one_date,
                                                 time_range: just_hour.(8)...just_hour.(12),
                                                 has_reservations?: true)
      
          afternoon_unbooked = stub(:afternoon_unbooked, date: one_date,
                                                         time_range: just_hour.(13)...just_hour.(17),
                                                         has_reservations?: false)
      
          result = subject.filter([morning_booked, afternoon_unbooked])
          result.should == [morning_booked, afternoon_unbooked]
        end

        it "but the slightest overlap is enough to exclude a tour" do
          morning_booked = stub(:morning_booked, date: one_date,
                                                 time_range: just_hour.(8)...just_hour.(13),
                                                 has_reservations?: true)
      
          afternoon_unbooked = stub(:afternoon_unbooked, date: one_date,
                                                         time_range: just_hour.(12)...just_hour.(17),
                                                         has_reservations?: false)
      
          subject.filter([morning_booked, afternoon_unbooked]).should == [morning_booked]
        end
      end

      context "allows a two-person shop to offer three tours" do 
        subject { klass.new(2) }

        it "only excludes the third tour if the first two are taken" do 
          wed_1 = stub(:wed_1, date: one_date,
                               time_range: just_hour.(8)...just_hour.(17),
                               has_reservations?: true)
        
          wed_2 = stub(:wed_2, date: one_date,
                               time_range: just_hour.(8)...just_hour.(12),
                               has_reservations?: true)
        
          wed_unbooked = stub(:wed_unbooked, date: one_date,
                               time_range: just_hour.(8)...just_hour.(12),
                               has_reservations?: false)
        
          subject.filter([wed_1, wed_2, wed_unbooked]).should == [wed_1, wed_2]
        end
  
        it "if only one is taken, there's no exclusion" do 
          wed_1 = stub(:wed_1, date: one_date,
                               time_range: just_hour.(8)...just_hour.(17),
                               has_reservations?: false)
        
          wed_2 = stub(:wed_2, date: one_date,
                               time_range: just_hour.(8)...just_hour.(12),
                               has_reservations?: true)
        
          wed_unbooked = stub(:wed_unbooked, date: one_date,
                               time_range: just_hour.(8)...just_hour.(12),
                               has_reservations?: false)
        
          result = subject.filter([wed_1, wed_2, wed_unbooked])
          Set.new(result).should == Set.new([wed_1, wed_2, wed_unbooked])
        end
  
        it "the unbooked tour is unaffected if it doesn't overlap a time when both tours are scheduled" do 
          wed_1 = stub(:wed_1, date: one_date,
                               time_range: just_hour.(8)...just_hour.(17),
                               has_reservations?: true)
        
          wed_2 = stub(:wed_2, date: one_date,
                               time_range: just_hour.(8)...just_hour.(12),
                               has_reservations?: true)
        
          wed_unbooked = stub(:wed_unbooked, date: one_date,
                               time_range: just_hour.(12)...just_hour.(17),
                               has_reservations?: false)
        
          result = subject.filter([wed_1, wed_2, wed_unbooked])
          Set.new(result).should == Set.new([wed_1, wed_2, wed_unbooked])
        end
      end
  
      it "handles a complex 3-way exclusion" do
        subject = klass.new(3)
        
        # These three work together to exclude the hours from 12-14
        one = stub(:one, date: one_date,
                         time_range: just_hour.(8)...just_hour.(14),
                         has_reservations?: true)
        two = stub(:two, date: one_date,
                         time_range: just_hour.(8)...just_hour.(16),
                         has_reservations?: true)
        three = stub(:three, date: one_date,
                         time_range: just_hour.(12)...just_hour.(15),
                         has_reservations?: true)
  
        # This is excluded because it overlaps the hours 12-14.
        excluded_late = stub(:excluded_late, date: one_date,
                                             time_range: just_hour.(13)...just_hour.(17),
                                             has_reservations?: false)
  
        # This adds another exclusion zone from 8-10
        four = stub(:four, date: one_date,
                           time_range: just_hour.(8)...just_hour.(10),
                           has_reservations?: true)
  
        # This is excluded because it overlaps the hours 8-10.
        excluded_early = stub(:excluded_early, date: one_date,
                                               time_range: just_hour.(8)...just_hour.(12),
                                               has_reservations?: false)
  
        # This is not excluded, because it only overlaps two of three
        ok = stub(:ok, date: one_date,
                       time_range: just_hour.(14)...just_hour.(17),
                       has_reservations?: false)
        
        result = subject.filter([one, two, three, four, excluded_early, excluded_early, ok])
        Set.new(result).should == Set.new([one, two, three, four, ok])
      end
    end

    context "a new tour" do
      subject { klass.new(1) }

      it "is allowed if the old tour has no reservation" do
        time_range = just_hour.(8)...just_hour.(17)
        existing = stub(time_range: time_range, has_reservations?: false)
        actual = subject.allows_new_tour?([existing], time_range)
        actual.should be_true
      end

      it "is allowed if the time range does not overlap" do 
        existing = stub(time_range: just_hour.(8)...just_hour.(12),
                        has_reservations?: true)
        actual = subject.allows_new_tour?([existing], just_hour.(12)...just_hour.(15))
        actual.should be_true
      end

      it "is disallowed if the range overlaps with too many reserved tours" do
        existing = stub(time_range: just_hour.(8)...just_hour.(12),
                        has_reservations?: true)
        actual = subject.allows_new_tour?([existing], just_hour.(10)...just_hour.(15))
        actual.should be_false
      end

      context "(slightly more complex cases)" do 
        subject { klass.new(2) }
        let(:earliest) { stub(time_range: just_hour.(8)...just_hour.(13), has_reservations?: true) } 
        let(:middle)   { stub(time_range: just_hour.(10)...just_hour.(15), has_reservations?: true) }
        let(:endish)   { stub(time_range: just_hour.(14)...just_hour.(16), has_reservations?: true) }
        let(:irrelevant) { stub(has_reservations?: false) }

        let(:tours) { [earliest, middle, endish, irrelevant] }

        it "work" do
          subject.allows_new_tour?(tours, just_hour.(8)...just_hour.(10)).should be_true
          subject.allows_new_tour?(tours, just_hour.(10)...just_hour.(13)).should be_false
          subject.allows_new_tour?(tours, just_hour.(13)...just_hour.(14)).should be_true
          subject.allows_new_tour?(tours, just_hour.(14)...just_hour.(15)).should be_false
          subject.allows_new_tour?(tours, just_hour.(15)...just_hour.(16)).should be_true
          subject.allows_new_tour?(tours, just_hour.(16)...just_hour.(17)).should be_true
        end
      end
    end

    context "a new reservation" do
      subject { klass.new(2) }

      morning = just_hour.(8)...just_hour.(12)
      afternoon = just_hour.(12)...just_hour.(17)
      
      let(:reserved_morning) {  stub(:reserved_morning, date: one_date,
                                     time_range: morning,
                                     has_reservations?: true) }
      let(:also_reserved_morning) {  stub(:also_reserved_morning, date: one_date,
                                          time_range: morning,
                                          has_reservations?: true) }
      let(:reserved_afternoon) {  stub(:reserved_afternoon, date: one_date,
                                       time_range: afternoon,
                                       has_reservations?: true) }
      
      let(:base_tours) { [reserved_morning, also_reserved_morning, reserved_afternoon] }

      it "disallows a reservation that would exceed the simultaneous tour limit" do 
        candidate = stub(:candidate, date: one_date,
                         time_range: morning,
                         has_reservations?: false)
        candidate.should_receive(:date_family).twice.and_return(base_tours+[candidate])

        subject.would_be_within_simultaneous_tour_limit?(candidate).should be_false
        subject.must_be_within_simultaneous_tour_limit(candidate).should be_failure
      end

      it "allows a reservation that would produce newly-reserved tour under the tour limit" do
        candidate = stub(:candidate, date: one_date,
                         time_range: afternoon,
                         has_reservations?: false)
        candidate.should_receive(:date_family).twice.and_return(base_tours+[candidate])

        subject.would_be_within_simultaneous_tour_limit?(candidate).should be_true
        subject.must_be_within_simultaneous_tour_limit(candidate).should be_success
      end


      it "is not fooled by adding a reservation to a tour that already has one" do
        subject.would_be_within_simultaneous_tour_limit?(reserved_morning).should be_true
        subject.must_be_within_simultaneous_tour_limit(reserved_morning).should be_success
      end
    end
  
    context "the mechanics of the n-simultaneous-tours filtering policy" do
      given_n = 3
      subject { ScheduledTourAvailabilityPolicy::OnlyNSimultaneousTours.new(given_n) }
  
      it "processes each day separately and combines the results" do
        monday_tour_one = stub("monday tour one")
        monday_tour_two = stub("monday tour two")
        tuesday_tour_one = stub("tuesday tour one")
        monday_tours = [monday_tour_one, monday_tour_two]
        tuesday_tours = [tuesday_tour_one]
        tours = monday_tours + tuesday_tours
  
        during {
          subject.filter(tours)
        }.behold! {
          subject.should_receive(:partition_by_date).with(tours).
                  and_return([monday_tours, tuesday_tours])
          subject.should_receive(:filter_one_days_worth).with(monday_tours).
                  and_return([monday_tour_two]) # Monday tour one is unavailable
          subject.should_receive(:filter_one_days_worth).with(tuesday_tours).
                  and_return(tuesday_tours)
        }
        @result.should == [monday_tour_two, tuesday_tour_one]
      end
  
      # When processing a day's tours...
      it "disallows tours with no bookings based on times when booked tours use up scarce resources" do
        # where the scarce resources are represented by the parameter N
        
        booked_tour_one = stub("booked tour one", has_reservations?: true)
        booked_tour_two = stub("unbooked tour two", has_reservations?: true)
        overlapping_range = "start"..."end"  # just as an example
        
        unbooked_tour = stub("unbooked tour", has_reservations?: false) 
        # Let's assume unbooked tour doesn't clash with the overlapping range.
  
        during {
          subject.filter_one_days_worth([booked_tour_one, booked_tour_two, unbooked_tour])
        }.behold! {
          subject.should_receive(:fully_booked_times_of_the_day).with([booked_tour_one, booked_tour_two]).
          and_return([overlapping_range])
          subject.should_receive(:time_containers_allowed_by).with([unbooked_tour], [overlapping_range]).
          and_return([unbooked_tour])
        }
        @result.should == [booked_tour_one, booked_tour_two, unbooked_tour]
      end
  
      it "uses `n` to find times of the day when no new tours can be handled" do
        
        during {
          subject.fully_booked_times_of_the_day(["some tours..."])
        }.behold! {
          subject.should_receive(:n_way_overlaps).with(given_n, ["some tours..."]).
                  and_return([ ["tour1", "tour2", "tour3"], ["tour2", "tour3", "tour4"]])
          subject.should_receive(:time_range_intersection).with(["tour1", "tour2", "tour3"]).
                  and_return("intersection 1")
          subject.should_receive(:time_range_intersection).with(["tour2", "tour3", "tour4"]).
                  and_return("intersection 2")
        }
        @result.should == ["intersection 1", "intersection 2"]
      end
    end
  end
end  
