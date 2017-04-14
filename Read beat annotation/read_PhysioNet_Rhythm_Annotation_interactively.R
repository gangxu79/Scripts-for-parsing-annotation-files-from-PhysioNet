library(tools)
library(tcltk2)

###############################################################################
# choose your file interactively
###############################################################################

inputfile <- tclvalue(tkgetOpenFile(filetypes = "{ {PhysioNet Rhythm Annotation Text Files} {.txt} }"))

###############################################################################
# interpret annotation
###############################################################################
if (inputfile == "")
{
    stop('Annotation interpretation cancelled by user.')
} else {
    print(inputfile)
}

# extract folder
inputfolder <- dirname(inputfile)

# extract file name
inputfilename <- file_path_sans_ext(basename(inputfile))

# sample rate
fs <- readline(prompt="Please enter the sample rate in Hz: ")
fs <- as.numeric(fs)
if (is.na(fs))
{
    stop('Invalid sample rate.')
}

# assign customized variable type in PhysioNet definition
# https://www.physionet.org/physiobank/annotations.shtml
# assigned string should be in the list below
# '(AB','(AFIB','(AFL','(B','(BII','(IVR','(N','(NOD','(P','(PREX','(SBR','(SVTA','(T','(VFL','(VT'


# input annotation type 
# comment out if you don't want input interactively
cat('String  Description
(AB     Atrial bigeminy
(AFIB   Atrial fibrillation
(AFL    Atrial flutter
(B      Ventricular bigeminy
(BII    2° heart block
(IVR    Idioventricular rhythm
(N      Normal sinus rhythm
(NOD    Nodal (A-V junctional) rhythm
(P      Paced rhythm
(PREX   Pre-excitation (WPW)
(SBR    Sinus bradycardia
(SVTA   Supraventricular tachyarrhythmia
(T      Ventricular trigeminy
(VFL    Ventricular flutter
(VT     Ventricular tachycardia')
CustomizedType <- readline(prompt="Please enter the annotation types without curly bracket you want to interpret separated by comma: ")
CustomizedType <- unlist(strsplit(CustomizedType,','))
CustomizedType <- trimws(CustomizedType)
CustomizedType <- paste0('(',CustomizedType)

# set types here and comment the last a few lines out
# CustomizedType <- c('(AFIB','(AFL')

# input annotation index in ECM toolbox
CustomizedIndex <- readline(prompt="Please enter the annotation indexes separated by comma: ")
CustomizedIndex <- unlist(strsplit(CustomizedIndex,','))
CustomizedIndex <- as.numeric(CustomizedIndex)

# set indexes here and comment the last a few lines out
# CustomizedIndex <- c(21,22)



###############################################################################
# interpret annotation
###############################################################################
# read header
header <- readLines(inputfile, n = 1)

# get width for each variable
colwidth <- numeric(6)
colwidth[1] <- unlist(gregexpr('Sample #', header))-1
colwidth[2] <- unlist(gregexpr('Type', header))-colwidth[1]-1
colwidth[3] <- unlist(gregexpr('Sub', header))-sum(colwidth[1:2])-1
colwidth[4] <- unlist(gregexpr('Chan', header))-sum(colwidth[1:3])-1
colwidth[5] <- unlist(gregexpr('Num', header))-sum(colwidth[1:4])-1
colwidth[6] <- unlist(gregexpr('\t', header))-sum(colwidth[1:5])-1

# read every line of the file
content <- readLines(inputfile)

# remove header
content <- content[-1]

# create a variable named peakindex with same length of content
peakindex <- rep(NaN,length(content))

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
    } else if (ann == '+')
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

# remove empty element in the variable rhythmchange and sampleindex
rhythmchange <- rhythmchange[rhythmchange!='']
sampleindex <- sampleindex[!is.na(sampleindex)]

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

# print message to show execution finished
print('Interpretation finished, please save variables into csv file.')

# write rhythm annotation into csv file
if (nrow(Custom_Annotation) > 0)
{
    outputfile <- tclvalue(tkgetSaveFile(initialfile = file.path(inputfolder,paste0(inputfilename,'.csv')),
                                         filetypes = "{ {Comma separated value files} {.csv} }"))
    if (outputfile == "")
    {
        stop('Annotation interpretation cancelled by user.')
    } else {
        write.table(Custom_Annotation,
                    sep = ',',
                    file = outputfile,
                    col.names = FALSE,
                    row.names = FALSE,
                    append = FALSE)
    }
    print(paste(outputfile, 'generated successfully.'))
}
