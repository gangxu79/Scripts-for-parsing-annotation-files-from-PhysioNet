# Scripts for parsing annotation text file from PhysioNet

This folder contains all the scripts parsing **annotation** files from [PhysioNet](http://www.physionet.org).
The main purpose of these scripts is to parse different format of the annotation text file from different PhysioNet database, and save it into csv (comma separated values) format.

# Platform
Each folder contains script for a specific database. 
All the scripts were coded in **R language**. You can download [R software](https://www.r-project.org/) to run these codes.
**RStudio**(https://www.rstudio.com/), which is an integrated development environment (IDE) for R, also strongly recommanded to be downloaded on your computer for your convenience.

# Steps
1. Download and install latest version of R (https://cloud.r-project.org/) for your operating system.
2. Download and install latest version of RStudio (https://www.rstudio.com/products/rstudio/download/) for your operating system.
3. Download script from the GitHub folder for the database you intent to analysis, and open it in RStudio.
4. Download annotation text file to your computer or just paste hyperlink of the file in the R code.
5. Run the whole R code with **Source** button on the top right of editor window.

# Things to know
* The packages require to be installed in RStudio before the first time you run the code.
* You can change the current folder working on, so you know where the csv files exported to.
* If you run into any error, you can contact me via gangxu79@gmail.com or gaxu@med.umich.edu.
