#' Extract transfer flows and stages for specified transfer names
#'
#' Extracts transfer flows for a list of tidefiles and transfer names.
#' The data are saved in *.csv files in the specified output directory.
#'
#' @param tidefiles List of full paths to tidefiles
#' @param transferNames List of transfer names
#' @param outputDir Full path to the output directory
#'
#' @return None
#' @export
#'
#' @examples
#' \dontrun{
#' extractTransferFlows(c(system.file("extdata", "hist_v82.h5", package="dsm2utils", mustWork=TRUE)),
#'              c("if_337"), ".")
#' }
extractTransferFlows <- function(tidefiles, transferNames, outputDir) {

    dir.create(outputDir, showWarnings=F, recursive=T)
    for(transferName in transferNames) {

        cat("Processing transfer", transferName, "\n")

        transferFlowsList <- list()
        for(i in 1:length(tidefiles)){
            tidefile <- tidefiles[i]

            thisTransfer <- rhdf5::h5read(tidefile, "/hydro/input/transfer")
            thisCol <- which(thisTransfer$name==transferName)

            if(length(thisCol)!=1) {
                stop(paste("Error in looking up transfer name", transferName))
            }

            thisTransferFlows <- rhdf5::h5read(tidefile, "/hydro/data/transfer flow")

            # Read the start and end dates and times from the transfer flow attributes
            transferFlowAttrib <- rhdf5::h5readAttributes(tidefile, "/hydro/data/transfer flow")
            rhdf5::h5closeAll()
            if(grepl("min", transferFlowAttrib$interval)) {
                timeStep_min <- as.numeric(gsub("min", "", transferFlowAttrib$interval))
            } else if(grepl("hour", transferFlowAttrib$interval)) {
                timeStep_min <- as.numeric(gsub("hour", "", transferFlowAttrib$interval))*60
            }

            startDatetime <- lubridate::ymd_hms(transferFlowAttrib$start_time, tz="Etc/GMT+8")
            timeSteps <- seq(startDatetime, by=paste0(timeStep_min, " min"), length=dim(thisTransferFlows)[2])

            transferFlowsList[[i]] <- data.frame(datetime_PST=timeSteps,
                                                transferFlow=thisTransferFlows[thisCol, ],
                                                tidefile=basename(tidefile))

        }
        transferFlows <- dplyr::bind_rows(transferFlowsList)

        # Convert datetimes to characters for consistent formatting in the output file
        transferFlows$datetime_PST <- strftime(transferFlows$datetime_PST, format="%Y-%m-%d %H:%M:%S", tz="Etc/GMT+8")

        write.csv(transferFlows, file=file.path(outputDir, paste0("transferFlows_", transferName, ".csv")), row.names=F)
    }
}

