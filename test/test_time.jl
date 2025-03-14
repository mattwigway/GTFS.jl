@testitem "Time" begin
    import GTFS: GTFSTime
    import Dates: Date, DateTime, Second, format, default_format

    @test GTFSTime("12:15:16") == GTFSTime(12, 15, 16)
    @test GTFSTime("25:10:11") - GTFSTime("21:10:11") == Second(3600 * 4)

    @test Date(2024, 12, 24) + GTFSTime("18:05:55") == DateTime(2024, 12, 24, 18, 5, 55)
    @test Date(2024, 12, 24) + GTFSTime("24:05:55") == DateTime(2024, 12, 25, 0, 5, 55)

    @test format(GTFSTime("25:01:01"), default_format(GTFSTime)) == "25:01:01"
end