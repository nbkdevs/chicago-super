<?php

declare(strict_types=1);

namespace ChicagoSuperCoach\CharterBusRental;

/**
 * A vehicle class in the Chicago charter fleet. Seats are the top of the
 * published range and are used as the capacity.
 */
enum Vehicle: string
{
    case SuperCoach = 'super_coach';
    case Coach = 'coach';
    case SmallCoach = 'small_coach';
    case SprinterVan = 'sprinter_van';
    case PartyBus = 'party_bus';
    case Trolley = 'trolley';

    public function label(): string
    {
        return match ($this) {
            self::SuperCoach => 'SuperCoach',
            self::Coach => 'Coach Bus',
            self::SmallCoach => 'Small Coach Bus',
            self::SprinterVan => 'Executive Sprinter Van',
            self::PartyBus => 'Party Bus',
            self::Trolley => 'Trolley',
        };
    }

    public function minSeats(): int
    {
        return match ($this) {
            self::SuperCoach => 50,
            self::Coach => 39,
            self::SmallCoach => 22,
            self::SprinterVan => 13,
            self::PartyBus => 45,
            self::Trolley => 30,
        };
    }

    public function maxSeats(): int
    {
        return match ($this) {
            self::SuperCoach => 57,
            self::Coach => 44,
            self::SmallCoach => 28,
            self::SprinterVan => 15,
            self::PartyBus => 45,
            self::Trolley => 30,
        };
    }

    /** Seat range as text, e.g. "39-44", or "45" for a single number. */
    public function seatRange(): string
    {
        return $this->minSeats() === $this->maxSeats()
            ? (string) $this->maxSeats()
            : $this->minSeats() . '-' . $this->maxSeats();
    }

    /**
     * Standard coaches used by default, largest first.
     *
     * @return list<Vehicle>
     */
    public static function standard(): array
    {
        return [self::SuperCoach, self::Coach, self::SmallCoach, self::SprinterVan];
    }

    /**
     * Every class, including the party bus and trolley.
     *
     * @return list<Vehicle>
     */
    public static function all(): array
    {
        return [
            self::SuperCoach, self::PartyBus, self::Coach,
            self::Trolley, self::SmallCoach, self::SprinterVan,
        ];
    }
}
