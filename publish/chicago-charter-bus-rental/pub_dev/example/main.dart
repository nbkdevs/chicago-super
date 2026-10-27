import 'package:chicago_charter_bus_rental/chicago_charter_bus_rental.dart';

void main() {
  // 80 guests confirmed, plus 5% for late additions.
  final headcount = headcountWithBuffer(80);
  final plan = recommendFleet(headcount);
  print(plan.summary);
  for (final line in plan.lines) {
    print('  $line');
  }
  print('Coaches if you only book SuperCoaches: '
      '${vehiclesNeeded(headcount, CharterVehicle.superCoach)}');
}
