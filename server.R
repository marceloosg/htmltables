library(shiny)
library(data.table)
url="http://www.dnr.state.mn.us/lakefind/showreport.html?downum=27013300"
url2="http://www.ssp.sp.gov.br/novaestatistica/Pesquisa.aspx"
url3="https://www.cpubenchmark.net/cpu_list.php"
source("readtable.R")
# Define server logic required to draw a histogram
lastgo=0
foption=list("mean"=mean,"sum"=sum)
shinyServer(function(input, output,session) {

        observeEvent(input$goButton,{
                
                html=get_db_from_web(isolate(input$url))
                html.title=html[[1]]
                html.db=html[[2]]
                options=colnames(html.db)
                updateSelectInput(session, "columns", choices = options)
                updateSelectInput(session, "fcolumns", choices = options)
                output$dircontents = renderDataTable(html.db)
                output$title=renderText(html.title)
        })
       
            
                observeEvent(input$filtButton,{
                        if(input$goButton > 0){
                                html=get_db_from_web(isolate(input$url))
                                html.title=html[[1]]
                                html.db=html[[2]]
                                if(input$optfilter != ""){
                                        filter=grep(input$optfilter,html.db[[input$columns]])
                                        rdb=html.db[filter,]
                                }else{
                                        rdb=html.db[,]
                                }
                                
                                result=foption[[input$optfunction]](
                                        as.numeric(as.character(rdb[[input$fcolumns]])),na.rm=T)
                                fname=input$fcolumns
                                output$lresults=renderText(fname)
                                output$Results = renderText({
                                        if(length(result)>0){
                                        paste(input$optfunction,result,sep=":")}
                                        else{return("Not enought Data:(check selected column) ")}
                                        })
                                col=as.numeric(as.character(rdb[[input$fcolumns]]))
                                col=col[!is.na(col)]
                                output$bplot=renderPlot({
                                        if(is.null(col)){
                                                return(NULL)      
                                        } 
                                        boxplot(col)
                                }
                                        
                                )
                                
                        }
                })
        
})