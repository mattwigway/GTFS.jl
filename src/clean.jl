"""
Enforce minimum stop spacing of m meters.
"""
function minimum_stop_spacing!(gtfs, m)
    sort!(gtfs.stop_times, [:trip_id, :stop_sequence])

    st = leftjoin(gtfs.stop_times, gtfs.stops[!, [:stop_id, :stop_lat, :stop_lon]], on=:stop_id)

    st.dist_from_prev = ifelse.(
        coalesce.(st.trip_id .== lag(st.trip_id), false),
        euclidean_distance.(
            LatLon{Float64}.(st.stop_lat, st.stop_lon),
            LatLon{Float64}.(lag(st.stop_lat; default=0.0), lag(st.stop_lon, default=0.0))
        ),
        missing
    )

    st = @chain st begin
        @subset ismissing.(:dist_from_prev) .|| :dist_from_prev .> m
        @select Not([:dist_from_prev, :stop_lat, :stop_lon])
    end

    # clean up timepoints in case last stop was removed
    if "timepoint" in names(st)
        st[
            coalesce.(st.trip_id .≠ lag(st.trip_id), true) .||
            coalesce.(st.trip_id .≠ lead(st.trip_id), true),
            :timepoint] .= 1
    end

    gtfs.stop_times = st
end