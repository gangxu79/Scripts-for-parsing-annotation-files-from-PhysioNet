# Scripts for parsing annotation text file from PhysioNet

This folder contains all the scripts parsing **annotation** files from [PhysioNet](http://www.physionet.org).
The main purpose of these scripts is to parse different format of the annotation text file from different PhysioNet database, and save it into csv (comma separated values) format.

# csv format definition
The csv format for sleep stage contains only one column data of numeric values, which indicates scored sleep stages.
* 0	Wake
* 1	Stage 1
* 2	Stage 2
* 3	Stage 3
* 4	Stage 4
* 5 REM
* 6	Unscored
The csv format for scored events contains 3 columns with variable type of character, numeric and numeric.

### Example:

Type          |   Start Time     |     Duration
--------------|------------------|-----------------
Apnea         |   18200          |     30
Leg Movement  |   19020          |     10


# Platform
Each folder contains script for a specific database. 
All the scripts were coded in **R language**. You can download [R software](https://www.r-project.org/) to run these codes.
**RStudio**(https://www.rstudio.com/), which is an integrated development environment (IDE) for R, also strongly recommanded to be downloaded on your computer for your convenience.

# Steps
1. Download and install latest version of R (https://cloud.r-project.org/) for your operating system.
2. Download and install latest version of RStudio (https://www.rstudio.com/products/rstudio/download/) for your operating system.
3. Download script from the GitHub folder for the database you intent to analysis, and open it in RStudio.
4. Install packages if not exist in environment.
5. Download annotation text file to your computer or just paste hyperlink of the file in the R code.
6. Run the whole R code with **Source** button on the top right of editor window.

# Things to know
* The packages require to be installed in RStudio before the first time you run the code.
* You can change the current folder working on, so you know where the csv files exported to.
* If you run into any error, you can contact me via gangxu79@gmail.com or gaxu@med.umich.edu.

# How to download script from GitHub
* Click the file name in GitHub.
* Click Raw button on the top right corner of the script window.
* Copy the script to your RStudio editor.
* Save it to a R file on your local disk.

