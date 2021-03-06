library(shiny)
library(dplyr)

shinyServer(function(input, output) {
  
  MxMunicipios1 <- reactive({
    
    if (input$State1 != "All") {
      MxMunicipios <- MxMunicipios[MxMunicipios$state_name %in% input$State1,]
    }else MxMunicipios <- MxMunicipios
    
   # if (input$Categorie1 != "All") {
  #    MxMunicipios <- MxMunicipios[MxMunicipios$Categorie %in% input$Categorie1,]
  #  }else MxMunicipios <- MxMunicipios
   
   #prod2010a <- MxMunicipios$prod2010 - (MxMunicipios$prod2010 * (input$Loss1/100))
   
   prod2010a <- MxMunicipios$prod2010 
   
   PerCapitaL <- (input$PerCapita*365)/1000
   
   #Urbana1 <- MxMunicipios$POBTOT10 - MxMunicipios$Pob_rur10
   Rural <- (prod2010a * (1 - (input$Loss/100))) -  (MxMunicipios$Pob_rur10 * PerCapitaL)
   Total <- (prod2010a * (1 - (input$Loss/100))) -  (MxMunicipios$POBTOT10 * PerCapitaL)
   
   #Urbana <- prod2010a -  (Urbana1 * PerCapitaL)
  
   Tabla1 <- data.frame(MxMunicipios, Total, Rural) 
   #names(Tabla1) <- c("MxMunicipios", "Total", "Rural") 
   
  })
    
  
  #Para la tabla en csv
#  output$downloadData <- downloadHandler(
#    filename = function(){
#      paste("tabla", '.csv', sep = '')},
#    content = function(file){
#      write.csv(MxMunicipios1(), file)
#    }
#  )
    

  MxMunicipios2 <- reactive({
    TablaH <- MxMunicipios1()
    #TablaH <- subset(TablaH, state_name %in% input%State1)
    value <- decostand(TablaH[,input$Variable1], "normalize")
    #value <- TablaH[,input$Variable1]
    TablaH <- data.frame(TablaH, value)
  })
  
  output$mymap <- renderLeaflet({
    HHH1 <- MxMunicipios2()
    HHH1$state_name <- as.factor(HHH1$state_name)
   # HHH2 <- subset(HHH1, state_name %in% input%State1)
    
    #MxMunicipios3 <- merge(TTT, MxMunicipios2[,c(1,14:18)], by = "region", all.x = T)
    #value <- c(MxMunicipios2$input %in% input$Variable1)
    #MxMunicipios3 <- data.frame(MxMunicipios2, value)
    #MxMunicipios3 <- MxMunicipiosLL
    
    #HHH <- brewer.pal(12, "")
    HHH <- c(rev(brewer.pal(3, "Reds")),brewer.pal(3, "Blues"))
    #HHH <- c("white",brewer.pal(6, "Reds"))
    #MxMunicipios3$value[is.na(MxMunicipios3$value)] <- 0
    
    pal <- colorNumeric(HHH, domain = HHH1$value)
    
    pal1 <- colorNumeric('OrRd', 2)
    
    #head(MxMunicipios2)
    
    mxmunicipio_leaflet(HHH1,
                        #zoom = subset(HHH1, state_name == input$State1)$region,
                        pal, 
                        mapzoom = 6,
                        ~pal(value),
                        fillOpacity = 1,
                        ~ sprintf("IdCode: %s<br/>State: %s<br/>Municipio: %s<br/>AreaPlantada: %s ha <br/>Producción: %s t<br/>Rendimiento: %s t<br/>Pob. Total: %s people <br/>Pob. Rural: %s people<br/>SurPlusTPobl: %s t<br/>SurPlusPob. Rural: %s t",
                                  region,state_name, municipio_name, aplt2010, prod2010, rend2010, POBTOT10, Pob_rur10, round(Total), round(Rural))) %>%
      #fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat)) %>%
                          
    #  addLegend(position = "topright", pal = pal, 
    #            values = HHH1$value,
    #            title = "variable<br>Selected") %>%
      
      # Add common legend
      addLegend(colors = c("#3068b2","#bf3750","#050505"), position = "topleft", 
                labels = c("Surplus of <br>maize", "Deficit of <br>maize","No data"),
                opacity = c(0.1, 0.1, 0.1)) %>%
      
        addProviderTiles("CartoDB.Positron") 
    
  }
  )
  
#  output$summary <- renderPrint({
#    dataset <- MxMunicipios2()
#    summary(dataset[,15:ncol(dataset)],3)
#  })
  
  ####################################
  
  
})
