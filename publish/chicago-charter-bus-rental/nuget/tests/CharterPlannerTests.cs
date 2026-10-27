using ChicagoCharterBusRental;
using Xunit;

public class CharterPlannerTests
{
    [Fact]
    public void Metadata()
    {
        Assert.Equal("https://chicagosupercoachbus.com/", Resources.Homepage);
        Assert.Equal("Chicago Charter Bus Rental", Resources.Title);
    }

    [Fact]
    public void VehiclesNeededRoundsUp()
    {
        Assert.Equal(1, CharterPlanner.VehiclesNeeded(57, Vehicle.SuperCoach));
        Assert.Equal(2, CharterPlanner.VehiclesNeeded(58, Vehicle.SuperCoach));
        Assert.Equal(3, CharterPlanner.VehiclesNeeded(100, Vehicle.Coach));
        Assert.Equal(2, CharterPlanner.VehiclesNeeded(31, Vehicle.Trolley));
        Assert.Throws<ArgumentOutOfRangeException>(() => CharterPlanner.VehiclesNeeded(0, Vehicle.Coach));
    }

    [Fact]
    public void HeadcountWithBuffer()
    {
        Assert.Equal(105, CharterPlanner.HeadcountWithBuffer(100));
        Assert.Equal(53, CharterPlanner.HeadcountWithBuffer(50));
        Assert.Equal(40, CharterPlanner.HeadcountWithBuffer(40, 0));
        Assert.Equal(44, CharterPlanner.HeadcountWithBuffer(40, 10));
        Assert.Throws<ArgumentOutOfRangeException>(() => CharterPlanner.HeadcountWithBuffer(10, -1));
    }

    [Fact]
    public void SmallGroupsGetSmallestFit()
    {
        var plan = CharterPlanner.RecommendFleet(12);
        Assert.Equal(1, plan.VehicleCount);
        Assert.Equal(Vehicle.SprinterVan, plan.Lines[0].Vehicle);
        Assert.Equal(3, plan.SpareSeats);
        Assert.Equal(Vehicle.SmallCoach, CharterPlanner.RecommendFleet(28).Lines[0].Vehicle);
        Assert.Equal(Vehicle.Coach, CharterPlanner.RecommendFleet(29).Lines[0].Vehicle);
        Assert.Equal(Vehicle.SuperCoach, CharterPlanner.RecommendFleet(45).Lines[0].Vehicle);
    }

    [Fact]
    public void FewestVehiclesThenFewestSpareSeats()
    {
        var plan = CharterPlanner.RecommendFleet(86);
        Assert.Equal(2, plan.VehicleCount);
        Assert.Equal(88, plan.TotalSeats);
        Assert.Equal("2 x Coach Bus (39-44 seats) = 88 seats for 86 passengers, 2 spare", plan.Summary);
    }

    [Fact]
    public void EveryHeadcountIsSeatedWithMinimumVehicles()
    {
        for (var n = 1; n <= 400; n++)
        {
            var plan = CharterPlanner.RecommendFleet(n);
            Assert.True(plan.TotalSeats >= n, $"n={n}");
            Assert.Equal((n + 56) / 57, plan.VehicleCount);
            Assert.True(plan.SpareSeats < 57, $"n={n}");
        }
    }

    [Fact]
    public void SpecialtyVehiclesAndValidation()
    {
        Assert.Equal(0, CharterPlanner.RecommendFleet(30, new[] { Vehicle.Trolley }).SpareSeats);
        Assert.Equal(0, CharterPlanner.RecommendFleet(45, Vehicle.All).SpareSeats);
        Assert.Throws<ArgumentOutOfRangeException>(() => CharterPlanner.RecommendFleet(0));
        Assert.Throws<ArgumentOutOfRangeException>(() => CharterPlanner.RecommendFleet(5001));
        Assert.Throws<ArgumentException>(() => CharterPlanner.RecommendFleet(10, Array.Empty<Vehicle>()));
    }
}
