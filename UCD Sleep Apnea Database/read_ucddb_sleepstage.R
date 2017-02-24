# Annotation definition from ucddb database of Physionet

# 0	Wake
# 1	REM
# 2	Stage 1
# 3	Stage 2
# 4	Stage 3
# 5	Stage 4
# 6	Artifact
# 7	Indeterminate

# Annotation definition in ECM interface

# 0	Wake
# 1	Stage 1
# 2	Stage 2
# 3	Stage 3
# 4	Stage 4
# 5 REM
# 6	Unscored

rm(list = ls())
filename <- 'https://physionet.org/physiobank/database/ucddb/ucddb006_stage.txt'
ss <- read.csv(filename, col.names = 'Stage', header = FALSE)

for (i in 1:length(ss$Stage))
{
    if (ss$Stage[i] == 1)
    {
        ss$Stage[i] <- 5
    } else if (ss$Stage[i] == 2)
    {
        ss$Stage[i] <- 1
    } else if (ss$Stage[i] == 3)
    {
        ss$Stage[i] <- 2
    } else if (ss$Stage[i] == 4)
    {
        ss$Stage[i] <- 3
    } else if (ss$Stage[i] == 5)
    {
        ss$Stage[i] <- 4
    } else if (ss$Stage[i] == 7)
    {
        ss$Stage[i] <- 6
    }
}

# write to csv file
write.table(ss,
            sep = ',',
            file = paste0(file_path_sans_ext(basename(filename)),
                          '_SleepStages.csv'),
            col.names = FALSE,
            row.names = FALSE,
            append = FALSE)