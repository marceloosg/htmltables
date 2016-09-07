library(shiny)
library(data.table)
library(digest)
url="http://www.dnr.state.mn.us/lakefind/showreport.html?downum=27013300"
url2="http://www.ssp.sp.gov.br/novaestatistica/Pesquisa.aspx"
url3="https://www.cpubenchmark.net/cpu_list.php"
source("ReadWebTable.R")
# Define server logic required to draw a histogram
lastgo=0
foption=list("mean"=mean,"sum"=sum)
shinyServer(function(input, output,session) {

        observeEvent(input$goButton,{
                
                output$frame <- renderUI({})
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
                                output$frame <- renderUI({})
                                html=get_db_from_web(isolate(input$url))
                                html.title=html[[1]]
                                html.db=html[[2]]
                                if(input$optfilter != ""){
                                        filter=grep(input$optfilter,html.db[[input$columns]],ignore.case=T)
                                        rdb=html.db[filter,]
                                }else{
                                        rdb=html.db[,]
                                }
				colvalue=as.character(rdb[[input$fcolumns]])
				colvalue=gsub("\\@|\\$","",colvalue)
				colvalue=as.numeric(colvalue)
				nas=sum(is.na(colvalue))
				valid=sum(!is.na(colvalue))
				colvalue=colvalue[!is.na(colvalue)]
				selected_function=foption[[input$optfunction]]
                                result=as.integer(100*selected_function(colvalue))/100
                                fname=input$fcolumns
                                output$lresults=renderText(fname)
                                output$Results = renderText({
                                        if(length(colvalue)>0){
                                        paste(input$optfunction,result,
					"NAs",nas,"Values",valid,sep=":")}
                                        else{return("Not enought Data:(check selected column) ")}
                                        })
                                output$bplot=renderPlot({
                                        if(length(colvalue) < 3){
                                                return(NULL)      
                                        } 
                                        boxplot(colvalue)
                                }
                                        
                                )
                                
                        }
                })
                output$dir=renderText(dir())
                observeEvent(input$helpButton,{
                        output$dircontents=renderDataTable(data.frame())
                        output$title=renderText("Documentation")
                        output$frame <- renderUI({
                                
                                includeMarkdown("include.md")
                        })
                        })
        
})
