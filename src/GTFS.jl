module GTFS

import CSV, Dates
import Dates: @dateformat_str
import DataFrames: DataFrame, groupby, metadata, metadata!, metadatakeys, nrow, leftjoin
import ZipFile
import DataStructures: DefaultDict, counter, inc!
import DataFramesMeta: @chain, @groupby, @combine, @orderby, @subset, @select, @transform, Not
import Dates: Date, DateTime, Time
import Base: +, ==
import Missings: passmissing
import Geodesy: LatLon, euclidean_distance
import ShiftedArrays: lag, lead
import Compat: @compat

include("model/model.jl")
include("load.jl")
include("write.jl")
include("prefix.jl")
include("combine.jl")
include("patterns.jl")
include("time.jl")
include("simplify.jl")
include("clean.jl")

@compat public read, save, combine, find_patterns, calendars_to_frequencies, GTFSTime, minimum_stop_spacing!

end
