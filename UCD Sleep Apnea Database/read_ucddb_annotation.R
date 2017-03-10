library(lubridate)
library(dplyr)
library(tools)
library(xlsx)

setwd(Sys.getenv("HOME"))
rm(list = ls())
# read record start time from subject detail spreadsheet file
filename <- './SubjectDetails.xls'
detail <- read.xlsx(filename, sheetIndex = 1, stringsAsFactors = FALSE)

# read annotation text file from PhysioNet 
# St. Vincent's University Hospital / University College Dublin Sleep Apnea Database
filename <- 'https://physionet.org/physiobank/database/ucddb/ucddb002_respevt.txt'
subjectid <- basename(filename)
subjectid <- unlist(strsplit(subjectid, split = '_'))
subjectid <- subjectid[1]

ann <- read.fwf(filename,
                header = FALSE,
                skip = 3,
                na.strings = '',
                strip.white = TRUE,
                stringsAsFactors = FALSE,
                col.names = c('Time',
                              'Type',
                              'PB/CS',
                              'Duration',
                              'Low',
                              '%Drop',
                              'Snore',
                              'Arousal',
                              'B/T Rate',
                              'B/T Change'),
                widths = c(10, 10, 5, 5, 11, 7, 6, 6, 10, 8))
# compensate from beginning
subidx <- match(subjectid, tolower(detail$Study.Number))
# convert HH:MM:SS to seconds
at <- as.integer(seconds(hms(ann$Time)))
st <- as.integer(seconds(hms(detail$PSG.Start.Time[subidx])))
timelength <- at - st
for (i in 1:length(timelength))
{
    if (timelength[i] < 0)
    {
      timelength[i] <- timelength[i] + 3600*24
    }
}
ann$TimeInSec <- timelength
# set factor variables
ann$Type <- as.factor(ann$Type)
ann$Snore <- factor(ann$Snore, 
                    levels = c('+', '-'), 
                    labels = c('+','-'))
ann$Arousal <- factor(ann$Arousal,
                      levels = c('+', '-'),
                      labels = c('+', '-'))
# export csv file with each annotation type
csvdata <- select(ann, Type, TimeInSec, Duration)
# write to file
write.table(csvdata,
            sep = ',',
            file = paste0(file_path_sans_ext(basename(filename)),
                          '_ScoredEvents.csv'),
            col.names = FALSE,
            row.names = FALSE,
            append = FALSE)

