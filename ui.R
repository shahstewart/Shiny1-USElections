library(shiny); library(plotly)
states <- read.csv('states.csv')
ch <- as.list(states$names) 

shinyUI(fluidPage(
    tags$head(includeCSS('./styles.css')),
    titlePanel('US Presidential Election Votes by Party and State'),
    sidebarLayout(
        sidebarPanel(
            h3('Map Options', class='optionsHead'),
            sliderInput('year', 'Select a Year', 1976, 2020, 2020, 4),
            selectInput('showVoteType', 'Show Votes For:',
                        data.frame('Republican Only' = 1, 'Democratic Only' = 2, 'Both Major Parties' = 3),
                        selected = 3),
            h3('See Details:', class='stateHead'),
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
                    'About',
                    h3('About this app', class='secHead'),
                    HTML('<p>This app was created as a part of the coursework for the 
                    <a href="https://www.coursera.org/learn/data-products/home/welcome">Developing Data Products</a>
                    course.</p>'), br(),
                    h3('What does this app do', class='secHead'),
                    HTML('<p>This app displays votes break-up of the US presidential elections from year 1976 to 2020. 
                     There are 4 areas where information is displayd: <br><br>
                     <b>1. The US map in the main panel:</b> 
                     Based on the year selected by the user, this map depicts the proportion of votes cast for the 
                     two major parties, namely <i>The Republican</i> and <i>The Democratic</i> parties that year. 
                     Hovering over a state will show the break-up of votes for the two parties for that state in 
                     that specific year. <br><br>
                     <b>2. The line plot of vote break-up in main panel:</b> 
                     This plot depicts the vote break-up by party during US presidential elections from 1976-2020. 
                     Hovering over the lines will show the year and percentage vote. <br><br>
                     <b>3. Vote details in the left sidebar</b>
                     Here, you will see details such as total votes cast, votes cast for each party, percentages etc 
                     for the selected state.<br><br>
                     <b>4. Vote break-up plot in the left sidebar</b>
                     This plot will change based on the state selected by the user, and will show the vote-breakup
                     over the years for that state.</p>'), br(),
                    h3('How to use app options', class='secHead'),                   
                    HTML('<p><b>Changing the Year:</b> When first loaded, the map depicts 2020 data. 
                    User can change the year using the slider on the top of the sidebar on the left. As 
                    the year is changed by moving the slider, the page will update automatically.</p>'),
                    HTML('<p><b>Changing the Party:</b> You can either choose to see votes cast for 
                    either of the two parties or both parties by selecting a party from the 
                    <i>Show Vote For</i> drop-down. Click on the down-arrow to make your selection.
                    </p>'),
                    HTML('<p><b>Seeing details vote break-up for a state:</b> To see the detailed vote break-up, 
                    select a state from the state drop-down at the bottom of the sidebar. This will also 
                    update the plot depicting vote-break up over the years for selected state.</p>
                    <p><b>Please Note:</b>The map plot ignores votes cast for minor parties and independents.</p>
                    <p>The details of the data and data-processing used in this app are available in the 
                    <i>data</i> and <i>CodeBook</i> tabs. respectively.</p>'), br(),
                    h3('Using Plot Zoom, Pan, Reset Controls', class='secHead'),
                    HTML('<p>The upper right corner of each plot shows a set of controls. These can be used 
                    for zooming, panning and resetting the plots. You can learn how to use these controls from 
                    the <a href="https://plotly.com/chart-studio-help/zoom-pan-hover-controls/"> Plotly documentation</a>
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
                    <a href="https://github.com/shahstewart/DPP-USPresElections">my GitHub Repo</a>,
                     where the The original data as well as the processed data can bee seen.</p'), br(),
                    p('- The data was filtered to only contain fileds year, state, state abbrevation, party 
                    (simplified as Republican, Democratic, Other), candidatevotes, total votes.'), br(),
                    p('- Data was further subsetted to only contain rows corresponding to the 2 major parties.'), br(),
                    p('- Percent votes were calculated based on the votes cast for a party and total votes'), br(),
                    p('- Some state-year-party combinations had duplicate data. Duplicates were removed'), br(),
                    p('- The data was transformed so that instead of one row for each party per year per state, 
                    the data held only one row per year, per state. The party-specific voting data was moved 
                    to newly added columns, each column specific for a party.'), br(),
                    p('- The processed data was saved as a csv file, to be used by the app.')                    
                )
            )           
        )        
    )
))
