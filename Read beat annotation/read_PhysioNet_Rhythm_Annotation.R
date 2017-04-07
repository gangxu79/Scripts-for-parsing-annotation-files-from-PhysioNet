library(tools)

###############################################################################
# customized parameters
###############################################################################
# set working directory
setwd(path.expand('~'))
setwd('./R/')

# file name
filename <- 'afdb04908_rhythm.txt'

# sample rate
fs = 250;

# assign customized variable type in PhysioNet definition
# https://www.physionet.org/physiobank/annotations.shtml
# assigned string should be in the list below
# '(AB','(AFIB','(AFL','(B','(BII','(IVR','(N','(NOD','(P','(PREX','(SBR','(SVTA','(T','(VFL','(VT'
CustomizedType <- c('(AFIB','(AFL')

# assign index between 1 ~ 24 in ECM Toolbox
CustomizedIndex <- c(21,22)



###############################################################################
# interpret annotation
###############################################################################
# read header
header <- readLines(filename, n = 1)

# get width for each variable
colwidth <- numeric(6)
colwidth[1] <- unlist(gregexpr('Sample #', header))-1
colwidth[2] <- unlist(gregexpr('Type', header))-colwidth[1]-1
colwidth[3] <- unlist(gregexpr('Sub', header))-sum(colwidth[1:2])-1
colwidth[4] <- unlist(gregexpr('Chan', header))-sum(colwidth[1:3])-1
colwidth[5] <- unlist(gregexpr('Num', header))-sum(colwidth[1:4])-1
colwidth[6] <- unlist(gregexpr('\t', header))-sum(colwidth[1:5])-1

# read every line of the file
content <- readLines(filename)

# remove header
content <- content[-1]

# create a variable named type with same length of content
type <- character(length(content))

# create a variable named rhythmchange with same length of content
rhythmchange <- character(length(content))

# create a variable named sampleindex with same length of content
sampleindex <- rep(NaN,length(content))

# beat and non-beat annotation definition
# https://www.physionet.org/physiobank/annotations.shtml
beat_annotation <- factor(levels = c('N','L','R','B','A','a','J','S','V','r','F','e','j','n','E','/','f','Q','?'))
nonbeat_annotation <- factor(levels = c('[','!',']','x','(',')','p','t','u','`','\'','^','|','~','+','s','T','*','D','=','\"','@'))
rhythm_change_annotation <- factor(levels = c('(AB','(AFIB','(AFL','(B','(BII','(IVR','(N','(NOD','(P','(PREX','(SBR','(SVTA','(T','(VFL','(VT'))

# read annotation and parse content iteratively
for (i in 1:length(content))
{
    # separate annotation and aux part with tab
    tmp <- unlist(strsplit(content[i], split = '\t'))
    
    # get annotation type variable at the 3rd column
    ann <- trimws(substr(tmp[1],sum(colwidth[1:2])+1,sum(colwidth[1:3])))
    
    # assign peak index if this is a beat annotation, ignor aux part for now
    if (ann %in% levels(beat_annotation))
        # beat annotation
    {
        type[i] <- ann
        peakindex[i] <- as.numeric(substr(tmp[1],colwidth[1]+1,sum(colwidth[1:2])))
    } else (ann %in% levels(nonbeat_annotation))
    # rhythm annotation
    {
        type[i] <- ann
        rhythmchange[i] <- tmp[2]
        tmpstr <- substr(tmp[1],colwidth[1]+1,sum(colwidth[1:2]))
        tmpstr <- unlist(strsplit(trimws(tmpstr),' '))
        tmpstr <- tmpstr[length(tmpstr)]
        sampleindex[i] <- as.numeric(tmpstr)
    }
}

# convert to customized format
# remove if first annotation is Normal
if (rhythmchange[1] == '(N')
{
    type <- type[-1]
    rhythmchange <- rhythmchange[-1]
    sampleindex <- sampleindex[-1]
}

# output variable
Custom_Annotation <- data.frame(type = rep(NaN,length(rhythmchange)*2),
                                index = rep(NaN,length(rhythmchange)*2))
idx <- 1

# loop the rhythm change annotation
for (i in 1:length(rhythmchange))
{
    # if annotation label is pre-defined and what we want
    if ((rhythmchange[i] %in% levels(rhythm_change_annotation)) & (rhythmchange[i] %in% CustomizedType))
    {
        # rhythm start from here
        Custom_Annotation$type[idx] <- CustomizedIndex[which(CustomizedType == rhythmchange[i])]
        Custom_Annotation$index[idx] <- sampleindex[i]
        idx <- idx + 1
        
        # rhythm end at here
        if (i < length(rhythmchange))
        {
            Custom_Annotation$type[idx] <- CustomizedIndex[which(CustomizedType == rhythmchange[i])]
            Custom_Annotation$index[idx] <- sampleindex[i+1]
            idx <- idx + 1
        }
    }
}

# remove NaN
Custom_Annotation <- Custom_Annotation[!is.nan(Custom_Annotation$type),]

# convert sample to second
Custom_Annotation$index <- Custom_Annotation$index/fs;

# write rhythm annotation into csv file
if (nrow(Custom_Annotation) > 0)
{
    write.table(Custom_Annotation,
                sep = ',',
                file = paste0(file_path_sans_ext(basename(filename)),
                              '.csv'),
                col.names = FALSE,
                row.names = FALSE,
                append = FALSE)
}
