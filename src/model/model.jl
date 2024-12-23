"""
Represents a GTFS Feed, basically as a collection of data frames.
"""
struct Feed
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

