<?php

declare(strict_types=1);

namespace ChicagoSuperCoach\CharterBusRental;

use InvalidArgumentException;

/**
 * Group charter planning helpers for Chicago Charter Bus Rental: how many
 * vehicles does a headcount need, and how many seats are left over?
 *
 * Seat counts are the top of the ranges on the published fleet page. They are
 * a planning aid only, not a quote, a booking or a statement of availability.
 */
final class Resources
{
    public const HOMEPAGE = 'https://chicagosupercoachbus.com/';

    public const TITLE = 'Chicago Charter Bus Rental';

    public const MAX_PLAN_PASSENGERS = 5000;

    public static function homepage(): string
    {
        return self::HOMEPAGE;
    }

    /** Vehicles of one class needed for $passengers. */
    public static function vehiclesNeeded(int $passengers, Vehicle $vehicle): int
    {
        self::checkPassengers($passengers);

        return intdiv($passengers + $vehicle->maxSeats() - 1, $vehicle->maxSeats());
    }

    /** Headcount to plan for after adding $percent for late additions, rounded up. */
    public static function headcountWithBuffer(int $confirmed, int $percent = 5): int
    {
        self::checkPassengers($confirmed);
        if ($percent < 0) {
            throw new InvalidArgumentException('percent must not be negative');
        }

        return intdiv($confirmed * (100 + $percent) + 99, 100);
    }

    /**
     * Fewest vehicles that seat $passengers, and among those the fewest spare
     * seats. Uses the standard coaches unless $vehicles is given.
     *
     * @param list<Vehicle>|null $vehicles
     */
    public static function recommendFleet(int $passengers, ?array $vehicles = null): FleetPlan
    {
        self::checkPassengers($passengers);
        if ($passengers > self::MAX_PLAN_PASSENGERS) {
            throw new InvalidArgumentException('passengers must be at most ' . self::MAX_PLAN_PASSENGERS);
        }
        $options = $vehicles ?? Vehicle::standard();
        if ($options === []) {
            throw new InvalidArgumentException('vehicles must not be empty');
        }
        usort($options, static fn (Vehicle $a, Vehicle $b): int => $b->maxSeats() <=> $a->maxSeats());

        $limit = $passengers + $options[0]->maxSeats() - 1;
        $unreachable = PHP_INT_MAX >> 2;
        $fewest = array_fill(0, $limit + 1, $unreachable);
        $pick = array_fill(0, $limit + 1, null);
        $fewest[0] = 0;
        for ($s = 1; $s <= $limit; $s++) {
            foreach ($options as $v) {
                $from = $s - $v->maxSeats();
                if ($from >= 0 && $fewest[$from] + 1 < $fewest[$s]) {
                    $fewest[$s] = $fewest[$from] + 1;
                    $pick[$s] = $v;
                }
            }
        }

        $best = -1;
        for ($s = $passengers; $s <= $limit; $s++) {
            if ($fewest[$s] === $unreachable) {
                continue;
            }
            if ($best === -1 || $fewest[$s] < $fewest[$best]) {
                $best = $s;
            }
        }

        $counts = [];
        for ($s = $best; $s > 0; $s -= $pick[$s]->maxSeats()) {
            $key = $pick[$s]->value;
            $counts[$key] = ($counts[$key] ?? 0) + 1;
        }
        $lines = [];
        foreach ($options as $v) {
            if (isset($counts[$v->value])) {
                $lines[] = ['vehicle' => $v, 'count' => $counts[$v->value]];
            }
        }

        return new FleetPlan($passengers, $lines);
    }

    private static function checkPassengers(int $passengers): void
    {
        if ($passengers < 1) {
            throw new InvalidArgumentException('passengers must be at least 1');
        }
    }
}
