summarizeTidefile <- function(tidefile) {

    # Read the start and end dates and times
    envVar <- rhdf5::h5read(tidefile, "hydro/input/envvar")
    startDate <- envVar[envVar$name=="START_DATE", "value"]
    startTime <- envVar[envVar$name=="START_TIME", "value"]
    endDate <- envVar[envVar$name=="END_DATE", "value"]
    endTime <- envVar[envVar$name=="END_TIME", "value"]
    timestep_min <- rhdf5::h5readAttributes(tidefile, "hydro")$'Time interval'

    startDatetime_PST <- lubridate::dmy_hm(paste0(startDate, startTime), tz="Etc/GMT+8")
    endDatetime_PST <- lubridate::dmy_hm(paste0(endDate, endTime), tz="Etc/GMT+8")

    return(list(startDatetime_PST=startDatetime_PST, endDatetime_PST=endDatetime_PST, timestep_min=timestep_min))
}
