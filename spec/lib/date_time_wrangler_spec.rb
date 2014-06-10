describe DateTimeWrangler do
  subject { DateTimeWrangler } 
  
  it "can partition containers by date" do
    one_date = stub(:one, date: Date.new(2011, 11, 11))
    same_date = stub(:same, date: Date.new(2011, 11, 11))
    different = stub(:different, date: Date.new(2012, 12, 12))

    actual = subject.partition_by_date([one_date, different, same_date])
    comparable = actual.collect(&:to_set).to_set
    comparable.should == [ [one_date, same_date].to_set, [different].to_set].to_set
  end

  context "determining if time ranges overlap" do
    let(:before_first) { Time.new(2012, 12, 12, 1, 30) }
    let(:first)        { Time.new(2012, 12, 12, 2, 30) }
    let(:middle)       { Time.new(2012, 12, 12, 3, 30) }
    let(:last)         { Time.new(2012, 12, 12, 4, 30) }
    let(:after_last)   { Time.new(2012, 12, 12, 5, 30) }
    
    let(:constant)        { stub(time_range: first...       last) }
    let(:overlaps_before) { stub(time_range: before_first...middle) }
    let(:overlaps_after)  { stub(time_range: middle...      after_last) }
    let(:just_before)     { stub(time_range: before_first...first) }
    let(:just_after)      { stub(time_range: last...        after_last) }

    it "works with containers" do 
      subject.time_overlaps?(constant, constant).should be_true
      subject.time_overlaps?(constant, overlaps_before).should be_true
      subject.time_overlaps?(constant, overlaps_after).should be_true
      subject.time_overlaps?(constant, just_before).should be_false
      subject.time_overlaps?(constant, just_before).should be_false
    end

    it "also works with unwrapped ranges" do 
      subject.time_overlaps?(constant, constant.time_range).should be_true
      subject.time_overlaps?(constant.time_range, overlaps_before).should be_true
      subject.time_overlaps?(constant.time_range, just_before).should be_false
      subject.time_overlaps?(constant, just_before.time_range).should be_false
    end

  end

  context "can determine if a set of time ranges overlap with each other" do
    let(:one) { mock(:one) }
    let(:two) { mock(:two) }
    let(:three) { mock(:three) }

    it "when they do" do
      during { 
        subject.all_tour_times_overlap?([one, two, three])
      }.behold! { 
        subject.should_receive(:time_overlaps?).with(one, two).and_return(true)
        subject.should_receive(:time_overlaps?).with(one, three).and_return(true)
        subject.should_receive(:time_overlaps?).with(two, three).and_return(true)
      }
      @result.should be_true
    end

    it "when they don't" do
      during { 
        subject.all_tour_times_overlap?([one, two, three])
      }.behold! { 
        subject.should_receive(:time_overlaps?).with(one, two).and_return(true)
        subject.should_receive(:time_overlaps?).with(one, three).and_return(true)
        subject.should_receive(:time_overlaps?).with(two, three).and_return(false)
      }
      @result.should be_false
    end
  end

  it "can generate all N-way overlaps" do 
    one = mock(:one) 
    two = mock(:two) 
    three = mock(:three) 
    four = mock(:four) 

    during { 
      subject.n_way_overlaps(3, [one, two, three, four])
    }.behold! {
      subject.should_receive(:all_tour_times_overlap?).with([one, two, three]).and_return(true)
      subject.should_receive(:all_tour_times_overlap?).with([one, two, four]).and_return(false)
      subject.should_receive(:all_tour_times_overlap?).with([one, three, four]).and_return(false)
      subject.should_receive(:all_tour_times_overlap?).with([two, three, four]).and_return(true)
    }
    @result.to_set.should == Set.new([[one, two, three], [two, three, four]])
  end

  it "can generate a minimal range given a set of overlapping containers" do 
    one   = Time.new(2012, 12, 12, 1, 30)
    two   = Time.new(2012, 12, 12, 2, 30)
    three = Time.new(2012, 12, 12, 3, 30)
    four  = Time.new(2012, 12, 12, 4, 30)
    five  = Time.new(2012, 12, 12, 5, 30)
    six   = Time.new(2012, 12, 12, 6, 30)


    result = subject.time_range_intersection([stub(time_range: one...five),
                                              stub(time_range: one...three),
                                              stub(time_range: one...two)]).
      should == (one...two)

    # Order doesn't matter

    result = subject.time_range_intersection([stub(time_range: one...two),
                                              stub(time_range: one...five),
                                              stub(time_range: one...three)]).
      should == (one...two)

    # non-contained ranges

    result = subject.time_range_intersection([stub(time_range: one...four),
                                              stub(time_range: two...five)]).
      should == (two...four)

    # A few unnecessary tests

    result = subject.time_range_intersection([stub(time_range: one...five),
                                              stub(time_range: two...six),
                                              stub(time_range: three...four)]).
      should == (three...four)


    result = subject.time_range_intersection([stub(time_range: one...four),
                                              stub(time_range: two...six),
                                              stub(time_range: three...five)]).
      should == (three...four)
  end

  context "excluding a container that overlaps a set of ranges" do 
    let(:candidate) { stub(time_range: "candidate range") }

    it "works" do
      during {
        subject.time_ranges_exclude?(["one range", "another"], candidate)
      }.behold! { 
        subject.should_receive(:time_overlaps?).with("one range", candidate).and_return(false)
        subject.should_receive(:time_overlaps?).with("another", candidate).and_return(true)
      }
      @result.should be_true
    end

    it "does not exclude everything" do 
      during {
        subject.time_ranges_exclude?(["one range", "another"], candidate)
      }.behold! { 
        subject.should_receive(:time_overlaps?).with("one range", candidate).and_return(false)
        subject.should_receive(:time_overlaps?).with("another", candidate).and_return(false)
      }
      @result.should be_false
    end
  end

  it "can determine which containers a date range allows" do
    one_container = stub(:one_container)
    another_container = stub(:another_container)

    during { 
      subject.time_containers_allowed_by([one_container, another_container], ["time ranges"])
    }.behold! {
      subject.should_receive(:time_ranges_exclude?).with(["time ranges"], one_container).
              and_return(true)
      subject.should_receive(:time_ranges_exclude?).with(["time ranges"], another_container).
              and_return(false)
    }
    @result.should == [another_container]
  end

end
