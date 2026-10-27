import unittest

from fleet_plan import VEHICLES, SPECIALTY, headcount_with_buffer, recommend_fleet, summary


class FleetPlanTest(unittest.TestCase):
    def test_small_group(self):
        self.assertEqual(recommend_fleet(12), ([("Executive Sprinter Van", 1)], 15))

    def test_smallest_fit(self):
        self.assertEqual(recommend_fleet(28)[0], [("Small Coach Bus", 1)])
        self.assertEqual(recommend_fleet(29)[0], [("Coach Bus", 1)])
        self.assertEqual(recommend_fleet(45)[0], [("SuperCoach", 1)])

    def test_fewest_vehicles_then_spare_seats(self):
        lines, total = recommend_fleet(86)
        self.assertEqual((lines, total), ([("Coach Bus", 2)], 88))
        self.assertEqual(
            summary(86, lines, total, VEHICLES),
            "2 x Coach Bus (39-44 seats) = 88 seats for 86 passengers, 2 spare",
        )

    def test_every_headcount_minimum_vehicles(self):
        for n in range(1, 401):
            lines, total = recommend_fleet(n)
            self.assertGreaterEqual(total, n)
            self.assertEqual(sum(c for _, c in lines), (n + 56) // 57, n)
            self.assertLess(total - n, 57)

    def test_specialty(self):
        self.assertEqual(recommend_fleet(45, True)[1], 45)

    def test_buffer(self):
        self.assertEqual(headcount_with_buffer(100), 105)
        self.assertEqual(headcount_with_buffer(50), 53)
        self.assertEqual(headcount_with_buffer(40, 0), 40)

    def test_validation(self):
        for bad in (0, 5001):
            with self.assertRaises(ValueError):
                recommend_fleet(bad)
        with self.assertRaises(ValueError):
            headcount_with_buffer(10, -1)


if __name__ == "__main__":
    unittest.main()
