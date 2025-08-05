# Author: Richard Ian Carpenter
# Date Created: 19 Apr 2023
# Date Updated: 23 Aug 2024

# Project: MLB Season Analysis

# Purpose: Taking regular season data and using Pythagorean Expectations 
# to create an analysis of performance.

# This is version 2 of my R script, which now reads data from the ESPN website.
# Webscraping is more efficient than doing copypasta into a spreadsheet.  Also,
# this is built off of my earlier iterations that I used during the 2023 MLB
# season.

# Acknowledgements: Regular season data comes from ESPN MLB website:
# https://www.espn.com/mlb/standings

# Updates will come as the season progresses.

# Initial libraries:
library(tidyverse)
library(lubridate)
library(rvest)
library(openxlsx)

# User input for year:
mlb_season <- "2024"

# Reading in the data:
espn_mlb_url <- read_html("https://www.espn.com/mlb/standings/")
mlb_standings <- espn_mlb_url %>% 
  html_elements("table") %>%
  html_table(header = FALSE)
  
# View(mlb_standings)

# Creating data frames from imported tibbles:
al_team_name <- data.frame(mlb_standings[[1]])
al_team_stats <- data.frame(mlb_standings[[2]][c(1,2,7,8)])
nl_team_name <- data.frame(mlb_standings[[3]])
nl_team_stats <- data.frame(mlb_standings[[4]][c(1,2,7,8)])

# Combining data frames into one table for analysis:
team_name <- bind_rows(al_team_name, nl_team_name)
team_name <- slice(team_name, -c(1, 7, 13, 19, 25, 31))
team_name$X1 <- str_remove(team_name$X1, "[a-z] --") # Cleans up notations before the team name
team_stats <- bind_rows(al_team_stats, nl_team_stats)
team_stats <- slice(team_stats, -c(1, 7, 13, 19, 25, 31))
regular_season <- bind_cols(team_name, team_stats)
# View(regular_season)

# Cleaning up column names:
colnames(regular_season) <- c("team", "w", "l", "rs", "ra")

# Adding columns for league and division:
regular_season$league <- NA
regular_season$division <- NA
regular_season$league[c(1:15)] <- "American"
regular_season$league[c(16:30)] <- "National"
regular_season$division[c(1:5, 15:20)] <- "East"
regular_season$division[c(6:10, 21:25)] <- "Central"
regular_season$division[c(11:15, 26:30)] <- "West"

# Reorganizing columns:
regular_season <- regular_season[ , c(1, 6:7, 2:5)]

# Cleaning up team names to remove artifact from team logo:
regular_season$team_name <-
  case_when(
    regular_season$team == "NYYNew York Yankees" ~ "New York Yankees",
    regular_season$team == "BALBaltimore Orioles" ~ "Baltimore Orioles",
    regular_season$team == "BOSBoston Red Sox" ~ "Boston Red Sox",
    regular_season$team == "TBTampa Bay Rays" ~ "Tampa Bay Rays",
    regular_season$team == "TORToronto Blue Jays" ~ "Toronto Blue Jays",
    regular_season$team == "CLECleveland Guardians" ~ "Cleveland Guardians",
    regular_season$team == "MINMinnesota Twins" ~ "Minnesota Twins",
    regular_season$team == "KCKansas City Royals" ~ "Kansas City Royals",
    regular_season$team == "DETDetroit Tigers" ~ "Detroit Tigers",
    regular_season$team == "CHWChicago White Sox" ~ "Chicago White Sox",
    regular_season$team == "SEASeattle Mariners" ~ "Seattle Mariners",
    regular_season$team == "HOUHouston Astros" ~ "Houston Astros",
    regular_season$team == "TEXTexas Rangers" ~ "Texas Rangers",
    regular_season$team == "LAALos Angeles Angels" ~ "Los Angeles Angels",
    regular_season$team == "OAKOakland Athletics" ~ "Oakland Athletics",
    regular_season$team == "PHIPhiladelphia Phillies" ~ "Philadelphia Phillies",
    regular_season$team == "ATLAtlanta Braves" ~ "Atlanta Braves",
    regular_season$team == "WSHWashington Nationals" ~ "Washington Nationals",
    regular_season$team == "NYMNew York Mets" ~ "New York Mets",
    regular_season$team == "MIAMiami Marlins" ~ "Miami Marlins",
    regular_season$team == "MILMilwaukee Brewers" ~ "Milwaukee Brewers",
    regular_season$team == "STLSt. Louis Cardinals" ~ "St. Louis Cardinals",
    regular_season$team == "PITPittsburgh Pirates" ~ "Pittsburgh Pirates",
    regular_season$team == "CHCChicago Cubs" ~ "Chicago Cubs",
    regular_season$team == "CINCincinnati Reds" ~ "Cincinnati Reds",
    regular_season$team == "LADLos Angeles Dodgers" ~ "Los Angeles Dodgers",
    regular_season$team == "SDSan Diego Padres" ~ "San Diego Padres",
    regular_season$team == "ARIArizona Diamondbacks" ~ "Arizona Diamondbacks",
    regular_season$team == "SFSan Francisco Giants" ~ "San Francisco Giants",
    regular_season$team == "COLColorado Rockies" ~ "Colorado Rockies")

