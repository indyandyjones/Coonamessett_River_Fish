library(shiny)
library(ggplot2)
library(plyr)
library(data.table)
library(DT)
library(leaflet)

test.data.list.df <- readRDS("test.data.list.2.df")

pallete_mov <- c(c("A0"="#756bb1","A1"="#3182bd","B1"="#ffeda0","B2"="#fff7bc",
                   "B3"="#fec44f","B4"="#d95f0e","C0"="#a1d99b","C1"="#31a354","D1"="#e34a33"))

shinyServer(function(input, output) {
  dataset = reactive({
    a = subset(test.data.list.df, 
               as.Date(DT) %between% input$daterange & 
                 Sponsor.name == input$Sponsor.name)
    return(a)
  })
  output$tbl <- DT::renderDataTable(dataset()[-1,c(10,3)], 
                                    options = list(searching = FALSE,pageLength = 10,dom = 'tip'), rownames = FALSE,colnames = c('Antenna Name' = 1, 'Date and Time' = 2),
                                    caption = 'Table 2: This is a list of the times your fish has been seen in the river.'
  )
  output$tbl2 <- DT::renderDataTable(dataset()[1,c(6:8,10)], 
                                     options = list(searching = FALSE, pageLength = 1,dom = 'tip',paging=FALSE,bInfo=0), 
                                     rownames = FALSE, caption = 'Table 1: This is the information collected about your fish when it was tagged.',
                                     colnames = c('Species' = 1, 'Length (cm)' = 3,'Tagging Spot' = 4)
  ) 
  #output$tbl3 <- DT::renderDataTable(dataset()[1,c(6:8)]
  #                 options = list(searching = FALSE, pageLength = 1,dom = 'tip',paging=FALSE,bInfo=0),
  #                 rownames = FALSE, colnames = c('Tagging Location' = 1)
  #)
  output$plot <- renderPlot({
    p <- ggplot(dataset(), aes_string(x=dataset()$DT, y=dataset()$Location2,colour=dataset()$Location)) +
      geom_path(colour='black') +
      geom_point(alpha=0.9) +
      theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
      scale_colour_manual(values=pallete_mov) +
      labs(x="\n -> TIME ->",y="<- DOWN STREAM <- \n") +#,title=paste(dataset()$Sponsor.name,"\n",dataset()$species,"-",
                                                                  #dataset()$Gender,"-",dataset()$Total.Length, "cm")) +
      scale_y_continuous(
        limits=c(0,20),
        breaks=c(0,1,5,6,7,8,9,11,20),
        labels=c("Lower Bog Tag Site","Lower Bog","Below Middle Dike","Bottom MD Culvert",
                 "Top MD Culvet","Above Middle Dike","Flax Tag Site","Flax Pond","Coon Pond")
      ) +
      theme(legend.position = "none")
    print(p)
  }, height=400)
  output$plot2 <- renderPlot({
    q <- qplot(hour(dataset()$DT)) + scale_x_continuous(limits=c(0,24)) + labs(x="Time of Day (Hour)", y="Frequency of Detections")
    print(q)}, height=400)
  
  names <- c("Low Bog Tag Site","Lower Bog","Below Middle Dike","Bottom MD Culvert",
    "Top MD Culvet","Above Middle Dike","Flax Tag Site","Flax Pond","Coon Pond")
  
  pal <- colorFactor(c(pallete_mov), domain = names)
  
  m <- leaflet() %>% addProviderTiles("Esri.WorldGrayCanvas",
                                      options = providerTileOptions(noWrap = TRUE))
  
  m2 <- m %>%
    setView(-70.568179, 41.588716, 12) %>%
    addPopups(-70.583341,41.560154, popup = "This is where herring enter the river") %>%
    addPopups(-70.568341,41.618621, popup = "Coonamessett Pond, one place herring breed") %>%
    addPopups(-70.568179, 41.588716, popup = "Flax Pond, another place herring breed")
  
  output$mymap <- renderLeaflet({m2 %>% 
      addCircleMarkers(data = dataset()[,c(11,12)],
                       color = ~pal(dataset()$Location), stroke = FALSE, fillOpacity = 0.6,
                       clusterOptions = markerClusterOptions()) %>%
      addLegend(position = 'topright', colors = c(pallete_mov), labels = c(names), opacity = 0.8,
                title = 'Legend')
    })

  })

  
