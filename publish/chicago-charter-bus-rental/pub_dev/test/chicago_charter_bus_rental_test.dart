import 'package:chicago_charter_bus_rental/chicago_charter_bus_rental.dart';
import 'package:test/test.dart';

void main() {
  test('homepage points to Chicago Charter Bus Rental', () {
    expect(
      chicagoCharterBusRentalHomepageUrl(),
      'https://chicagosupercoachbus.com/',
    );
    expect(chicagoCharterBusRentalTitle, 'Chicago Charter Bus Rental');
  });
}