regular_season$team_abbrev <-
  case_when(
    regular_season$team == "NYYNew York Yankees" ~ "NYY",
    regular_season$team == "BALBaltimore Orioles" ~ "BAL",
    regular_season$team == "BOSBoston Red Sox" ~ "BOS",
    regular_season$team == "TBTampa Bay Rays" ~ "TB",
    regular_season$team == "TORToronto Blue Jays" ~ "TOR",
    regular_season$team == "CLECleveland Guardians" ~ "CLE",
    regular_season$team == "MINMinnesota Twins" ~ "MIN",
    regular_season$team == "KCKansas City Royals" ~ "KC",
    regular_season$team == "DETDetroit Tigers" ~ "DET",
    regular_season$team == "CHWChicago White Sox" ~ "CHW",
    regular_season$team == "SEASeattle Mariners" ~ "SEA",
    regular_season$team == "HOUHouston Astros" ~ "HOU",
    regular_season$team == "TEXTexas Rangers" ~ "TEX",
    regular_season$team == "LAALos Angeles Angels" ~ "LAA",
    regular_season$team == "OAKOakland Athletics" ~ "OAK",
    regular_season$team == "PHIPhiladelphia Phillies" ~ "PHI",
    regular_season$team == "ATLAtlanta Braves" ~ "ATL",
    regular_season$team == "WSHWashington Nationals" ~ "WSH",
    regular_season$team == "NYMNew York Mets" ~ "NYM",
    regular_season$team == "MIAMiami Marlins" ~ "MIA",
    regular_season$team == "MILMilwaukee Brewers" ~ "MIL",
    regular_season$team == "STLSt. Louis Cardinals" ~ "STL",
    regular_season$team == "PITPittsburgh Pirates" ~ "PIT",
    regular_season$team == "CHCChicago Cubs" ~ "CHC",
    regular_season$team == "CINCincinnati Reds" ~ "CIN",
    regular_season$team == "LADLos Angeles Dodgers" ~ "LAD",
    regular_season$team == "SDSan Diego Padres" ~ "SD",
    regular_season$team == "ARIArizona Diamondbacks" ~ "ARI",
    regular_season$team == "SFSan Francisco Giants" ~ "SF",
    regular_season$team == "COLColorado Rockies" ~ "COL")

# Reorganizing columns:
regular_season <- regular_season[ , c(8:9, 2:7)]

# Changing wins, losses, runs scored, and runs against to integer format from
# character format:
regular_season$w <- as.integer(regular_season$w)
regular_season$l <- as.integer(regular_season$l)
regular_season$rs <- as.integer(regular_season$rs)
regular_season$ra <- as.integer(regular_season$ra)

# Creating win-loss percentage, run difference, and the exponent for the Pythagorean
# Expectation model.  This will be based on the work of Chris Davenport at 
# Baseball Prospectus.

# Games played:
regular_season$games <- regular_season$w + regular_season$l

# Win-loss percentage:
regular_season$win_pct <- round(regular_season$w/(regular_season$games), 3)

# Run difference:
regular_season$run_diff <- regular_season$rs - regular_season$ra

# Chris Davenport's exponent:
# regular_season$exponent <- 1.50*log((regular_season$rs + regular_season$ra)/regular_season$games) + 0.45
regular_season$exponent <- log((regular_season$rs + regular_season$ra)/regular_season$games)

# Pythagorean Expectation:
regular_season$expected_win_pct <- round(regular_season$rs^regular_season$exponent/(regular_season$rs^regular_season$exponent +
                                                                                      regular_season$ra^regular_season$exponent), 3)

regular_season$expected_wins <- round(regular_season$expected_win_pct*regular_season$games, 0)

regular_season$expected_losses <- round(regular_season$games - regular_season$expected_wins, 0)

regular_season$performance <- ifelse(regular_season$w - regular_season$expected_wins > 2, "Above expectations",
                                     ifelse(regular_season$w - regular_season$expected_wins < -2, "Below expectations",
                                            "Within expectations"))

regular_season$projected_wins <- round(regular_season$expected_win_pct * 162, 0)

regular_season$projected_losses <- round(162 - regular_season$projected_wins, 0)

# Creating a table for publishing to my blog.  This will contain only the team names,
# actual wins and losses, win percentage, expected wins and losses, and expected win percentage.

pub_regular_season <- regular_season[c(1:4, 9, 5:6, 10, 7:8, 11, 14:15, 13, 16:18)]

colnames(pub_regular_season) <- c("Team Name", "Team Abbreviation", "League", "Division", 
                                  "Games Played", "Actual Wins", 
                                  "Actual Losses", "Win %", "Runs Scored", "Runs Against",
                                  "Difference", "Expected Wins",
                                  "Expected Losses", "Expected Win %", "Actual vs Expected",
                                  "Projected Wins", "Projected Losses")

View(pub_regular_season)

# write.xlsx(pub_regular_season,
#            file = paste0("~/Documents/R/", mlb_season, " MLB Season ", today(), ".xlsx"),
#            sheetName = paste0(mlb_season, " Regular Season"),
#            append = FALSE)


