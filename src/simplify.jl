
"""
    calendars_to_frequencies(gtfs, dates, periods)

For each date->day pair, find the most common pattern for each route in each direction (or, if the GTFS)
"""
function calendars_to_frequencies(gtfs, dates, periods)
    patterns = find_patterns(gtfs)

    new_trips = nothing
    new_stop_times = nothing
    frequencies = []
    calendar = []

    service_idx = 1
    trip_idx = 1

    for (date, days) in dates
        service_id = "service_$service_idx"
        service_idx += 1
        services = GTFS.services_active(gtfs, date)

        for (pstart, pend) in periods
            pstart = GTFSTime(pstart)
            pend = GTFSTime(pend)

            # find the most popular pattern by period, route, and direction
            most_popular = Dict{Tuple{String, Union{Int32, Missing}}, Tuple{Pattern, Int64}}()

            for pattern in patterns
                count_in_period = 0
                for trip in pattern.trips
                    if first(gtfs.trips[gtfs.trips.trip_id .== trip, :service_id]) ∈ services
                        start_time = get_trip_start_time(gtfs, trip)
                        if start_time ≥ pstart && start_time ≤ pend
                            count_in_period += 1
                        end
                    end
                end

                if !haskey(most_popular, (pattern.route, pattern.direction)) || most_popular[(pattern.route, pattern.direction)][2] < count_in_period
                    most_popular[(pattern.route, pattern.direction)] = (pattern, count_in_period)
                end
            end

            for (pattern, count) ∈ values(most_popular)
                if count == 0
                    continue
                end

                trip_id = "trip_$trip_idx"
                trip_idx += 1

                trip = gtfs.trips[gtfs.trips.trip_id .== first(pattern.trips), :]
                trip.trip_id .= trip_id
                trip.service_id .= service_id

                stop_times = gtfs.stop_times[gtfs.stop_times.trip_id .== first(pattern.trips), :]
                sort!(stop_times, :stop_sequence)
                base_time = first(stop_times.departure_time)
                stop_times.arrival_time = map(a -> ismissing(a) ? missing : GTFSTime(a - base_time), stop_times.arrival_time)
                stop_times.departure_time = map(a -> ismissing(a) ? missing : GTFSTime(a - base_time), stop_times.departure_time)
                stop_times.trip_id .= trip_id

                if isnothing(new_trips)
                    new_trips = trip
                    new_stop_times = stop_times
                else
                    new_trips = vcat(new_trips, trip)
                    new_stop_times = vcat(new_stop_times, stop_times)
                end

                push!(frequencies, (
                    trip_id=trip_id,
                    start_time=pstart,
                    end_time=pend,
                    headway_secs = Dates.value(convert(Dates.Second, pend - pstart)) ÷ count,
                    exact_times = 0
                ))
            end
        end

        # create the calendar
        push!(calendar, (
            service_id=service_id,
            monday=convert(Int64, "monday" ∈ days),
            tuesday=convert(Int64, "tuesday" ∈ days),
            wednesday=convert(Int64, "wednesday" ∈ days),
            thursday=convert(Int64, "thursday" ∈ days),
            friday=convert(Int64, "friday" ∈ days),
            saturday=convert(Int64, "saturday" ∈ days),
            sunday=convert(Int64, "sunday" ∈ days),
            start_date=Date(1980, 1, 1),
            end_date=Date(2099, 12, 31)
        ))
    end

    return Feed(
        gtfs.agency,
        gtfs.routes,
        new_trips,
        gtfs.stops,
        new_stop_times,
        DataFrame(calendar),
        missing,
        DataFrame(frequencies),
        gtfs.shapes
    )
end

function get_trip_start_time(gtfs, trip_id)
    result = @chain gtfs.stop_times begin
        @subset :trip_id .== trip_id
        @subset :stop_sequence .== minimum(:stop_sequence)
        @select :departure_time
    end

    return first(result.departure_time)
end