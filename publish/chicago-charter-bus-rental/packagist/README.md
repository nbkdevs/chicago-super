# chicagosupercoach/charter-bus-rental

Group charter planning helpers for the [Chicago Charter Bus Rental](https://chicagosupercoachbus.com/) fleet: work out how many vehicles a headcount needs and how many seats are left over. Requires PHP 8.1+, no dependencies.

Seat counts are the top of the ranges published for each vehicle class: SuperCoach 57 (50-57), Coach Bus 44 (39-44), Small Coach Bus 28 (22-28), Executive Sprinter Van 15 (13-15), Party Bus 45 and Trolley 30.

```php
use ChicagoSuperCoach\CharterBusRental\Resources;
use ChicagoSuperCoach\CharterBusRental\Vehicle;

$headcount = Resources::headcountWithBuffer(80);   // 84, +5% for late additions
$plan = Resources::recommendFleet($headcount);
echo $plan->summary();
// 1 x SuperCoach (50-57 seats) + 1 x Small Coach Bus (22-28 seats)
// = 85 seats for 84 passengers, 1 spare

echo Resources::vehiclesNeeded($headcount, Vehicle::SuperCoach); // 2
```

- `Resources::recommendFleet(int $passengers, ?array $vehicles = null)` returns the fewest vehicles that seat everyone and, among those, the fewest spare seats. Pass `Vehicle::all()` to include the party bus and trolley.
- `Resources::vehiclesNeeded(int $passengers, Vehicle $vehicle)` is the simple round-up for one class.
- `Resources::headcountWithBuffer(int $confirmed, int $percent = 5)` adds a rounded-up safety margin.

A headcount below 1 throws `InvalidArgumentException`.

## Scope

A planning aid, not a quote, booking or availability statement. Confirm vehicles, prices and dates with the provider.

## Development

```
php tests/run.php
```
