struct GTFSTime <: Dates.TimeType
    instant::Dates.Second
end

GTFSTime(hour, minute, second) = GTFSTime(Dates.Second((hour * 3600 + minute * 60 + second)))

GTFSTime(gtfstime::AbstractString) = GTFSTime(parse.(Int64, split(gtfstime, ":"))...)

GTFSTime(gtfstime::Dates.AbstractTime) = GTFSTime(convert(Dates.Second, gtfstime.instant))

Base.show(io::IO, t::GTFSTime) = Dates.format(io, t, Dates.default_format(GTFSTime))

"""
Add a date and GTFSTime to get a DateTime of service
"""
# DST handling: add time to "GTFS Midnight" i.e. noon - 12h
(+)(d::Date, t::GTFSTime) = DateTime(d, Time(12, 0, 0)) - Dates.Hour(12) + t.instant

(==)(t1::GTFSTime, t2::GTFSTime) = (t1.instant == t2.instant)

Base.isless(x::GTFSTime, y::GTFSTime) = x.instant < y.instant

Dates.default_format(_::Type{GTFSTime}) = dateformat"HH:MM:SS"

Dates.hour(t::GTFSTime) = Dates.value(t.instant) ÷ 3600
Dates.minute(t::GTFSTime) = (Dates.value(t.instant) % 3600) ÷ 60
Dates.second(t::GTFSTime) = Dates.value(t.instant) % 60

"""
Get active service IDs for a date
"""
function services_active(feed, date)

    cal_services = if !ismissing(feed.calendar)
        day_of_week = lowercase(Dates.dayname(date))
        Set(feed.calendar[
            # TODO days of weeks should be boolean
            feed.calendar.start_date .≤ date .&& feed.calendar.end_date .≥ date .&& feed.calendar[!, day_of_week] .== 1,
            :service_id
        ])
    else
        Set()
    end

    added_services, removed_services = if !ismissing(feed.calendar_dates)
        Set(feed.calendar_dates[feed.calendar_dates.date .== date .&& feed.calendar_dates.exception_type .== 1, :service_id]),
        Set(feed.calendar_dates[feed.calendar_dates.date .== date .&& feed.calendar_dates.exception_type .== 2, :service_id])
    else
        Set(), Set()
    end

    setdiff(cal_services ∪ added_services, removed_services)
end
