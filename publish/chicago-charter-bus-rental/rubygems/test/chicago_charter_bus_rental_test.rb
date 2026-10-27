# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/chicago_charter_bus_rental"

class ChicagoCharterBusRentalTest < Minitest::Test
  CBR = ChicagoCharterBusRental

  def test_metadata
    assert_equal "https://chicagosupercoachbus.com/", CBR.homepage
    assert_equal "Chicago Charter Bus Rental", CBR::TITLE
  end

  def test_vehicles_needed_rounds_up
    assert_equal 1, CBR.vehicles_needed(57, CBR::SUPER_COACH)
    assert_equal 2, CBR.vehicles_needed(58, CBR::SUPER_COACH)
    assert_equal 3, CBR.vehicles_needed(100, CBR::COACH)
    assert_equal 2, CBR.vehicles_needed(31, CBR::TROLLEY)
    assert_raises(ArgumentError) { CBR.vehicles_needed(0, CBR::COACH) }
  end

  def test_headcount_with_buffer
    assert_equal 105, CBR.headcount_with_buffer(100)
    assert_equal 53, CBR.headcount_with_buffer(50)
    assert_equal 40, CBR.headcount_with_buffer(40, percent: 0)
    assert_equal 44, CBR.headcount_with_buffer(40, percent: 10)
    assert_raises(ArgumentError) { CBR.headcount_with_buffer(10, percent: -1) }
  end

  def test_small_group_gets_smallest_fit
    plan = CBR.recommend_fleet(12)
    assert_equal 1, plan.vehicle_count
    assert_equal CBR::SPRINTER_VAN, plan.lines.first.vehicle
    assert_equal 3, plan.spare_seats
    assert_equal CBR::SMALL_COACH, CBR.recommend_fleet(28).lines.first.vehicle
    assert_equal CBR::COACH, CBR.recommend_fleet(29).lines.first.vehicle
    assert_equal CBR::SUPER_COACH, CBR.recommend_fleet(45).lines.first.vehicle
  end

  def test_fewest_vehicles_then_fewest_spare_seats
    plan = CBR.recommend_fleet(86)
    assert_equal 2, plan.vehicle_count
    assert_equal 88, plan.total_seats
    assert_equal "2 x Coach Bus (39-44 seats) = 88 seats for 86 passengers, 2 spare", plan.summary
  end

  def test_every_headcount_is_seated_with_minimum_vehicles
    (1..400).each do |n|
      plan = CBR.recommend_fleet(n)
      assert_operator plan.total_seats, :>=, n
      assert_equal (n + 56) / 57, plan.vehicle_count, "n=#{n}"
      assert_operator plan.spare_seats, :<, 57
    end
  end

  def test_specialty_vehicles
    plan = CBR.recommend_fleet(30, vehicles: [CBR::TROLLEY])
    assert_equal 0, plan.spare_seats
    assert_equal 0, CBR.recommend_fleet(45, vehicles: CBR::ALL).spare_seats
  end

  def test_validation
    assert_raises(ArgumentError) { CBR.recommend_fleet(0) }
    assert_raises(ArgumentError) { CBR.recommend_fleet(5001) }
    assert_raises(ArgumentError) { CBR.recommend_fleet(10, vehicles: []) }
  end
end
