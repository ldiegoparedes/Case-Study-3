library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    # Observe active tab
    observeEvent(input$tabs,{
        ##### TAB 1
        if (input$tabs == "tab1"){
            output$map = renderLeaflet({
                leaflet() %>%
                    addProviderTiles(providers$CartoDB.DarkMatter, group="Dark")%>%
                    setView(lng = -73.97, lat = 40.75, zoom = 13)
            })
            
            observeEvent(c(input$hour.range, input$minutes.range, input$days, input$Month),{
                
                ##### UPDATES INPUT PARAMETERS SHARED IN TABS ##### 
                observe({updateSliderInput(session, "hour.range1", value = input$hour.range)})
                observe({updateSliderInput(session, "minutes.range1", value = input$minutes.range)})
                observe({updateCheckboxGroupInput(session, "days1", selected = input$days)})
                observe({updateSelectInput(session, "Month1", selected=input$Month)})
                
                ####### FILTER DATA #######
                filterData = uber14%>%
                    filter(Hour >= input$hour.range[1] & Hour <= input$hour.range[2])%>%
                    filter(Minute >= input$minutes.range[1] & Minute <= input$minutes.range[2])%>%
                    filter(Month == input$Month) %>%
                    filter(Weekday %in% input$days)
                
                output$filterdata <- DT::renderDataTable({
                    df = filterData %>%
                        arrange(., desc(Weekday))
                    DT::datatable(head(df,100), class = 'cell-border stripe', escape = FALSE)
                    
                })
                
                ####### PLOT TAB1 MAP  #######
                leafletProxy("map", data = filterData) %>%
                    clearMarkerClusters() %>%
                    clearShapes() %>%
                    addProviderTiles(providers$CartoDB.DarkMatter, group="Dark") %>%
                    addMarkers(
                        lng=~Lon, lat=~Lat,
                        label=~as.character(Base), labelOptions = labelOptions(),
                        options = markerOptions(),
                        clusterOptions = markerClusterOptions(
                            showCoverageOnHover = TRUE,
                            zoomToBoundsOnClick = TRUE,
                            spiderfyOnMaxZoom = FALSE,
                            removeOutsideVisibleBounds = TRUE
                            #### CLUSTER NUMBERS ####
                            #,iconCreateFunction=
                            # JS("function (cluster) {
                            #   var childCount = cluster.getChildCount();
                            #   var c = ' marker-cluster-';
                            #   if (childCount >= 1000) {
                            #     c += 'large';
                            #   } else if (childCount < 1000 & childCount >= 100) {
                            #     c += 'medium';
                            #   } else {
                            #     c += 'small';
                            #   }
                            # 
                            #   return new L.DivIcon({
                            #   html: '<div><span>' + childCount + '</span></div>',
                            #   className: 'marker-cluster' + c, iconSize: new L.Point(40, 40)
                            #   });
                            # }")
                            ###### 
                        )
                        # ,clusterId = "uberCluster"
                    )
                
                #### BUTTON TO FREEZE Z-LEVEL CLUSTER #####
                # %>%
                #     addEasyButton(easyButton(
                #         states = list(
                #             easyButtonState(
                #                 stateName="unfrozen-markers",
                #                 icon="ion-toggle",
                #                 title="Freeze Clusters",
                #                 onClick = JS("
                #                     function(btn, map) {
                #                         var clusterManager =
                #                         map.layerManager.getLayer('cluster', 'uberCluster');
                #                     clusterManager.freezeAtZoom();
                #                     btn.state('frozen-markers');
                #                     }")
                #             ),
                #             easyButtonState(
                #                 stateName="frozen-markers",
                #                 icon="ion-toggle-filled",
                #                 title="UnFreeze Clusters",
                #                 onClick = JS("
                #                     function(btn, map) {
                #                         var clusterManager =
                #                         map.layerManager.getLayer('cluster', 'uberCluster');
                #                     clusterManager.unfreeze();
                #                     btn.state('unfrozen-markers');
                #                     }")
                #             )
                #         )
                #     ))
                    
            })
            
        ##### TAB 2
        } else if (input$tabs == "tab2") {
            v = reactiveValues(doPlot = FALSE)
            
            observeEvent(c(input$hour.range1, input$minutes.range1, input$days1, input$Month1, input$sampleSize),{
                
                ##### UPDATES INPUT PARAMETERS SHARED IN TABS ##### 
                
                # observe({updateSliderInput(session, "hour.range", value = input$hour.range1)})
                # observe({updateSliderInput(session, "minutes.range", value = input$minutes.range1)})
                # observe({updateCheckboxGroupInput(session, "days", selected = input$days1)})
                # observe({updateSelectInput(session, "Month", selected=input$Month1)})
                
                ####### FILTER DATA #######
                filterData = uber14%>%
                    filter(Hour >= input$hour.range1[1] & Hour <= input$hour.range1[2])%>%
                    filter(Minute >= input$minutes.range1[1] & Minute <= input$minutes.range1[2])%>%
                    filter(Month == input$Month1) %>%
                    filter(Weekday %in% input$days1)
                
                newMax = nrow(filterData)
                updateSliderInput(session, "sampleSize", max = newMax)
               

                observeEvent(input$mapbtn, {
                    # 0 will be coerced to FALSE
                    # 1+ will be coerced to TRUE
                    v$doPlot = input$mapbtn
                })
                
                observeEvent(input$algorithm, {
                    v$doPlot = FALSE
                })  
                
                output$clusterplot<-renderPlot({
                    if (v$doPlot == FALSE) return()
                    
                    isolate({
                        if (input$algorithm == "DBSCAN") {
                            filterData = filterData[sample(1:nrow(filterData), input$sampleSize),]
                            epsilon = input$rad.db/ mi_per_lon
                            clust = fpc::dbscan(filterData[,2:3], eps = epsilon, MinPts = input$MinPts)
                            filterData$cluster = clust$cluster
                            
                        } else {
                            filterData = filterData[sample(1:nrow(filterData), input$sampleSize),]
                            clust = kmeans(filterData[,2:3], input$ncluster)
                            filterData$cluster = clust$cluster
                            
                        }
                        
                        all_hulls = setNames(data.frame(matrix(nrow = 0, ncol = ncol(filterData))), colnames(filterData))
                        
                        for(i in 1:max(filterData$cluster)){
                            grpi = filterData[filterData$cluster == i, ][chull(filterData %>% filter(cluster == i) %>% select(Lon, Lat) ), ]  # hull values for cluster 1
                            all_hulls = rbind.data.frame(all_hulls,grpi)
                        }
                        
                        NYCMap +
                            geom_point(aes(x = Lon, y = Lat, colour = as.factor(cluster)), data = filterData)+ ggtitle(input$algorithm)+
                            geom_polygon(data = all_hulls, aes(x = Lon, y = Lat, fill = as.factor(cluster), colour =  as.factor(cluster)), alpha = 0.25)+ theme(legend.position="top")

                    })
                })
            })
        }
    })
    
    ##### STOP APP IF WINDOW CLOSED ####
    observeEvent(input$close, {
        js$closeWindow()
        stopApp()
    })
})
    