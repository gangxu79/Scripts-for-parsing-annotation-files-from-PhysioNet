library(lubridate)
library(dplyr)
library(tools)

setwd('./')
rm(list = ls())
# read annotation text file from PhysioNet 
# St. Vincent's University Hospital / University College Dublin Sleep Apnea Database
filename <- 'https://physionet.org/physiobank/database/ucddb/ucddb006_respevt.txt'
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
# convert HH:MM:SS to seconds
ann$TimeInSec <- as.integer(seconds(hms(ann$Time)))
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

