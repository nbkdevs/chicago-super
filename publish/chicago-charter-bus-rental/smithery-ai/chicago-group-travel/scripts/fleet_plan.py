#!/usr/bin/env python3
"""Recommend vehicles for a Chicago group charter headcount.

Usage: python3 fleet_plan.py PASSENGERS [--buffer PERCENT] [--all]

Seat counts are the top of the published ranges: SuperCoach 57 (50-57),
Coach Bus 44 (39-44), Small Coach Bus 28 (22-28), Executive Sprinter Van 15
(13-15), Party Bus 45, Trolley 30. --all adds the party bus and trolley.
A planning aid only: not a quote, booking or availability statement.
"""
import argparse

VEHICLES = {  # label: (min seats, max seats), standard coaches first
    "SuperCoach": (50, 57),
    "Coach Bus": (39, 44),
    "Small Coach Bus": (22, 28),
    "Executive Sprinter Van": (13, 15),
}
SPECIALTY = {"Party Bus": (45, 45), "Trolley": (30, 30)}
MAX_PASSENGERS = 5000


def seat_range(lo_hi):
    lo, hi = lo_hi
    return str(hi) if lo == hi else f"{lo}-{hi}"


def headcount_with_buffer(confirmed, percent=5):
    if confirmed < 1:
        raise ValueError("passengers must be at least 1")
    if percent < 0:
        raise ValueError("percent must not be negative")
    return (confirmed * (100 + percent) + 99) // 100


def recommend_fleet(passengers, include_specialty=False):
    """Fewest vehicles that seat everyone, then fewest spare seats.

    Returns (lines, total_seats) where lines is [(label, count), ...].
    """
    if passengers < 1:
        raise ValueError("passengers must be at least 1")
    if passengers > MAX_PASSENGERS:
        raise ValueError(f"passengers must be at most {MAX_PASSENGERS}")
    table = dict(VEHICLES)
    if include_specialty:
        table.update(SPECIALTY)
    options = sorted(table, key=lambda k: -table[k][1])
    limit = passengers + table[options[0]][1] - 1
    unreachable = 1 << 30
    fewest = [unreachable] * (limit + 1)
    pick = [None] * (limit + 1)
    fewest[0] = 0
    for s in range(1, limit + 1):
        for label in options:
            frm = s - table[label][1]
            if frm >= 0 and fewest[frm] + 1 < fewest[s]:
                fewest[s] = fewest[frm] + 1
                pick[s] = label
    best = None
    for s in range(passengers, limit + 1):
        if fewest[s] != unreachable and (best is None or fewest[s] < fewest[best]):
            best = s
    counts = {}
    s = best
    while s > 0:
        counts[pick[s]] = counts.get(pick[s], 0) + 1
        s -= table[pick[s]][1]
    return [(k, counts[k]) for k in options if k in counts], best


def summary(passengers, lines, total, table):
    parts = [f"{n} x {k} ({seat_range(table[k])} seats)" for k, n in lines]
    return f"{' + '.join(parts)} = {total} seats for {passengers} passengers, {total - passengers} spare"


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("passengers", type=int)
    ap.add_argument("--buffer", type=int, default=0, help="percent to add for late additions")
    ap.add_argument("--all", action="store_true", help="include party bus and trolley")
    a = ap.parse_args()
    n = headcount_with_buffer(a.passengers, a.buffer) if a.buffer else a.passengers
    lines, total = recommend_fleet(n, a.all)
    print(summary(n, lines, total, {**VEHICLES, **SPECIALTY}))
