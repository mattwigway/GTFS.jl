# Load GTFS

function read(filename)
    inp = ZipFile.Reader(filename)

    feed_files = DefaultDict(missing, Dict{String, Union{Missing, DataFrame}}(map(inp.files) do f
        f.name => CSV.read(f, DataFrame)
    end))

    close(inp)

    ismissing(feed_files["agency.txt"]) && error("agency.txt not found!")
    ismissing(feed_files["routes.txt"]) && error("routes.txt not found!")
    ismissing(feed_files["trips.txt"]) && error("trips.txt not found!")
    ismissing(feed_files["stops.txt"]) && error("stops.txt not found!")
    ismissing(feed_files["stop_times.txt"]) && error("stop_times.txt not found!")

    eltype(feed_files["stop_times.txt"].stop_sequence) <: Integer || error("non-integer stop sequences!")


    f = Feed(
        feed_files["agency.txt"],
        feed_files["routes.txt"],
        feed_files["trips.txt"],
        feed_files["stops.txt"],
        feed_files["stop_times.txt"],
        feed_files["calendar.txt"],
        feed_files["calendar_dates.txt"],
        feed_files["frequencies.txt"],
        feed_files["shapes.txt"]
        #Dict(filter(f -> f ∉ ["agency.txt", "routes.txt", "trips.txt", "stops.txt", "stop_times.txt", "shapes.txt"], pairs(feed_files)))
    )

    f.stop_times.arrival_time = passmissing(GTFSTime).(f.stop_times.arrival_time)
    f.stop_times.departure_time = passmissing(GTFSTime).(f.stop_times.departure_time)

    if !ismissing(f.calendar)
        f.calendar.start_date = gtfsdate_to_date.(f.calendar.start_date)
        f.calendar.end_date = gtfsdate_to_date.(f.calendar.end_date)
        metadata!(f.calendar, "primary_key", "service_id")
    end

    if !ismissing(f.calendar_dates)
        f.calendar_dates.date = gtfsdate_to_date.(f.calendar_dates.date)
        metadata!(f.calendar_dates, "primary_key", "service_id")
    end

    if !ismissing(f.frequencies)
        metadata!(f.frequencies, "primary_key", "trip_id")
    end

    if !ismissing(f.shapes)
        metadata!(f.shapes, "primary_key", "shape_id")
    end

    metadata!(f.agency, "primary_key", "agency_id")
    metadata!(f.routes, "primary_key", "route_id")
    metadata!(f.routes, "foreign_keys", ("agency_id",))
    metadata!(f.trips, "primary_key", "trip_id")
    metadata!(f.trips, "foreign_keys", ("route_id", "service_id", "shape_id"))
    metadata!(f.stops, "primary_key", "stop_id")
    metadata!(f.stop_times, "foreign_keys", ("trip_id", "stop_id"))

    return f
end

"Convert a GTFS integer date into a Date object"
function gtfsdate_to_date(gtfsdate)
    year = gtfsdate ÷ 10000
    month = (gtfsdate % 10000) ÷ 100
    day = gtfsdate % 100

    return Date(year, month, day)
end