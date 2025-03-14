"""
Combine several GTFS feeds together. Accepts either varargs or feeds,
or pairs of prefix => feed
"""
function combine(feeds...)
    to_stack = Feed[]

    for (i, feedpair) in enumerate(feeds)
        id, feed = get_feed_and_id(feedpair, i)
        feed = deepcopy(feed)
        prefix!(feed, id)
        push!(to_stack, feed)
    end

    Feed(
        combine_tables(to_stack, :agency),
        combine_tables(to_stack, :routes),
        combine_tables(to_stack, :trips),
        combine_tables(to_stack, :stops),
        combine_tables(to_stack, :stop_times),
        combine_tables(to_stack, :calendar),
        combine_tables(to_stack, :calendar_dates),
        combine_tables(to_stack, :frequencies),
        combine_tables(to_stack, :shapes)
    )
end

function combine_tables(feeds, table)
    tables = collect(skipmissing(map(f -> getfield(f, table), feeds)))

    if isempty(tables)
        return missing
    else
        allcols = Set{String}()

        for table in tables
            for name in names(table)
                push!(allcols, name)
            end
        end

        for table in tables
            for col in allcols
                if col ∉ names(table)
                    table[!, col] .= missing
                end
            end
        end

        result = vcat(tables...)

        for table in tables
            for (k, v) in metadata(table)
                metadata!(result, k, v)
            end
        end

        return result
    end
end

get_feed_and_id(f::Pair{<:Any, Feed}, _) = "$(f[1]):", f[2]
get_feed_and_id(f::Feed, i) = "$(i):"