require(shiny)

options(xtable.type = "html")
options(xtable.include.rownames = FALSE)
options(xtable.html.table.attributes = "class=table")

shinyServer(function(input, output){
  
  query_num <- reactive({
    list(strsplit(input$spec, ",")[[1]], input$numresults)
  })
  
  plos_prep <- reactive({
    require(rplos); require(xtable); require(plyr); require(doMC)
    registerDoMC(cores=8)
    dat <- llply(query_num()[[1]], function(x) searchplos(x, fields='id,journal,title', limit = query_num()[[2]], key='WQcDSXml2VSWx3P')[,-4], .parallel=TRUE)
    names(dat) <- query_num()[[1]]
    dat <- ldply(dat)
    dat$id <- paste0("<center><a href='http://macrodocs.org/?doi=", dat$id, "' target='_blank'> <i class='icon-book'></i> </a></center>")
    names(dat) <- c("Species","Read","Journal","Title")
    print(xtable(dat), type="html", sanitize.text.function = function(x){x})
  })
  
  crossref_prep <- reactive({
    require(rmetadata); require(xtable); require(plyr); require(doMC); require(rjson)
    registerDoMC(cores=8)
    dat <- llply(query_num()[[1]], function(x) crossref_search(x, rows = query_num()[[2]])[,-c(2,5,6,7)], .parallel=TRUE)
    names(dat) <- query_num()[[1]]
    dat <- ldply(dat)
    dat$doi <- paste0("<center><a href='", dat$doi, "' target='_blank'><i class='icon-link'></i> </a></center>")
    names(dat) <- c("Term","Read","Score","Publication")
    print(xtable(dat), type="html", sanitize.text.function = function(x){x})
  })
  
  crossref_free_prep <- reactive({
    require(rmetadata); require(xtable); require(rjson)
    dat <- crossref_search_free(query_num()[[1]])
    dat$doi <- paste0("<center><a href='", dat$doi, "' target='_blank'><i class='icon-link'></i> </a></center>")
    dat <- data.frame(Term=dat$text,Read=dat$doi,Match=dat$match,Score=dat$score)
    print(xtable(dat), type="html", sanitize.text.function = function(x){x})
  })
  
  dpla_prep <- reactive({
    require(rmetadata); require(xtable); require(plyr); require(doMC); require(rjson)
    registerDoMC(cores=8)
    dat <- llply(query_num()[[1]], function(x) 
      dpla_basic(x, limit = query_num()[[2]])[,c("url","title","provider_name","date","rights")], 
                 .parallel=TRUE)
    names(dat) <- query_num()[[1]]
    dat <- ldply(dat)
    dat$rights <- gsub("No known.+", "No known copyright", dat$rights)
    dat$url <- paste0("<center><a href='", dat$url, "' target='_blank'><i class='icon-link'></i> </a></center>")
    names(dat) <- c("Term","View","Title","Provider","Date","Rights")
    print(xtable(dat), type="html", sanitize.text.function = function(x){x})
  })
  
#   dpla_plot_prep <- reactive({
#     require(rmetadata); require(plyr); require(doMC); require(rjson)
#     registerDoMC(cores=8)
#     out <- dpla_basic("ecology", date.before=1900, limit=200)
#     dpla_plot(input=out, plottype="subjectsbydate")
#   })
  
  output$plos <- renderText({
    plos_prep()
  })
  
  output$crossref <- renderText({
    crossref_prep()
  })
  
  output$crossref_free <- renderText({
    crossref_free_prep()
  })
  
  output$dpla <- renderText({
    dpla_prep()
  })
  
#   output$dpla_plots <- renderPlot({
#     dpla_plot_prep()
#   })
  
})