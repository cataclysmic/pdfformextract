require(shiny)
require(shinysky)
require(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  pageWithSidebar(
    headerPanel("PDF Formulardaten-Extraktion"),
    sidebarPanel(
      fileInput('pdfFile', 'PDF auswählen',
                accept=c('.pdf','.PDF'),multiple=TRUE),
      uiOutput("col"),
      checkboxInput("whitespace",label="Entferne führende und folgende Leerzeichen"),
      actionButton(inputId="extract",label="Extrahieren",style="primary"),
      downloadButton("downloadData", label="Download XLSX",style="primary")

    ),
    mainPanel(
      tableOutput('contents'),
      busyIndicator(text = "Kalkuliere Tabellen",wait = 1000)
    )
  )
)
