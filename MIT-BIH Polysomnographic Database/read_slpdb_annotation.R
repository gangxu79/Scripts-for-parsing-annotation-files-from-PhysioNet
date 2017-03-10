library(dplyr)
library(tools)

# MIT-BIH Polysomnographic Database
# read sleep stages and scored events from annotation file

# aux	meaning
# W	subject is awake
# 1	sleep stage 1
# 2	sleep stage 2
# 3	sleep stage 3
# 4	sleep stage 4
# R	REM sleep
# H	Hypopnea
# HA	Hypopnea with arousal
# OA	Obstructive apnea
# X	Obstructive apnea with arousal
# CA	Central apnea
# CAA	Central apnea with arousal
# L	Leg movements
# LA	Leg movements with arousal
# A	Unspecified arousal
# MT	Movement time

# Annotation definition in ECM interface

# 0	Wake
# 1	Stage 1
# 2	Stage 2
# 3	Stage 3
# 4	Stage 4
# 5 REM
# 6	Unscored

# set current working folder
setwd('./')
rm(list = ls())
# read annotation text file from PhysioNet 
# St. Vincent's University Hospital / University College Dublin Sleep Apnea Database

# read file
filename <- 'https://physionet.org/atm/slpdb/slp03/st/0/e/rdann/e/annotations.txt'
ann <- readLines(filename)
# remove header
ann <- ann[-1]
nrow <- length(ann)
# constant
period <- 30
eventname <- c('Hypopnea',
               'Hypopnea with arousal',
               'Obstructive apnea',
               'Obstructive apnea with arousal',
               'Central apnea',
               'Central apnea with arousal',
               'Leg movements',
               'Leg movements with arousal',
               'Unspecified arousal',
               'Movement time')

# initialize data frame
allevents <- data.frame(H = logical(nrow),
                        HA = logical(nrow),
                        OA = logical(nrow),
                        X = logical(nrow),
                        CA = logical(nrow),
                        CAA = logical(nrow),
                        L = logical(nrow),
                        LA = logical(nrow),
                        A = logical(nrow),
                        MT = logical(nrow))
events <- data.frame(Type = character(),
                     TimeInSec = integer(),
                     Duration = integer(),
                     stringsAsFactors = FALSE)
sleepstages <- data.frame(stage = numeric(nrow))

for (i in 1:length(ann))
{
    strings <- unlist(strsplit(ann[i], split = '\t'))
    aux <- strings[2]

    # parse sleep stage
    tmpstr <- unlist(strsplit(aux, split = '\\s+'))
    stage <- tmpstr[1]
    if (stage == 'W')
    {
        sleepstages$stage[i] <- 0
    } else if (stage == '1')
    {
        sleepstages$stage[i] <- 1
    } else if (stage == '2')
    {
        sleepstages$stage[i] <- 2
    } else if (stage == '3')
    {
        sleepstages$stage[i] <- 3
    } else if (stage == '4')
    {
        sleepstages$stage[i] <- 4
    } else if (stage == 'R')
    {
        sleepstages$stage[i] <- 5
    } else
    {
        sleepstages$stage[i] <- 6
    }
    # parse scored events
    if (length(tmpstr) > 1)
    {
        for (j in 2:length(tmpstr))
        {
            if (tmpstr[j] == 'H')
            {
                allevents$H[i] = TRUE
            } else if (tmpstr[j] == 'HA')
            {
                allevents$HA[i] = TRUE
            } else if (tmpstr[j] == 'OA')
            {
                allevents$OA[i] = TRUE
            } else if (tmpstr[j] == 'X')
            {
                allevents$X[i] = TRUE
            } else if (tmpstr[j] == 'CA')
            {
                allevents$CA[i] = TRUE
            } else if (tmpstr[j] == 'CAA')
            {
                allevents$CAA[i] = TRUE
            } else if (tmpstr[j] == 'L')
            {
                allevents$L[i] = TRUE
            } else if (tmpstr[j] == 'LA')
            {
                allevents$LA[i] = TRUE
            } else if (tmpstr[j] == 'A')
            {
                allevents$A[i] = TRUE
            } else if (tmpstr[j] == 'MT')
            {
                allevents$MT[i] = TRUE
            }
        }
    }
}

# reorganize scored events
for (i in 1:ncol(allevents))
{
    lencod <- rle(allevents[,i])
    len <- lencod[['lengths']]
    val <- lencod[['values']]
    tidx <- which(val == TRUE)
    # if event exist
    if (length(tidx) > 0)
    {
        for (j in 1:length(tidx))
        {
            if (tidx[j] == 1)
            {
                starttime <- 0
            } else {
                starttime <- sum(len[1:(tidx[j]-1)])
            }
            # event name, start time, duration
            events[nrow(events)+1,] <- c(eventname[i], starttime*period, len[tidx[j]]*period)
        }
    }
}
# sort by time
events$TimeInSec <- as.integer(events$TimeInSec)
events$Duration <- as.integer(events$Duration)
events <- arrange(events, TimeInSec)

# write sleep stages to csv file
write.table(sleepstages,
            sep = ',',
            file = paste0(file_path_sans_ext(basename(filename)),
                          '_SleepStages.csv'),
            col.names = FALSE,
            row.names = FALSE,
            append = FALSE)

# write scored events to csv file
write.table(events,
            sep = ',',
            file = paste0(file_path_sans_ext(basename(filename)),
                          '_ScoredEvents.csv'),
            col.names = FALSE,
            row.names = FALSE,
            append = FALSE)
