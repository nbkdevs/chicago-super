import 'package:chicago_charter_bus_rental/chicago_charter_bus_rental.dart';
import 'package:test/test.dart';

void main() {
  test('metadata constants', () {
    expect(chicagoCharterBusRentalHomepageUrl(),
        'https://chicagosupercoachbus.com/');
    expect(chicagoCharterBusRentalTitle, 'Chicago Charter Bus Rental');
  });

  group('vehiclesNeeded', () {
    test('rounds up per class', () {
      expect(vehiclesNeeded(57, CharterVehicle.superCoach), 1);
      expect(vehiclesNeeded(58, CharterVehicle.superCoach), 2);
      expect(vehiclesNeeded(100, CharterVehicle.coach), 3);
      expect(vehiclesNeeded(15, CharterVehicle.sprinterVan), 1);
      expect(vehiclesNeeded(31, CharterVehicle.trolley), 2);
    });

    test('rejects empty groups', () {
      expect(
          () => vehiclesNeeded(0, CharterVehicle.coach), throwsArgumentError);
    });
  });

  group('headcountWithBuffer', () {
    test('adds a rounded-up percentage', () {
      expect(headcountWithBuffer(100), 105);
      expect(headcountWithBuffer(50), 53); // 52.5 rounds up
      expect(headcountWithBuffer(40, percent: 0), 40);
      expect(headcountWithBuffer(40, percent: 10), 44);
    });

    test('validates input', () {
      expect(() => headcountWithBuffer(0), throwsArgumentError);
      expect(() => headcountWithBuffer(10, percent: -1), throwsArgumentError);
    });
  });

  group('recommendFleet', () {
    test('single vehicle for small groups', () {
      final p = recommendFleet(12);
      expect(p.vehicleCount, 1);
      expect(p.lines.single.vehicle, CharterVehicle.sprinterVan);
      expect(p.spareSeats, 3);
    });

    test('picks the smallest class that fits', () {
      expect(
          recommendFleet(28).lines.single.vehicle, CharterVehicle.smallCoach);
      expect(recommendFleet(29).lines.single.vehicle, CharterVehicle.coach);
      expect(
          recommendFleet(45).lines.single.vehicle, CharterVehicle.superCoach);
    });

    test('uses fewest vehicles, then fewest spare seats', () {
      final p = recommendFleet(86);
      expect(p.vehicleCount, 2);
      expect(p.totalSeats, 88); // two coaches beat 57 + 44 = 101 seats
      expect(p.spareSeats, 2);
      expect(p.summary,
          '2 x Coach Bus (39-44 seats) = 88 seats for 86 passengers, 2 spare');
    });

    test('big groups', () {
      final p = recommendFleet(300);
      expect(p.vehicleCount, 6); // ceil(300 / 57)
      expect(p.totalSeats, greaterThanOrEqualTo(300));
    });

    test('always seats everyone with the minimum vehicle count', () {
      for (var n = 1; n <= 400; n++) {
        final p = recommendFleet(n);
        expect(p.totalSeats, greaterThanOrEqualTo(n), reason: 'n=$n');
        expect(p.vehicleCount, (n + 56) ~/ 57, reason: 'n=$n');
        expect(p.spareSeats, lessThan(57), reason: 'n=$n');
      }
    });

    test('specialty vehicles when asked', () {
      final p = recommendFleet(30, vehicles: [CharterVehicle.trolley]);
      expect(p.lines.single.vehicle, CharterVehicle.trolley);
      expect(p.spareSeats, 0);
      final all = recommendFleet(45, vehicles: CharterVehicle.all);
      expect(all.vehicleCount, 1);
      expect(all.spareSeats, 0); // party bus seats exactly 45
    });

    test('validates input', () {
      expect(() => recommendFleet(0), throwsArgumentError);
      expect(() => recommendFleet(maxPlanPassengers + 1), throwsArgumentError);
      expect(() => recommendFleet(10, vehicles: []), throwsArgumentError);
    });
  });

  test('seat ranges', () {
    expect(CharterVehicle.superCoach.seatRange, '50-57');
    expect(CharterVehicle.partyBus.seatRange, '45');
  });
}
