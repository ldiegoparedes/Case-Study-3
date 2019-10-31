Month = c("April" = 4,
          "May" = 5,
          "June" = 6,
          "July"= 7,
          "August" = 8,
          "September"=9)

about14 <- c("txt/about.Rmd")
Kmeans14 <- c("txt/Kmeans.Rmd")
DBSCAN14 <- c("txt/DBSCAN.Rmd")
greedy14 <- c("txt/greedy.Rmd")
            
sapply(about14, knit, quiet = T, output = "txt/about.md")
sapply(Kmeans14, knit, quiet = T, output = "txt/Kmeans.md")
sapply(DBSCAN14, knit, quiet = T, output = "txt/DBSCAN.md")
sapply(greedy14, knit, quiet = T, output = "txt/greedy.md")

shinyUI(navbarPage(title ="Uber Pick-Up",
                   id = "tabs",
                   theme = shinytheme("cosmo"),
                   ##### TAB #####
                   tabPanel("Report",
                            mainPanel(
                              tabsetPanel(id = "report",
                                          tabPanel("Report",
                                                   withMathJax(includeMarkdown("txt/about.md"))
                                          ),
                                          tabPanel("K-Means", value = "kmeans1",
                                                   withMathJax(includeMarkdown("txt/Kmeans.md"))
                                          ),
                                          tabPanel("DBSCAN", value = "dbscan1",
                                                   withMathJax(includeMarkdown("txt/DBSCAN.md"))
                                          ),
                                          tabPanel("Greedy",
                                                   withMathJax(includeMarkdown("txt/greedy.md"))
                                          )
                              )
                            )
                   ),
                   ##### TAB 1 #####
                   tabPanel("Greedy Clustering", value = "tab1",
                            div(class="outer",
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("html/style.css"),
                                  includeScript("html/gomap.js")
                                ),
                                leafletOutput("map", width = "100%", height = "100%"),
                                
                                absolutePanel(id = "controls", class = "modal-content", fixed = TRUE, draggable = TRUE,
                                              top = 80, left = "auto", right = 20, bottom = "auto", width = 330, height = "auto",
                                              
                                              sliderInput("hour.range", "Hour", min(uber14$Hour), max(uber14$Hour),
                                                          value = c(7,17), step = 1),
                                              
                                              sliderInput("minutes.range", "Minutes", min(uber14$Minute), max(uber14$Minute),
                                                          value = range(uber14$Minute), step = 1),
                                              
                                              selectInput("Month", "Month", Month, selected = 4),
                                              
                                              checkboxGroupInput("days", label = h3("Day of the week"), 
                                                                 choices = list("Monday" = 1,
                                                                                "Tuesday" = 2,
                                                                                "Wednesday" = 3,
                                                                                "Thursday" = 4,
                                                                                "Friday" = 5,
                                                                                "Saturday" = 6,
                                                                                "Sunday" = 7),
                                                                 selected = c(1,2)),
                                              
                                              checkboxInput("legend", "Show legend", TRUE)
                                )
                            ),
                   ),
                   
                   ##### TAB #####
                   
                   tabPanel("K-Means & DBSCAN", value = "tab2",
                            
                            sidebarLayout(
                              sidebarPanel(
                                sliderInput("hour.range1", "Hour", min(uber14$Hour), max(uber14$Hour),
                                            value = c(7,17), step = 1),
                                
                                sliderInput("minutes.range1", "Minutes", min(uber14$Minute), max(uber14$Minute),
                                            value = range(uber14$Minute), step = 1),
                                
                                selectInput("Month1", "Month", Month, selected = 4),
                                
                                checkboxGroupInput("days1", label = h1("Day of the week"), 
                                                   choices = list("Monday" = 1,
                                                                  "Tuesday" = 2,
                                                                  "Wednesday" = 3,
                                                                  "Thursday" = 4,
                                                                  "Friday" = 5,
                                                                  "Saturday" = 6,
                                                                  "Sunday" = 7),
                                                   selected = c(1,2)),
                                
                                sliderInput("sampleSize", "Sample Size", 
                                            min=1000, max = 15000, value=8000, 
                                            step=1000),
                                
                                tabsetPanel(id = "algorithm",
                                            tabPanel("DBSCAN",
                                                     helpText("Larger sample size will increase processing time, waiting time is about 15~40 seconds depeding on the parameters"),
                                                     numericInput("rad.db", "Radius of Neighborhood (miles)", .25),
                                                     
                                                     sliderInput("MinPts", "Minimum Points", min = 5, max = 100, value = 10)
                                            ),
                                            tabPanel("KMeans",
                                                     numericInput("ncluster", "Number of Clusters", 13)
                                            )
                                ),
                                helpText("Press plot to generate map"),
                                actionButton("mapbtn", "Plot")
                              ),
                              mainPanel(
                                plotOutput("clusterplot", width = "100%", height = "1000px")
                              )
                            )
                            
                   ),
                   ##### TAB #####
                   tabPanel("Filtered Data set", value = "tab3",
                            
                            mainPanel(
                              img(
                                src = "https://github.com/ldiegoparedes/Case-Study-3/raw/master/www/Uber2018.png",
                                height = 300,
                                weight = 500),
                              h2(),
                              strong('Snapshot of our Uber Dataset'),
                              DT::dataTableOutput("filterdata")
                            )
                   )
                   #####
)

)