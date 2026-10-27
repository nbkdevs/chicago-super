# chicago_charter_bus_rental

Group charter planning helpers for the [Chicago Charter Bus Rental](https://chicagosupercoachbus.com/) fleet: work out how many vehicles a headcount needs and how many seats are left over.

Seat counts are the top of the ranges published for each vehicle class: SuperCoach 57 (50-57), Coach Bus 44 (39-44), Small Coach Bus 28 (22-28), Executive Sprinter Van 15 (13-15), Party Bus 45 and Trolley 30.

```ruby
require "chicago_charter_bus_rental"

headcount = ChicagoCharterBusRental.headcount_with_buffer(80) # 84, +5% for late additions
plan = ChicagoCharterBusRental.recommend_fleet(headcount)
puts plan.summary
# 1 x SuperCoach (50-57 seats) + 1 x Small Coach Bus (22-28 seats)
# = 85 seats for 84 passengers, 1 spare

ChicagoCharterBusRental.vehicles_needed(headcount, ChicagoCharterBusRental::SUPER_COACH) # 2
```

- `recommend_fleet(passengers, vehicles: STANDARD)` returns the fewest vehicles that seat everyone and, among those, the fewest spare seats. Pass `vehicles: ChicagoCharterBusRental::ALL` to include the party bus and trolley.
- `vehicles_needed(passengers, vehicle)` is the simple round-up for one class.
- `headcount_with_buffer(confirmed, percent: 5)` adds a rounded-up safety margin.

A headcount below 1 raises `ArgumentError`.

## Scope

A planning aid, not a quote, booking or availability statement. Confirm vehicles, prices and dates with the provider.

## Development

```
ruby test/chicago_charter_bus_rental_test.rb
gem build chicago_charter_bus_rental.gemspec
```
