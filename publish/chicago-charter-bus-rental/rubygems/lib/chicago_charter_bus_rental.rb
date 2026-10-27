# frozen_string_literal: true

# Group charter planning helpers for Chicago Charter Bus Rental: how many
# vehicles does a headcount need, and how many seats are left over?
#
# Seat counts are the top of the ranges on the published fleet page. They are
# a planning aid only, not a quote, a booking or a statement of availability.
module ChicagoCharterBusRental
  VERSION = "1.0.0"
  TITLE = "Chicago Charter Bus Rental"
  HOMEPAGE = "https://chicagosupercoachbus.com/"
  MAX_PLAN_PASSENGERS = 5000

  # A vehicle class in the Chicago charter fleet.
  Vehicle = Struct.new(:key, :label, :min_seats, :max_seats) do
    # Seat range as text, e.g. "39-44", or "45" for a single number.
    def seat_range
      min_seats == max_seats ? max_seats.to_s : "#{min_seats}-#{max_seats}"
    end
  end

  SUPER_COACH = Vehicle.new(:super_coach, "SuperCoach", 50, 57).freeze
  COACH = Vehicle.new(:coach, "Coach Bus", 39, 44).freeze
  SMALL_COACH = Vehicle.new(:small_coach, "Small Coach Bus", 22, 28).freeze
  SPRINTER_VAN = Vehicle.new(:sprinter_van, "Executive Sprinter Van", 13, 15).freeze
  PARTY_BUS = Vehicle.new(:party_bus, "Party Bus", 45, 45).freeze
  TROLLEY = Vehicle.new(:trolley, "Trolley", 30, 30).freeze

  # Standard coaches used by default, largest first.
  STANDARD = [SUPER_COACH, COACH, SMALL_COACH, SPRINTER_VAN].freeze
  # Every class, including the party bus and trolley.
  ALL = [SUPER_COACH, PARTY_BUS, COACH, TROLLEY, SMALL_COACH, SPRINTER_VAN].freeze

  # One line of a plan: +count+ vehicles of one class.
  FleetLine = Struct.new(:vehicle, :count) do
    def seats
      vehicle.max_seats * count
    end

    def to_s
      "#{count} x #{vehicle.label} (#{vehicle.seat_range} seats)"
    end
  end

  # The vehicles recommended for a headcount.
  FleetPlan = Struct.new(:passengers, :lines) do
    def vehicle_count
      lines.sum(&:count)
    end

    def total_seats
      lines.sum(&:seats)
    end

    def spare_seats
      total_seats - passengers
    end

    def summary
      "#{lines.join(' + ')} = #{total_seats} seats for #{passengers} passengers, #{spare_seats} spare"
    end

    alias_method :to_s, :summary
  end

  module_function

  def homepage
    HOMEPAGE
  end

  # Vehicles of one class needed for +passengers+.
  def vehicles_needed(passengers, vehicle)
    check_passengers(passengers)
    (passengers + vehicle.max_seats - 1) / vehicle.max_seats
  end

  # Headcount to plan for after adding +percent+ (default 5) for late
  # additions, rounded up.
  def headcount_with_buffer(confirmed, percent: 5)
    check_passengers(confirmed)
    raise ArgumentError, "percent must not be negative" if percent.negative?

    (confirmed * (100 + percent) + 99) / 100
  end

  # Fewest vehicles that seat +passengers+, and among those the fewest spare
  # seats. Uses the standard coaches unless +vehicles+ is given.
  def recommend_fleet(passengers, vehicles: STANDARD)
    check_passengers(passengers)
    if passengers > MAX_PLAN_PASSENGERS
      raise ArgumentError, "passengers must be at most #{MAX_PLAN_PASSENGERS}"
    end
    raise ArgumentError, "vehicles must not be empty" if vehicles.empty?

    options = vehicles.sort_by { |v| -v.max_seats }
    limit = passengers + options.first.max_seats - 1
    unreachable = 1 << 30
    fewest = Array.new(limit + 1, unreachable)
    pick = Array.new(limit + 1)
    fewest[0] = 0
    (1..limit).each do |s|
      options.each do |v|
        from = s - v.max_seats
        next unless from >= 0 && fewest[from] + 1 < fewest[s]

        fewest[s] = fewest[from] + 1
        pick[s] = v
      end
    end

    best = nil
    (passengers..limit).each do |s|
      next if fewest[s] == unreachable

      best = s if best.nil? || fewest[s] < fewest[best]
    end

    counts = Hash.new(0)
    s = best
    while s.positive?
      counts[pick[s]] += 1
      s -= pick[s].max_seats
    end
    lines = options.select { |v| counts.key?(v) }.map { |v| FleetLine.new(v, counts[v]) }
    FleetPlan.new(passengers, lines)
  end

  def check_passengers(passengers)
    raise ArgumentError, "passengers must be at least 1" if passengers < 1
  end
end
