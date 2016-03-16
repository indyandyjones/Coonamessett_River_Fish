library(shiny)
library(ggplot2)
library(plyr)
library(data.table)
library(DT)
library(leaflet)

test.data.list.df <- readRDS("test.data.list.2.df")
Sponsor.name <- as.vector(test.data.list.df$Sponsor.name)

shinyUI(fluidPage(
  titlePanel(
    img(src='myImage6.png', align = "center"),
    h1("Coonamessett River Herring Tagging Activity")),
  mainPanel(  
    h1(div("Start here:", style = "font-size:100%")),
    selectizeInput('Sponsor.name', NULL, Sponsor.name, options = list(placeholder = 'Type your fish name', maxOptions = 5)),
    h2(div("Please select the specific dates of interest below.", style = "font-size:60%")),
    h2(dateRangeInput('daterange', "Date range:",
                      start  = "2015-01-01",
                      end    = "2015-07-31",
                      min    = "2015-01-01",
                      max    = "2015-07-31",
                      format = "yyyy/mm/dd",
                      separator = "-"), style = "font-size:80%")),
    h2(div("Here are some graphs showing where your fish went:",style = "font-size:80%")),
    h2(div(" ",style = "font-size:80%")),
    #leafletOutput("mymap"),
    #p(),
    #actionButton("recalc", "New points")
  tabsetPanel(
    tabPanel("Where has my fish gone?", leafletOutput("mymap"), p()),
    tabPanel("On which dates was my fish seen?", plotOutput('plot')),
    tabPanel("When during the day was my fish moving?", plotOutput('plot2'))
    #tabPanel("Time of movement 2", plotOutput('plot2'))
  ),
  mainPanel(
    h1(div(DT::dataTableOutput('tbl2'), style = "font-size:50%")),
    #h2(div(DT::dataTableOutput('tbl3'), style = "font-size:50%")),
    h2(div(DT::dataTableOutput('tbl'), style = "font-size:60%")),
    helpText(
      "For more information on this project please visit the CRT Facebook page: ",
      a(href="https://www.facebook.com/Coonamessett-River-Trust-154082221281677/", target="_blank", "CRT Facebook")
    )
  )
    ))
