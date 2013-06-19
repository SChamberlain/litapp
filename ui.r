require(shiny)

# options(shiny.table.class = "table data table-striped table-condensed table-bordered ")

shinyUI(pageWithSidebar(
  
  headerPanel(title=HTML("LittR - <i>Explorating literature in R</i> "), windowTitle="LittR"),
  
  sidebarPanel(
    
    HTML('<style type="text/css">
         .row-fluid .span4{width: 26%;}
         .leaflet {height: 600px; width: 830px;}
         </style>'),

      HTML('<textarea id="spec" rows="3" cols="50">science,ecology,theory</textarea>'),
    
      h5(strong("Options:")),
      sliderInput(inputId="numresults", label="Number of records to search for", min=1, max=500, value=10, step=10, ticks=TRUE)
  ),
     
  mainPanel(  
    tabsetPanel(
      tabPanel("PLOS Journals", includeHTML('papersmodal.html'), tableOutput('plos')),
      tabPanel("Crossref", includeHTML('crossrefmodal.html'), tableOutput('crossref')),
      tabPanel("Crossref Free", tableOutput('crossref_free')),
      tabPanel("DPLA", includeHTML('dplamodal.html'), tableOutput('dpla'))
    ),
  includeHTML('gauges.html')
  )
))
