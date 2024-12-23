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
    if "primary_key" ∈ metadatakeys(table) && metadata(table, "primary_key") ∈ names(table)
        prefix!(table, metadata(table, "primary_key"), prefix)
    end

    if "foreign_keys" ∈ metadatakeys(table)
        for fkey in metadata(table, "foreign_keys")
            if fkey ∈ names(table)
                prefix!(table, fkey, prefix)
            end
        end
    end

end

function prefix!(table::DataFrame, col, prefix)
    table[!, col] = map(x -> "$(prefix)$(x)", table[!, col])
end

prefix!(_::Missing, _) = nothing