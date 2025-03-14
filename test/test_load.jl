@testitem "gtfsdate_to_date" begin
    import Dates: Date

    @test GTFS.gtfsdate_to_date(20241224) == Date(2024, 12, 24)
    @test_throws ArgumentError GTFS.gtfsdate_to_date(20231530)
    # non-leap year
    @test_throws ArgumentError GTFS.gtfsdate_to_date(20250229)
    
    @test GTFS.gtfsdate_to_date(20240229) == Date(2024, 2, 29)
end