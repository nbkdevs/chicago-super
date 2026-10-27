<?php

declare(strict_types=1);

namespace ChicagoSuperCoach\CharterBusRental;

/**
 * The vehicles recommended for a headcount.
 */
final class FleetPlan
{
    /**
     * @param array<int, array{vehicle: Vehicle, count: int}> $lines largest vehicles first
     */
    public function __construct(
        public readonly int $passengers,
        public readonly array $lines,
    ) {
    }

    public function vehicleCount(): int
    {
        return array_sum(array_column($this->lines, 'count'));
    }

    public function totalSeats(): int
    {
        $seats = 0;
        foreach ($this->lines as $line) {
            $seats += $line['vehicle']->maxSeats() * $line['count'];
        }

        return $seats;
    }

    public function spareSeats(): int
    {
        return $this->totalSeats() - $this->passengers;
    }

    public function summary(): string
    {
        $parts = array_map(
            static fn (array $l): string => sprintf(
                '%d x %s (%s seats)',
                $l['count'],
                $l['vehicle']->label(),
                $l['vehicle']->seatRange()
            ),
            $this->lines
        );

        return sprintf(
            '%s = %d seats for %d passengers, %d spare',
            implode(' + ', $parts),
            $this->totalSeats(),
            $this->passengers,
            $this->spareSeats()
        );
    }

    public function __toString(): string
    {
        return $this->summary();
    }
}
