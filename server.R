# Author: Felix Albrecht
#
# --- necessary libraries
  require(stringr)
  require(XLConnect)
# --- end -----------------

# require the extranel program pdftk (pdf tool kit) to be installed in the system path
# --- pdftk functions
getDataField <- function(pdf,name,ws){
  # call pdftk + get data field results
  pdftkOut <- system(paste("pdftk",pdf,"dump_data_fields_utf8",
                           sep=" "),intern=TRUE)
  if(length(pdftkOut) == 0){
    #print("Nr 1")
    return(NULL)
  }
  #print(pdftkOut) # testing
  fieldNames <- str_replace_all(pdftkOut[grepl("FieldName:",pdftkOut)],
                                "FieldName: ","")
  fieldNames <- c(fieldNames,"DATEI")
  fieldVals <- str_replace_all(pdftkOut[grepl("FieldValue:",pdftkOut)],
                               "FieldValue: ","")
  fieldVals <- c(fieldVals,name)
  if(ws == TRUE){  # execute for whitespace removal
    df <- data.frame(t(str_trim(fieldVals)))
  }
  else{
    df <- data.frame(t(fieldVals))
  }
  colnames(df) <- fieldNames
  return(df)
}

# --- server function
shinyServer <- function(input, output) {

# --- extracting tables from each pdf page (returns list of pages of tables)
  data <- eventReactive(input$extract,{
    # store pdf names without forms
    noFormList <- c()
    for(i in seq(1,length(input$pdfFile$datapath))){
      filePath <- input$pdfFile$datapath[i]
      fileName <- input$pdfFile$name[i]
      print(i)
      print(fileName)
      lineData <- getDataField(filePath,fileName,input$whitespace)
      # capture noForm PDF names for later output
      if(is.null(lineData)){
        noFormList <- c(noFormList,fileName)
      }
      else if(!exists("outdf")){
        outdf <- lineData
      }
      # capture differing forms - cause warning and script stop
      else if(!setequal(names(lineData),names(outdf))){
        return(0)
      }
      else{
        outdf <- rbind(outdf,lineData)
      }
    }
    # return data table and names of pdf without forms
    return(list(outdf,noFormList))
  })

# --- create xlsx name from pdf name ### funktioniert nicht richtig, file name wird nicht gefunden
  xlsxName <- reactive({
      fname <- paste("Konvertiert",".xlsx",sep="")
      return(fname)
  })

# --- create output table page 1
  observe(
    if(length(data()) == 1){
      alert("Die Dateien enthalten unterschiedliche Formulardaten. Vorgang abgebrochen.")
      }
    else{
      output$contents <- renderTable({data()[[1]]})
      alertStr <- c("Die folgenden Dateien enthalten keine Formulardaten und wurden ignoriert:\n",data()[[2]])
      alertStr <- paste(alertStr,sep="\n",collapse="\n")
      alert(alertStr)
    }
  )

# --- create download data
  output$downloadData <- downloadHandler(
    filename = xlsxName(),
    content = function(file = paste(input$pdfFile$datapath[1],
                                    xlsxName(),sep="")
                       ){

## -- create xlsx workbook
      newFile <- loadWorkbook(file,create=TRUE)

## -- iterate over page list und write data

      createSheet(newFile,name="PDF_Extrakt")
      writeTbl <- data()
      writeWorksheet(newFile,data=writeTbl,sheet="PDF_Extrakt",header=TRUE)

## -- write workbook
      saveWorkbook(newFile)
    }
  )



}

