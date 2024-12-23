# Load GTFS

function load_gtfs(filename)
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
    
    metadata!(f.agency, "primary_key", "agency_id")
    metadata!(f.routes, "primary_key", "route_id")
    metadata!(f.routes, "foreign_keys", ("agency_id",))
    metadata!(f.trips, "primary_key", "trip_id")
    metadata!(f.trips, "foreign_keys", ("route_id", "service_id", "shape_id"))
    metadata!(f.stops, "primary_key", "stop_id")
    metadata!(f.stop_times, "foreign_keys", ("trip_id",))

    if !ismissing(f.calendar)
        metadata!(f.calendar, "primary_key", "service_id")
    end

    if !ismissing(f.calendar_dates)
        metadata!(f.calendar_dates, "primary_key", "service_id")
    end

    if !ismissing(f.frequencies)
        metadata!(f.frequencies, "primary_key", "trip_id")
    end

    return f
end