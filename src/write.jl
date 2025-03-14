"""
    write(filename, gtfs)

Write a Feed to a GTFS file.
"""
function save(filename, feed)
    w = ZipFile.Writer(filename)

    f = ZipFile.addfile(w, "agency.txt")
    CSV.write(f, feed.agency, dateformat=dateformat"yyyymmdd")
    close(f)

    f = ZipFile.addfile(w, "routes.txt")
    CSV.write(f, feed.routes, dateformat=dateformat"yyyymmdd")
    close(f)

    f = ZipFile.addfile(w, "trips.txt")
    CSV.write(f, feed.trips, dateformat=dateformat"yyyymmdd")
    close(f)

    f = ZipFile.addfile(w, "stops.txt")
    CSV.write(f, feed.stops, dateformat=dateformat"yyyymmdd")
    close(f)

    f = ZipFile.addfile(w, "stop_times.txt")
    # no date format here as it would catch the times
    CSV.write(f, feed.stop_times)
    close(f)

    if !ismissing(feed.calendar)
        f = ZipFile.addfile(w, "calendar.txt")
        CSV.write(f, feed.calendar, dateformat=dateformat"yyyymmdd")
        close(f)
    end

    if !ismissing(feed.calendar_dates)
        f = ZipFile.addfile(w, "calendar_dates.txt")
        CSV.write(f, feed.calendar_dates, dateformat=dateformat"yyyymmdd")
        close(f)
    end

    if !ismissing(feed.frequencies)
        f = ZipFile.addfile(w, "frequencies.txt")
        # no date format here as it would catch the times
        CSV.write(f, feed.frequencies)
        close(f)
    end

    if !ismissing(feed.shapes)
        f = ZipFile.addfile(w, "shapes.txt")
        CSV.write(f, feed.shapes, dateformat=dateformat"yyyymmdd")
        close(f)
    end

    close(w)
end