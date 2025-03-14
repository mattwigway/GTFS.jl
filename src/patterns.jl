struct Pattern
    stops::Vector{String}
    trips::Vector{String}
    route::String
    direction::Union{Int32, Missing}
end

function find_patterns(feed)
    trip_pattern = @chain feed.stop_times begin
        leftjoin(feed.trips, on=:trip_id)
        @orderby(:route_id, :direction_id, :trip_id, :stop_sequence)
        @groupby(:route_id, :direction_id, :trip_id)
        @combine(:stops = Ref(collect(:stop_id)))
    end

    patterns = Pattern[]

    for grp in groupby(trip_pattern, [:stops, :route_id, :direction_id])
        push!(patterns, Pattern(collect(first(grp.stops)), collect(grp.trip_id), first(grp.route_id), first(grp.direction_id)))
    end

    return patterns
end