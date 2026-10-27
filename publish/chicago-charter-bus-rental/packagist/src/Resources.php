<?php

declare(strict_types=1);

namespace ChicagoSuperCoach\CharterBusRental;

/**
 * Official resource links for Chicago group charter transportation.
 *
 * @see https://chicagosupercoachbus.com/ Chicago Charter Bus Rental
 */
final class Resources
{
    public const HOMEPAGE = 'https://chicagosupercoachbus.com/';

    public const TITLE = 'Chicago Charter Bus Rental';

    public static function homepage(): string
    {
        return self::HOMEPAGE;
    }
}
