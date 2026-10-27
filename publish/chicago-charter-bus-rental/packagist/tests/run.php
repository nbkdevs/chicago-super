<?php

declare(strict_types=1);

// Dependency-free test runner: php tests/run.php
require __DIR__ . '/../src/Vehicle.php';
require __DIR__ . '/../src/FleetPlan.php';
require __DIR__ . '/../src/Resources.php';

use ChicagoSuperCoach\CharterBusRental\Resources;
use ChicagoSuperCoach\CharterBusRental\Vehicle;

$failures = 0;
$checks = 0;
function check(mixed $expected, mixed $actual, string $name): void
{
    global $failures, $checks;
    $checks++;
    if ($expected !== $actual) {
        $failures++;
        fwrite(STDERR, "FAIL $name: expected " . var_export($expected, true) . ', got ' . var_export($actual, true) . "\n");
    }
}
function throws(callable $fn, string $name): void
{
    try {
        $fn();
        check('exception', 'none', $name);
    } catch (InvalidArgumentException) {
        check(true, true, $name);
    }
}

check('https://chicagosupercoachbus.com/', Resources::homepage(), 'homepage');
check('Chicago Charter Bus Rental', Resources::TITLE, 'title');

check(1, Resources::vehiclesNeeded(57, Vehicle::SuperCoach), 'needed 57');
check(2, Resources::vehiclesNeeded(58, Vehicle::SuperCoach), 'needed 58');
check(3, Resources::vehiclesNeeded(100, Vehicle::Coach), 'needed 100 coach');
check(2, Resources::vehiclesNeeded(31, Vehicle::Trolley), 'needed trolley');
throws(fn () => Resources::vehiclesNeeded(0, Vehicle::Coach), 'needed zero');

check(105, Resources::headcountWithBuffer(100), 'buffer 100');
check(53, Resources::headcountWithBuffer(50), 'buffer 50 rounds up');
check(40, Resources::headcountWithBuffer(40, 0), 'buffer 0');
check(44, Resources::headcountWithBuffer(40, 10), 'buffer 10');
throws(fn () => Resources::headcountWithBuffer(10, -1), 'buffer negative');

$p = Resources::recommendFleet(12);
check(1, $p->vehicleCount(), 'small count');
check(Vehicle::SprinterVan, $p->lines[0]['vehicle'], 'small vehicle');
check(3, $p->spareSeats(), 'small spare');
check(Vehicle::SmallCoach, Resources::recommendFleet(28)->lines[0]['vehicle'], '28');
check(Vehicle::Coach, Resources::recommendFleet(29)->lines[0]['vehicle'], '29');
check(Vehicle::SuperCoach, Resources::recommendFleet(45)->lines[0]['vehicle'], '45');

$p = Resources::recommendFleet(86);
check(2, $p->vehicleCount(), '86 count');
check(88, $p->totalSeats(), '86 seats');
check('2 x Coach Bus (39-44 seats) = 88 seats for 86 passengers, 2 spare', $p->summary(), '86 summary');

for ($n = 1; $n <= 400; $n++) {
    $p = Resources::recommendFleet($n);
    check(true, $p->totalSeats() >= $n, "seated $n");
    check(intdiv($n + 56, 57), $p->vehicleCount(), "minimum vehicles $n");
    check(true, $p->spareSeats() < 57, "spare $n");
}

check(0, Resources::recommendFleet(30, [Vehicle::Trolley])->spareSeats(), 'trolley');
check(0, Resources::recommendFleet(45, Vehicle::all())->spareSeats(), 'party bus');
throws(fn () => Resources::recommendFleet(0), 'plan zero');
throws(fn () => Resources::recommendFleet(5001), 'plan too big');
throws(fn () => Resources::recommendFleet(10, []), 'plan empty');

echo $failures === 0 ? "OK ($checks checks)\n" : "$failures of $checks checks failed\n";
exit($failures === 0 ? 0 : 1);
