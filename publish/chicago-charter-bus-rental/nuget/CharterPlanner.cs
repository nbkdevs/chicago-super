namespace ChicagoCharterBusRental;

/// <summary>A vehicle class in the Chicago charter fleet.</summary>
public sealed record Vehicle(string Key, string Label, int MinSeats, int MaxSeats)
{
    public static readonly Vehicle SuperCoach = new("super_coach", "SuperCoach", 50, 57);
    public static readonly Vehicle Coach = new("coach", "Coach Bus", 39, 44);
    public static readonly Vehicle SmallCoach = new("small_coach", "Small Coach Bus", 22, 28);
    public static readonly Vehicle SprinterVan = new("sprinter_van", "Executive Sprinter Van", 13, 15);
    public static readonly Vehicle PartyBus = new("party_bus", "Party Bus", 45, 45);
    public static readonly Vehicle Trolley = new("trolley", "Trolley", 30, 30);

    /// <summary>Standard coaches used by default, largest first.</summary>
    public static IReadOnlyList<Vehicle> Standard { get; } = new[] { SuperCoach, Coach, SmallCoach, SprinterVan };

    /// <summary>Every class, including the party bus and trolley.</summary>
    public static IReadOnlyList<Vehicle> All { get; } = new[] { SuperCoach, PartyBus, Coach, Trolley, SmallCoach, SprinterVan };

    /// <summary>Seat range as text, e.g. "39-44", or "45" for a single number.</summary>
    public string SeatRange => MinSeats == MaxSeats ? MaxSeats.ToString() : $"{MinSeats}-{MaxSeats}";
}

/// <summary>One line of a plan: <paramref name="Count"/> vehicles of one class.</summary>
public sealed record FleetLine(Vehicle Vehicle, int Count)
{
    public int Seats => Vehicle.MaxSeats * Count;

    public override string ToString() => $"{Count} x {Vehicle.Label} ({Vehicle.SeatRange} seats)";
}

/// <summary>The vehicles recommended for a headcount.</summary>
public sealed record FleetPlan(int Passengers, IReadOnlyList<FleetLine> Lines)
{
    public int VehicleCount => Lines.Sum(l => l.Count);

    public int TotalSeats => Lines.Sum(l => l.Seats);

    public int SpareSeats => TotalSeats - Passengers;

    public string Summary =>
        $"{string.Join(" + ", Lines)} = {TotalSeats} seats for {Passengers} passengers, {SpareSeats} spare";
}

/// <summary>
/// Group charter planning helpers: how many vehicles does a headcount need, and how many
/// seats are left over? Seat counts are the top of the published ranges. A planning aid only,
/// not a quote, a booking or a statement of availability.
/// </summary>
public static class CharterPlanner
{
    public const int MaxPlanPassengers = 5000;

    /// <summary>Vehicles of one class needed for <paramref name="passengers"/>.</summary>
    public static int VehiclesNeeded(int passengers, Vehicle vehicle)
    {
        CheckPassengers(passengers);
        return (passengers + vehicle.MaxSeats - 1) / vehicle.MaxSeats;
    }

    /// <summary>Headcount to plan for after adding <paramref name="percent"/> for late additions, rounded up.</summary>
    public static int HeadcountWithBuffer(int confirmed, int percent = 5)
    {
        CheckPassengers(confirmed);
        if (percent < 0)
        {
            throw new ArgumentOutOfRangeException(nameof(percent), "must not be negative");
        }

        return (confirmed * (100 + percent) + 99) / 100;
    }

    /// <summary>
    /// Fewest vehicles that seat <paramref name="passengers"/>, and among those the fewest spare seats.
    /// Uses the standard coaches unless <paramref name="vehicles"/> is given.
    /// </summary>
    public static FleetPlan RecommendFleet(int passengers, IEnumerable<Vehicle>? vehicles = null)
    {
        CheckPassengers(passengers);
        if (passengers > MaxPlanPassengers)
        {
            throw new ArgumentOutOfRangeException(nameof(passengers), $"must be at most {MaxPlanPassengers}");
        }

        var options = (vehicles ?? Vehicle.Standard).OrderByDescending(v => v.MaxSeats).ToList();
        if (options.Count == 0)
        {
            throw new ArgumentException("must not be empty", nameof(vehicles));
        }

        var limit = passengers + options[0].MaxSeats - 1;
        const int unreachable = 1 << 30;
        var fewest = Enumerable.Repeat(unreachable, limit + 1).ToArray();
        var pick = new Vehicle?[limit + 1];
        fewest[0] = 0;
        for (var s = 1; s <= limit; s++)
        {
            foreach (var v in options)
            {
                var from = s - v.MaxSeats;
                if (from >= 0 && fewest[from] + 1 < fewest[s])
                {
                    fewest[s] = fewest[from] + 1;
                    pick[s] = v;
                }
            }
        }

        var best = -1;
        for (var s = passengers; s <= limit; s++)
        {
            if (fewest[s] == unreachable)
            {
                continue;
            }

            if (best == -1 || fewest[s] < fewest[best])
            {
                best = s;
            }
        }

        var counts = new Dictionary<Vehicle, int>();
        for (var s = best; s > 0; s -= pick[s]!.MaxSeats)
        {
            counts[pick[s]!] = counts.GetValueOrDefault(pick[s]!) + 1;
        }

        var lines = options.Where(counts.ContainsKey).Select(v => new FleetLine(v, counts[v])).ToList();
        return new FleetPlan(passengers, lines);
    }

    private static void CheckPassengers(int passengers)
    {
        if (passengers < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(passengers), "must be at least 1");
        }
    }
}
