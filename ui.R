library(shiny); library(plotly); library(stringr)
states <- read.csv('./data/states.csv')
ch <- as.list(str_to_title(states$names)) 

shinyUI(fluidPage(
    tags$head(includeCSS('./styles.css')),
    titlePanel('US Presidential Election Popular Votes by Party and State'),
    HTML('<div class="sub">
        <span>A Shiny App By <a target="_blank" href="https://linkedin.com/in/sangeetashah">Sangeeta Shah</a></span>
        <span>&emsp; | &emsp;</span>
        <span><a target="_blank" href="https://shahstewart.github.io/slidifyDeck1">About this app</a></span>
        </div>'),
    sidebarLayout(
        sidebarPanel(
            h3('Map Data Options', class='optionsHead'),
            sliderInput('year', 'Select a Year', 1976, 2020, 2020, 4),
            selectInput('showVoteType', 'Show Votes For:',
                        list('Republican Party Only' = 1, 'Democratic Party Only' = 2, 'Both Major Parties' = 3),
                        selected = 3),
            h3('Vote Details:', class='stateHead'),
            selectInput('state', 'Select a State', choices = ch, selected= 'ALL US'),
            p(textOutput('selectedState')),
            htmlOutput('details'), br(),
            h4(textOutput('statePlotHeader')), br(),
            plotlyOutput('stateVotePlot')            
        ),
        mainPanel(
            tabsetPanel(
                type = 'tabs',
                tabPanel(
                    'US Elections',
                    htmlOutput('mainPanelHeader'),
                    plotlyOutput('voteMap'),
                    HTML('<center><h3>Percent Votes by Party in US Presidential Elections</h3><h4>1976 - 2020</h4></center>'),
                    plotlyOutput('usVotePlot')
                ),
                tabPanel(
                    'Documentaion',
                    h2('About this app', class='secHead'), hr(),
                    h3('What does this app do', class='secHead'),
                    HTML('<p>This app displays the vote break-up of the US presidential elections from year 
                     1976 to 2020. There are 4 areas where information is displayd: <br><br>
                     <b>1. The US map in the main panel:</b> 
                     Based on the year selected by the user, this map depicts the proportion of votes cast for the 
                     two major parties, namely <i>The Republican</i> and <i>The Democratic</i> parties that year. 
                     Hovering over a state will show the vote break-up details for that state in the selected year.
                     <br><br>
                     <b>2. The line plot of vote break-up in main panel:</b> 
                     This plot depicts the vote break-up by party of the US presidential elections from years 
                     1976-2020. 
                     <br><br>
                     <b>3. Vote details in the left sidebar:</b>
                     Here, you will see detailed vote stats such as total votes cast, votes cast for each party,
                     percentage votes cast for each party etc. for the user-selected state.<br><br>
                     <b>4. Vote break-up plot in the left sidebar:</b>
                     This plot will change based on the state selected by the user, and will show the vote-breakup
                     over the years 1976-2020 for that specific state.</p>'), br(),
                    h3('How to use app options', class='secHead'),                   
                    HTML('<p><b>Changing the Year:</b> When first loaded, the map depicts 2020 data. 
                    User can change the year using the slider on the top of the sidebar on the left; 
                    the page will update automatically.</p>'),
                    HTML('<p><b>Changing the Party:</b> You can choose to see votes cast for 
                    either of the two major parties or both parties by making appropriate selection from the 
                    <i>Show Vote For</i> drop-down.</p>'),
                    HTML('<p><b>Seeing details vote break-up for a state:</b> To see the detailed vote break-up, 
                    select a state from the state drop-down. This will also update the selected state vote-break up 
                    plot in the sidebar.</p>
                    <p><b>Please Note:</b>The map plot ignores votes cast for minor parties and independents.</p>
                    <p>The details of the data and data-processing used in this app are available in the 
                    <i>data</i> tab.</p>'), br(),
                    h3('Using Plot Zoom, Pan, Reset Controls', class='secHead'),
                    HTML('<p>The upper right corner of each plot shows a set of controls. These can be used 
                    for zooming, panning and resetting the plots. You can learn how to use these controls 
                    <a href="https://plotly.com/chart-studio-help/zoom-pan-hover-controls/">here</a>
                    </p>')
                ),
                tabPanel(
                    'The Data',
                    h4('The Data Source', class='secHead'),
                    HTML('<p> The data used for this app is available at 
                    <a href="https://dataverse.harvard.edu/file.xhtml?fileId=4299753&version=6.0">Harvard Dataverse</a>                   
                    and is maintained by <a href="https://electionlab.mit.edu/">MIT Election Data and Science Lab (MEDSL).</a>
                    The data was downloaded from the above url on Nov 8, 2021.</p>
                    <p>
                    The codebook for the original data is available
                    <a href="https://dataverse.harvard.edu/file.xhtml?fileId=4299754&version=6.0">here</a>.
                    </p>'), br(),
                    h4('Data Processing', class='secHead'),
                    HTML('<p>The code for this app is avalialbe at 
                    <a href="https://github.com/shahstewart/Shiny1-USElections">my GitHub Repo</a>,
                     where the The original data as well as the processed data can bee seen.
                     The data was processed in the following steps:</p>'),
                    tags$ul(
                        tags$li('The data was filtered to only contain fileds year, state, state abbrevation, party,
                                candidatevotesand total votes.'),
                        HTML('<li>The party field was simplified as <i>Republican</i>, <i>Democratic</i> and <i>Other</i>.</li>'),
                        tags$li('Data was further subsetted to only contain rows corresponding to the 
                                2 major parties. The percent votes were calculated based on the votes cast for a party and total
                                votes.'),
                        tags$li('Some state-year-party combinations had duplicate data. Duplicates were removed.'),
                        tags$li('The data was transformed so that instead of one row for each party per
                                year per state, the data held only one row per year, per state.'),
                        tags$li('The processed data was saved as a csv file, to be used by the app.'),
                    )
                )
            )           
        )        
    )
))
