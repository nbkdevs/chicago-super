# chicago_charter_bus_rental

Group charter planning helpers for the [Chicago Charter Bus Rental](https://chicagosupercoachbus.com/) fleet: work out how many vehicles a headcount needs and how many seats are left over.

Seat counts are the top of the ranges published for each vehicle class:

| Class | Seats used |
| --- | --- |
| SuperCoach | 57 (50-57) |
| Coach Bus | 44 (39-44) |
| Small Coach Bus | 28 (22-28) |
| Executive Sprinter Van | 15 (13-15) |
| Party Bus | 45 |
| Trolley | 30 |

## Usage

```dart
import 'package:chicago_charter_bus_rental/chicago_charter_bus_rental.dart';

void main() {
  // 80 confirmed guests plus a 5% buffer for late additions.
  final headcount = headcountWithBuffer(80); // 84
  final plan = recommendFleet(headcount);
  print(plan.summary);
  // 1 x SuperCoach (50-57 seats) + 1 x Small Coach Bus (22-28 seats)
  // = 85 seats for 84 passengers, 1 spare

  print(vehiclesNeeded(headcount, CharterVehicle.superCoach)); // 2
}
```

- `recommendFleet(passengers, {vehicles})` returns the fewest vehicles that seat everyone and, among those, the fewest spare seats. Only standard coaches are used unless you pass `CharterVehicle.all` (adds the party bus and trolley).
- `vehiclesNeeded(passengers, vehicle)` is the simple round-up for one vehicle class.
- `headcountWithBuffer(confirmed, {percent = 5})` adds a rounded-up safety margin.

All functions throw `ArgumentError` for a headcount below 1.

## Scope

This is a planning aid. It is not a quote, a booking or a statement of availability: confirm vehicles, prices and dates with the provider.
