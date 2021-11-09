library(dplyr)

# load data. The file has been downloaded on Nov 8, 2021 from the following url:
# https://dataverse.harvard.edu/file.xhtml?fileId=4299753&version=6.0
# The codebook for this data is at the following url
# https://dataverse.harvard.edu/file.xhtml?fileId=4299754&version=6.0
dO <- read.csv('./1976-2020-president.csv')


# Ignore data for 'Other' and 'Libertarian' party affiliations.
# Add columns for percent vote
dO <- dO %>% 
    select(year, state, state_po, party_simplified, candidatevotes, totalvotes) %>%
    filter(party_simplified == 'DEMOCRAT' | party_simplified =='REPUBLICAN') %>%
    mutate(percent_votes = round(candidatevotes * 100 / totalvotes), 2)

# create a new df d with only one entry for each year-state 
d <- dO %>% select(year, state, state_po) %>% distinct()

# separate the original data into dems and reps.
dem <- dO %>% filter(party_simplified == 'DEMOCRAT')
rep <- dO %>% filter(party_simplified =='REPUBLICAN')

# remove some duplicate rows so the row numbers match properly
# dem has two entries for MD for 2004, and both have 2 entries for AZ in 2008
dem <- dem[-c(379, 515, 534), ]; rownames(dem) <- 1:nrow(dem)
rep <- rep[-532, ]; rownames(rep) <- 1:nrow(rep)

# add 2 new percent votes, 2 candidate vote columns and one each totalvotes and hover columns to df d.
d <- d %>% mutate(
    percDem = dem$percent_votes,
    percRep = rep$percent_votes,
    demVotes = dem$candidatevotes,
    repVotes = rep$candidatevotes,
    totalVotes = dem$totalvotes,
	hover=paste(state, '<br>', 'Year:', year, '<br>', 'Democratic:', 
				dem$percent_votes, '%<br>','Republican:', rep$percent_votes, '%'),)

write.csv(d, 'processedData.csv')
