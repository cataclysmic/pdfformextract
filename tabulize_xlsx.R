# Author: Felix Albrecht
# Edit: Marcel Moeschter
# script to convert HSH PDF to data.frame
#
########## !!! "./AGS_PLZ.txt" must be saved in working directory !!!
#
# for downloading package lists
# Sys.setenv(R_USER="C:/Software/Rpackages")
#
# for StaLA proxy / necessary for package installation
 Sys.setenv(https_proxy="http://zensus:wartburg-5@192.0.0.98:8080")
#
## -- install necessary libraries (remember proxy connection above for github download)
  #install.packages('tidyverse')
  #install.packages('devtools')
  #install.packages('png')
  #install.packages('rJava')
  #library(devtools)
  #install_github('miraisolutions/xlconnectjars', dependencies = "FALSE")
  #install_github('miraisolutions/xlconnect', dependencies = "FALSE")
  #install_github("ropensci/tabulizerjars", dependencies = "FALSE")
  #install_github("ropensci/tabulizer", dependencies = "FALSE")

# ------------------------------------- provide input file here --------------
filePath <- "D:/Service/Software/R-Skripte/PDFtoXLSX_Tabellen/2018-03-08_FINAL_AZP_TP_Personenerhebung(K_A)_V1.pdf"
# ----------------------------------------------------------------------------
# --------------------- Cross your fingers -----------------------------------
# --- loading libraries ---
library(tidyverse)
library(tabulizer)  # JAVA backend
library(XLConnect)  # JAVA backend
# --- end -----------------

pdfConvert <- function(filePath){
# --- extracting tables from each pdf page (returns list of pages of tables)
pdfTbls <- extract_tables(filePath)

# --- get file name without file extension
fileName <- str_replace(filePath,'pdf',"")
fileName <- paste(fileName,'xlsx',sep="")

# --- create xlsx workbook
wb <- loadWorkbook(fileName,create=TRUE)

# --- iterate over page list und write data

for(i in seq(1,length(pdfTbls))){
  sheetName <- paste("Seite",i,sep=" ")
  createSheet(wb,name=sheetName)
  writeWorksheet(wb,data=pdfTbls[i],sheet=sheetName,header=TRUE)
}

# --- write workbook
saveWorkbook(wb)
}

