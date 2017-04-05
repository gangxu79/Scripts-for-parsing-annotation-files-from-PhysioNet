library(tools)
library(tcltk2)

###############################################################################
# choose your file interactively
###############################################################################

inputfile <- tclvalue(tkgetOpenFile(filetypes = "{ {PhysioNet Beat Annotation Text Files} {.txt} }"))

###############################################################################
# interpret annotation
###############################################################################
if (inputfile == "")
{
    stop('Annotation interpretation cancelled by user.')
}

# extract folder
inputfolder <- dirname(inputfile)

# extract file name
inputfilename <- file_path_sans_ext(basename(inputfile))

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

# create a variable named type with same length of content
type <- character(length(content))

# create a variable named peakindex with same length of content
peakindex <- rep(NaN,length(content))

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
        tmpstr <- substr(tmp[1],colwidth[1]+1,sum(colwidth[1:2]))
        tmpstr <- unlist(strsplit(trimws(tmpstr),' '))
        tmpstr <- tmpstr[length(tmpstr)]
        peakindex[i] <- as.numeric(tmpstr)
    }
}

# only keep valid beat annotation values
peakindex <- na.omit(peakindex)

# write peak index into csv file
if (length(peakindex) > 0)
{
    outputfile <- tclvalue(tkgetSaveFile(initialfile = file.path(inputfolder,paste0(inputfilename,'_beat.csv')),
                                         filetypes = "{ {Comma separated value files} {.csv} }"))
    if (outputfile == "")
    {
        stop('Annotation interpretation cancelled by user.')
    } else {
        write.table(peakindex,
                    sep = ',',
                    file = outputfile,
                    col.names = FALSE,
                    row.names = FALSE,
                    append = FALSE)
    }
    print(paste(outputfile, 'generated successfully.'))
}

