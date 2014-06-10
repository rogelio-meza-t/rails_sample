#encoding: utf-8
require 'spec_helper'

describe ProductSchedule do
  it 'schedules the tours after creation' do
    start_date = 10.days.ago
    end_date   = 30.days.from_now
    days       = 'monday,wednesday'
    days_as_a  = [:monday, :wednesday]
    product    = FactoryGirl.create(:hiking)
    ScheduledTour.should_receive(:populate).with(product, start_date.to_date..end_date.to_date, days_as_a)
    ProductSchedule.create!(product: product, start_date: start_date, end_date: end_date, days: days)
  end

  it 'transforms the days string into array' do
    days_with_commas = 'monday, Wednesday, sunday'
    days_with_spaces = 'moNDay  wednesday  SUNDAY'
    days_as_array    = [:monday, :wednesday, :sunday]
    ProductSchedule.new(days: days_with_commas).days_as_array.should eq days_as_array
    ProductSchedule.new(days: days_with_spaces).days_as_array.should eq days_as_array
  end

  it 'translates spanish day names to english' do
    days = 'lunes, martes, miércoles, jueves, viernes, sabado, domingo'
    days_translated = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    ProductSchedule.new(days: days).days_as_array.should eq days_translated
  end
end
