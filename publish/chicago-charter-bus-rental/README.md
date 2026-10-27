# Chicago Charter Bus Rental: publish assets

Small, useful packages and agent skills for group charter planning, built around the [Chicago Charter Bus Rental](https://chicagosupercoachbus.com/) fleet. Each folder is self-contained and has its own README and tests where it has code.

The packages share one idea: given a headcount, recommend the fewest vehicles from the published fleet seat sizes (SuperCoach 57, Coach Bus 44, Small Coach Bus 28, Executive Sprinter Van 15, plus Party Bus 45 and Trolley 30) and report spare seats. They are planning aids, not quotes, bookings or availability statements.

| Registry | Directory | Package | Notes |
|---|---|---|---|
| npm | `npm/` | `chicago-charter-bus-rental` | Published |
| PyPI | `pypi/` | `chicago-charter-bus-rental` | Published |
| crates.io | `crates/` | `chicago-charter-bus-rental` | Published |
| Docker Hub | `docker/` | `iamnazzal/chicago-charter-bus-rental` | Published |
| pub.dev | `pub_dev/` | `chicago_charter_bus_rental` | Fleet planner library with tests |
| RubyGems | `rubygems/` | `chicago_charter_bus_rental` | Fleet planner gem with tests, not published |
| Packagist | `packagist/` | `chicago-super-coach/chicago-charter-bus-rental` | Fleet planner library with tests, not published |
| NuGet | `nuget/` | `ChicagoCharterBusRental` | Fleet planner library with xunit tests, not published |
| Smithery | `smithery-ai/` | `chicago-group-travel` | Agent skill with a planner script and tests, not published |
| Snapcraft | `snapcraft/` | | Not published |

Run the tests per package:

```
dart test                                   # pub_dev/
ruby test/chicago_charter_bus_rental_test.rb # rubygems/
php tests/run.php                           # packagist/
dotnet test tests                           # nuget/
python3 -m unittest -q                      # smithery-ai/chicago-group-travel/scripts/
```

Browser packages live separately under `/browser`. Overall publishing status is in the repository's STATUS.md.
