library(shiny)
url3="https://www.cpubenchmark.net/cpu_list.php"
# Define UI for application that draws a histogram
code= HTML('<script type="text/javascript">
        $(document).ready(function() {
          $("#goButton").click(function() {
            $("#Download").text("Loading...");
          });
        });
      </script>
')

foption=list("mean","sum")

shinyUI(fluidPage(
        
        # Application title
        titlePanel("Controls:"),
  
        # Sidebar with a slider input for the number of bins
        sidebarLayout(
                sidebarPanel(
                        tags$head(tags$style(type="text/css", "
             #loadmessage {
               display:block;
               position: fixed;
               top: 50%;
               left: 30%;
               width: 50%;
               padding: 5px 0px 5px 0px;
               text-align: center;
               font-weight: bold;
               font-size: 200%;
               color: #000000;
               z-index: 105;
             }
          ")),
                       
                        textInput("url","Url:",value=url3),
                        actionButton("goButton", "Get Tables"),
                        actionButton("filtButton", "Apply Filter"),
                        selectInput("columns", "Column which to Apply Filter:", 
                                    choices = c()),
                        textInput("optfilter", "Type the filter text to Apply: "),
			selectInput("fcolumns", "Column which to Apply Function:",choices = c()),
                        selectInput("optfunction", "Function to Apply:", 
                                    choices = foption),
                        conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                         tags$div("Loading...",id="loadmessage")),
                        h3(textOutput("lresults")),
                        textOutput("Results"),
                        plotOutput("bplot")
                ),
                
                # Show a plot of the generated distribution
                
                mainPanel(
#                        plotOutput("distPlot"),
                        h1(textOutput("title")),
                        p("Extracted Table:"),
                        dataTableOutput("dircontents")
 
                        
                )
        )
))
