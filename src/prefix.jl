function prefix!(f::Feed, prefix)
    prefix!(f.agency, prefix)
    prefix!(f.stops, prefix)
    prefix!(f.stop_times, prefix)
    prefix!(f.routes, prefix)
    prefix!(f.trips, prefix)
    prefix!(f.calendar, prefix)
    prefix!(f.calendar_dates, prefix)
    prefix!(f.frequencies, prefix)
    prefix!(f.shapes, prefix)
end

function prefix!(table::DataFrame, prefix)
    rename = collect(filter(x -> endswith(x, "_id") && x != "direction_id", names(table)))
    for col in rename
        table[!, col] = map(x -> "$(prefix)$(x)", table[!, col])
    end
end

# no-op for tables that are not present
prefix!(_::Missing, _) = nothing