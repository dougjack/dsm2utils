#' Extract flows and stages for specified external channel numbers
#'
#' Extracts flows and stages for a list of tidefiles and external channel
#' numbers. The data are saved in *.csv files in the specified output directory.
#' Time series plots are also created.
#'
#' @param tidefiles List of full paths to tidefiles
#' @param channelNums List of external channel numbers
#' @param outputDir Full path to the output directory
#' @param figWidth Figure width in inches. Default = 10
#' @param figHeight Figure height in inches. Default = 5
#'
#' @return None
#' @export
#'
#' @examples
#' \dontrun{
#' extractFlows(c(system.file("extdata", "hist_v82.h5", package="dsm2utils", mustWork=TRUE)),
#'              c(7), ".")
#' }
extractFlows <- function(tidefiles, channelNums, outputDir, figWidth=10, figHeight=5) {

    dir.create(outputDir, showWarnings=F, recursive=T)
    for(channelNum in channelNums) {

        cat("Processing channelNum", channelNum, "\n")

        DSM2flowList <- list()
        DSM2stageList <- list()
        for(i in 1:length(tidefiles)){
            tidefile <- tidefiles[i]

            thisChannelFlows <- rhdf5::h5read(tidefile, "/hydro/data/channel flow")
            thisChannelStages <- rhdf5::h5read(tidefile, "/hydro/data/channel stage")

            # Read the (external) channel numbers
            channelNums = rhdf5::h5read(tidefile, "/hydro/geometry/channel_number")
            rhdf5::h5closeAll()
            channelIndex <- which(channelNums==channelNum)

            # Read the start and end dates and times from the channel flow attributes
            channelFlowAttrib <- rhdf5::h5readAttributes(tidefile, "/hydro/data/channel flow")
            rhdf5::h5closeAll()
            if(grepl("min", channelFlowAttrib$interval)) {
                timeStep_min <- as.numeric(gsub("min", "", channelFlowAttrib$interval))
            } else if(grepl("hour", channelFlowAttrib$interval)) {
                timeStep_min <- as.numeric(gsub("hour", "", channelFlowAttrib$interval))*60
            }

            startDatetime <- lubridate::ymd_hms(channelFlowAttrib$start_time, tz="Etc/GMT+8")
            timeSteps <- seq(startDatetime, by=paste0(timeStep_min, " min"), length=dim(thisChannelFlows)[3])

            DSM2flowList[[i]] <- data.frame(datetime_PST=timeSteps,
                                            upFlow=thisChannelFlows[1, channelIndex, ],
                                            downFlow=thisChannelFlows[2, channelIndex, ],
                                            tidefile=basename(tidefile))

            DSM2stageList[[i]] <- data.frame(datetime_PST=timeSteps,
                                             upStage=thisChannelStages[1, channelIndex, ],
                                             downStage=thisChannelStages[2, channelIndex, ],
                                             tidefile=basename(tidefile))
        }
        DSM2flows <- dplyr::bind_rows(DSM2flowList)
        DSM2stages <- dplyr::bind_rows(DSM2stageList)

        # Convert datetimes to characters for consistent formatting in the output file
        DSM2flows$datetime_PST <- strftime(DSM2flows$datetime_PST, format="%Y-%m-%d %H:%M:%S", tz="Etc/GMT+8")
        DSM2stages$datetime_PST <- strftime(DSM2stages$datetime_PST, format="%Y-%m-%d %H:%M:%S", tz="Etc/GMT+8")

        write.csv(DSM2flows, file=file.path(outputDir, paste0("DSM2flows_e", channelNum, ".csv")), row.names=F)
        write.csv(DSM2stages, file=file.path(outputDir, paste0("DSM2stages_e", channelNum, ".csv")), row.names=F)

        # Convert datetimes back to POSIXct
        DSM2flows$datetime_PST <- lubridate::ymd_hms(DSM2flows$datetime_PST)
        DSM2stages$datetime_PST <- lubridate::ymd_hms(DSM2stages$datetime_PST)

        DSM2flows <- DSM2flows %>% tidyr::pivot_longer(cols=c("downFlow", "upFlow"), names_to="node", values_to="flow")
        DSM2stages <- DSM2stages %>% tidyr::pivot_longer(cols=c("downStage", "upStage"), names_to="node", values_to="stage")

        p <- ggplot(DSM2flows) + geom_line(aes(x=datetime_PST, y=flow, group=tidefile, color=tidefile)) +
            facet_grid(node~.) +
            labs(title=paste0("external channel ", channelNum)) +
            scale_x_datetime() +
            theme_light()
        ggsave(file.path(outputDir, paste0("DSM2flows_e", channelNum, ".png")), width=figWidth, height=figHeight)

        p <- ggplot(DSM2stages) + geom_line(aes(x=datetime_PST, y=stage, group=tidefile, color=tidefile)) +
            facet_grid(node~.) +
            labs(title=paste0("external channel ", channelNum)) + theme_light()
        ggsave(file.path(outputDir, paste0("DSM2stages_e", channelNum, ".png")), width=figWidth, height=figHeight)
    }
}

