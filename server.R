library(shiny); library(dplyr); library(plotly)

shinyServer(function(input, output) {
    data <- read.csv('./data/processedData.csv')
    mapData <- reactive({ data[data$year == input$mapYear,] })
    mapYear <- reactive({ input$mapYear })
    firstYear <- reactive({ input$year[1] })
    lastYear <- reactive({ input$year[2] })
    
    usPlotData <- reactive({
        data %>% filter(year >= input$year[1] & year <= input$year[2]) %>% select(year, demVotes, repVotes, totalVotes) %>%
        mutate(othVotes = totalVotes - demVotes - repVotes) %>% group_by(year) %>%
        summarize(demTotals = sum(demVotes), repTotals = sum(repVotes), othTotals = sum(othVotes), totals = sum(totalVotes)) %>%
        mutate(demPercs = demTotals*100/totals, repPercs = repTotals*100/totals, othPercs=othTotals*100/totals)
    })

    statePlotData <- reactive({ 
        if(input$state == 'All US') sd <- data %>% filter(year >= input$year[1] & year <= input$year[2])
        else sd <- data %>% filter(state == toupper(input$state) & year >= input$year[1] & year <= input$year[2])

        sd %>% select(year, demVotes, repVotes, totalVotes) %>%
        mutate(othVotes = totalVotes - demVotes - repVotes) %>% group_by(year) %>%
        summarize(demTotals = sum(demVotes), repTotals = sum(repVotes), othTotals = sum(othVotes), totals = sum(totalVotes)) %>%
        mutate(demPercs = demTotals*100/totals, repPercs = repTotals*100/totals, othPercs=othTotals*100/totals)
    })
    
    voteTypes <- c('Republican party', 'Democratic party', 'Both Major Parties')
    selectedVoteType <- reactive({ voteTypes[as.numeric(input$showVoteType)] })
    
    selectedState <- reactive({ input$state })
    
    colBarTitles <- c('Republican Votes<br>&nbsp;', 'Democratic Votes<br>&nbsp;', 'Percent Vote<br>&nbsp;')
    
    details <- reactive({
        st <- paste('Year:<b>', input$year, '</b><br>')
        
        if(selectedState() != 'All US') {
            d <- data[data$year == input$year[2] & data$state == toupper(input$state),]
            paste(
                st, 'Total Votes:<b>', d['totalVotes'], '</b><br>',
                'Democratic Votes:<b>', d['demVotes'], '</b><br>',
                'Republican Votes:<b>', d['repVotes'], '</b><br>',
                'Other Votes:<b>', (d['totalVotes'] - d['repVotes'] - d['demVotes']), '</b><br>',
                'Percent Democratic:<b>', d['percDem'], '%</b><br>',
                'Percent Republican:<b>', d['percRep'], '%</b><br>',               
                'Percent Other:<b>', (100 - d['percRep'] - d['percDem']), '%</b><br><br>'
            )
        } else {
            d <- data[data$year == input$year,]
            paste(
                st, 'Total Votes:<b>', round(sum(d['totalVotes'])/10^6, 2), 'M</b><br>',
                'Democratic Votes:<b>', round(sum(d['demVotes'])/10^6, 2), 'M</b><br>',
                'Republican Votes:<b>', round(sum(d['repVotes'])/10^6,2), 'M</b><br>',
                'Other Votes:<b>', round(sum(d['totalVotes'] - d['repVotes'] - d['demVotes'])/ 10^6,2), 'M</b><br>',
                'Percent Democratic:<b>', round(mean(d$percDem),2), '%</b><br>',
                'Percent Republican:<b>', round(mean(d$percRep), 2), '%</b><br>',
                'Percent Other:<b>', round(100 - mean(d$percRep) - mean(d$percDem), 2), '%</b><br><br>'
            )
        }
    }) 
    
    ## Output    
    output$voteMap <- renderPlotly({
        g <- list(scope = 'usa', projection = list(type = 'albers usa'))
        fig <- plot_geo(mapData(), locationmode = 'USA-states')

        if (input$showVoteType == 1) {
            fig <- fig %>%
                add_trace(z = ~percRep, locations = ~state_po, color = ~percRep, 
                          colors = 'Reds', text = ~hover, hoverinfo = 'text')
        } else if (input$showVoteType == 2) {
            fig <- fig %>%
                add_trace(z = ~percDem, locations = ~state_po, color = ~percDem, 
                          colors = 'Blues', text = ~hover, hoverinfo = 'text')
        } else {
            fig <- fig %>%
                add_trace(z = ~percRep, locations = ~state_po, color = ~percRep,
                          colorscale = 'Bluered', text = ~hover, hoverinfo = 'text')
        }

        fig <- fig %>% layout(title=list(y=.95, x = 0.02, font=list(size=24,
                                                                    family='Open Sans')), geo = g)

        if(input$showVoteType == 1 | input$showVoteType ==2) {
            fig %>% colorbar(title = colBarTitles[as.numeric(input$showVoteType)], y = .9, len=.8, thickness=12, 
                             limits = c(10, 90), tickvals = c(10, 90), ticktext = c('10-%', '90+%'))
        } else {
            fig %>% colorbar(title = colBarTitles[as.numeric(input$showVoteType)], y = .9, len=.8, thickness=12, 
                    limits = c(0, 100), tickvals = c(10, 90), ticktext = c('90% \nDem', '90% \nRep'))
        }
    })
    
    output$usVotePlot <- renderPlotly(
        plot_ly(usPlotData(), x=~year, y=~demPercs, type='scatter', mode='lines+markers', line=list(color='blue'), name='Democratic') %>%
            add_trace(y=~repPercs, mode='lines+markers', line=list(color='red'), name='Republican') %>%
            add_trace(y=~othPercs, mode='lines+markers', line=list(color='gray'), name='Other') %>%
            layout(yaxis=list(title='Percent Votes'), hovermode='x unified',
                   xaxis=list(title='Year', autotick=F, tickmode='array'))
    )
    
    output$stateVotePlot <- renderPlotly(
        plot_ly(statePlotData(), x=~year, y=~demPercs, type='scatter', mode='lines+markers', line=list(color='blue'), name='Democratic') %>%
        add_trace(y=~repPercs, mode='lines+markers', line=list(color='red'), name='Republican') %>%
        add_trace(y=~othPercs, mode='lines+markers', line=list(color='gray'), name='Other') %>%
        layout(title=list(text=selectedState(), y=0.95), yaxis=list(title='Percent Votes'), hovermode='x unified', 
               xaxis=list(title='Year', autotick=F, tickmode='array'))
        %>% hide_legend()
    )
    
    output$mapPlotHeader <- renderText(
        paste(
            '<center><h3>Map of Presidential Election Votes by State</h3><h4>', mapYear(), 'percent popular vote,',
            selectedVoteType(), '</h4></center>'
        )) 
    
    output$details <- renderText(details())
    
    output$statePlotHeader <- renderText(paste('Presidential Election Vote by party in',
            selectedState(),'(from)', firstYear(), '-', lastYear(), '):'))

    output$usVotePlotHeader <- renderText(paste('<center><h3>Percent Votes by Party in US Presidential Elections</h3>',
                                              '<h4>',firstYear(), '-', lastYear(), '</h4></center>'))
})
