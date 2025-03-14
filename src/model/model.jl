"""
Represents a GTFS Feed, basically as a collection of data frames.
"""
mutable struct Feed
    agency::DataFrame
    routes::DataFrame
    trips::DataFrame
    stops::DataFrame
    stop_times::DataFrame
    calendar::Union{Missing, DataFrame}
    calendar_dates::Union{Missing, DataFrame}
    frequencies::Union{Missing, DataFrame}
    shapes::Union{Missing, DataFrame}
    #additional_files::Dict{String, DataFrame}
end

Base.show(io::IO, f::Feed) = print(io, "GTFS.Feed($(join(f.agency.agency_name, ", ", " and ")); $(nrow(f.routes)) routes, $(nrow(f.stops)) stops, $(nrow(f.trips)) trips)")
