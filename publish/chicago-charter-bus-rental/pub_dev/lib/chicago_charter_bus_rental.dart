/// Group charter planning helpers for
/// [Chicago Charter Bus Rental](https://chicagosupercoachbus.com/).
///
/// Answer the first question of any Chicago group trip: how many vehicles
/// does this headcount need, and how many seats are left over?
///
/// ```dart
/// import 'package:chicago_charter_bus_rental/chicago_charter_bus_rental.dart';
///
/// final plan = recommendFleet(86);
/// print(plan.summary); // 2 x Coach Bus (39-44 seats) = 88 seats ...
/// ```
///
/// Seat counts are the top of the ranges on the published fleet page. They
/// are a planning aid only: they are not a quote, a booking or a statement
/// of availability.
library;

/// Display title: Chicago Charter Bus Rental.
const String chicagoCharterBusRentalTitle = 'Chicago Charter Bus Rental';

/// Official homepage, kept as a plain URL for metadata use.
const String chicagoCharterBusRentalHomepage =
    'https://chicagosupercoachbus.com/';

/// Returns the official homepage URL.
String chicagoCharterBusRentalHomepageUrl() => chicagoCharterBusRentalHomepage;

/// Largest headcount [recommendFleet] accepts in one plan.
const int maxPlanPassengers = 5000;

/// A vehicle class in the Chicago charter fleet.
enum CharterVehicle {
  /// Largest coach, 50-57 passengers.
  superCoach('SuperCoach', 50, 57),

  /// Full-size coach bus, 39-44 passengers.
  coach('Coach Bus', 39, 44),

  /// Small coach bus, 22-28 passengers.
  smallCoach('Small Coach Bus', 22, 28),

  /// Executive Sprinter van, 13-15 passengers.
  sprinterVan('Executive Sprinter Van', 13, 15),

  /// Party bus, 45 passengers.
  partyBus('Party Bus', 45, 45),

  /// Trolley, 30 passengers.
  trolley('Trolley', 30, 30);

  const CharterVehicle(this.label, this.minSeats, this.maxSeats);

  /// Human-readable name.
  final String label;

  /// Low end of the published seat range.
  final int minSeats;

  /// High end of the published seat range, used as the capacity.
  final int maxSeats;

  /// Seat range as text, e.g. `39-44`, or `45` when the range is a single
  /// number.
  String get seatRange =>
      minSeats == maxSeats ? '$maxSeats' : '$minSeats-$maxSeats';

  /// Standard coaches used by [recommendFleet], largest first.
  static const List<CharterVehicle> standard = [
    superCoach,
    coach,
    smallCoach,
    sprinterVan,
  ];

  /// Every class, largest standard coaches first, then specialty vehicles.
  static const List<CharterVehicle> all = [
    superCoach,
    partyBus,
    coach,
    trolley,
    smallCoach,
    sprinterVan,
  ];
}

/// One line of a [FleetPlan]: [count] vehicles of one [vehicle] class.
class FleetLine {
  /// Creates a line of [count] vehicles.
  const FleetLine(this.vehicle, this.count);

  /// The vehicle class.
  final CharterVehicle vehicle;

  /// How many of this class.
  final int count;

  /// Seats provided by this line.
  int get seats => vehicle.maxSeats * count;

  @override
  String toString() => '$count x ${vehicle.label} (${vehicle.seatRange} seats)';
}

/// The vehicles recommended for a headcount.
class FleetPlan {
  /// Creates a plan; use [recommendFleet] instead of calling this directly.
  const FleetPlan(this.passengers, this.lines);

  /// Headcount the plan was made for.
  final int passengers;

  /// Vehicle lines, largest vehicles first.
  final List<FleetLine> lines;

  /// Total vehicles.
  int get vehicleCount => lines.fold(0, (sum, l) => sum + l.count);

  /// Total seats across all vehicles.
  int get totalSeats => lines.fold(0, (sum, l) => sum + l.seats);

  /// Seats left over after seating [passengers].
  int get spareSeats => totalSeats - passengers;

  /// One-line description of the plan.
  String get summary =>
      '${lines.join(' + ')} = $totalSeats seats for $passengers '
      'passengers, $spareSeats spare';

  @override
  String toString() => summary;
}

/// How many vehicles of one [vehicle] class [passengers] need.
///
/// Throws [ArgumentError] when [passengers] is below 1.
int vehiclesNeeded(int passengers, CharterVehicle vehicle) {
  _checkPassengers(passengers);
  return (passengers + vehicle.maxSeats - 1) ~/ vehicle.maxSeats;
}

/// Headcount to plan for after adding a safety [percent] (default 5%) for
/// late additions, rounded up. Returns [confirmed] unchanged when [percent]
/// is 0.
///
/// Throws [ArgumentError] when [confirmed] is below 1 or [percent] is
/// negative.
int headcountWithBuffer(int confirmed, {int percent = 5}) {
  _checkPassengers(confirmed);
  if (percent < 0) {
    throw ArgumentError.value(percent, 'percent', 'must not be negative');
  }
  return (confirmed * (100 + percent) + 99) ~/ 100;
}

/// Recommends the fewest vehicles that seat [passengers], and among those
/// the fewest spare seats.
///
/// By default only the standard coaches are used ([CharterVehicle.standard]).
/// Pass [vehicles] to choose a different set, e.g. [CharterVehicle.all] to
/// include the party bus and trolley.
///
/// Throws [ArgumentError] when [passengers] is outside
/// 1..[maxPlanPassengers] or [vehicles] is empty.
FleetPlan recommendFleet(
  int passengers, {
  List<CharterVehicle> vehicles = CharterVehicle.standard,
}) {
  _checkPassengers(passengers);
  if (passengers > maxPlanPassengers) {
    throw ArgumentError.value(
        passengers, 'passengers', 'must be at most $maxPlanPassengers');
  }
  if (vehicles.isEmpty) {
    throw ArgumentError.value(vehicles, 'vehicles', 'must not be empty');
  }
  // Largest first so ties resolve toward fewer, bigger vehicles.
  final options = [...vehicles]
    ..sort((a, b) => b.maxSeats.compareTo(a.maxSeats));
  final biggest = options.first.maxSeats;
  final limit = passengers + biggest - 1;

  // Unbounded coin-change: fewest vehicles giving exactly `s` seats.
  const unreachable = 1 << 30;
  final fewest = List<int>.filled(limit + 1, unreachable);
  final pick = List<CharterVehicle?>.filled(limit + 1, null);
  fewest[0] = 0;
  for (var s = 1; s <= limit; s++) {
    for (final v in options) {
      final from = s - v.maxSeats;
      if (from >= 0 && fewest[from] + 1 < fewest[s]) {
        fewest[s] = fewest[from] + 1;
        pick[s] = v;
      }
    }
  }

  var best = -1;
  for (var s = passengers; s <= limit; s++) {
    if (fewest[s] == unreachable) continue;
    if (best == -1 || fewest[s] < fewest[best]) best = s;
  }

  final counts = <CharterVehicle, int>{};
  for (var s = best; s > 0; s -= pick[s]!.maxSeats) {
    counts.update(pick[s]!, (n) => n + 1, ifAbsent: () => 1);
  }
  final lines = [
    for (final v in options)
      if (counts.containsKey(v)) FleetLine(v, counts[v]!),
  ];
  return FleetPlan(passengers, lines);
}

void _checkPassengers(int passengers) {
  if (passengers < 1) {
    throw ArgumentError.value(passengers, 'passengers', 'must be at least 1');
  }
}
