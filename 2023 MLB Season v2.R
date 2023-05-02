# Author: Richard Ian Carpenter
# Date Created: 19 Apr 2023
# Date Updated: 02 May 2023

# Project: 2023 MLB Season Analysis

# Purpose: Taking 2023 Regular Season data and using Pythagorean Expectations 
# to create an analysis of performance.

# This is version 2 of my R script, which now reads data from the ESPN website
# instead of copy and pasting data into a spreadsheet.

# Acknowledgements: 2023 Regular Season data comes from ESPN MLB website:
# https://www.espn.com/mlb/standings

# Updates will come as the season progresses.

# Initial libraries:
library(tidyverse)
library(lubridate)
library(rvest)
library(openxlsx)

# Reading in the data:
espn_mlb_url <- read_html("https://www.espn.com/mlb/standings")
mlb_standings <- espn_mlb_url %>% html_elements("table") %>% html_table(fill = TRUE)
View(mlb_standings)

# Creating data frames from imported tibbles:
al_team_name <- data.frame(mlb_standings[[1]])
al_team_stats <- data.frame(mlb_standings[[2]][c(1,2,7,8)])
nl_team_name <- data.frame(mlb_standings[[3]])
nl_team_stats <- data.frame(mlb_standings[[4]][c(1,2,7,8)])

# Combining data frames into one table for analysis:
team_name <- bind_rows(al_team_name, nl_team_name)
team_name <- slice(team_name, -c(1, 7, 13, 19, 25, 31))
team_stats <- bind_rows(al_team_stats, nl_team_stats)
team_stats <- slice(team_stats, -c(1, 7, 13, 19, 25, 31))
regular_season <- bind_cols(team_name, team_stats)
View(regular_season)

# Cleaning up column names:
colnames(regular_season) <- c("team", "w", "l", "rs", "ra")
View(regular_season)

# Cleaning up team names to remove artifact from team logo:


# Adding columns for league and division:
regular_season$league <- NA
regular_season$division <- NA
regular_season$league[c(1:15)] <- "American"
regular_season$league[c(16:30)] <- "National"
regular_season$division[c(1:5, 15:20)] <- "East"
regular_season$division[c(6:10, 21:25)] <- "Central"
regular_season$division[c(11:15, 26:30)] <- "West"
View(regular_season)

# Reorganizing columns:
regular_season <- regular_season[ , c(1, 6:7, 2:5)]
View(regular_season)

# Changing wins, losses, runs scored, and runs against to integer format from
# character format:
regular_season$w <- as.integer(regular_season$w)
regular_season$l <- as.integer(regular_season$l)
regular_season$rs <- as.integer(regular_season$rs)
regular_season$ra <- as.integer(regular_season$ra)
View(regular_season)


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
regular_season$exponent <- 1.50*log((regular_season$rs + regular_season$ra)/regular_season$games) + 0.45

# Pythagorean Expectation:
regular_season$expected_win_pct <- round(regular_season$rs^regular_season$exponent/(regular_season$rs^regular_season$exponent +
                                                                                      regular_season$ra^regular_season$exponent), 3)

regular_season$expected_loss_pct <- 1 - regular_season$expected_win_pct

regular_season$expected_wins <- round(regular_season$expected_win_pct*regular_season$games, 0)

regular_season$expected_losses <- round(regular_season$games - regular_season$expected_wins, 0)

regular_season$performance <- ifelse(regular_season$w - regular_season$expected_wins > 2, "Above expectations",
                                     ifelse(regular_season$w - regular_season$expected_wins < -2, "Below expectations",
                                            "Within expectations"))


# Creating a table for publishing to my blog.  This will contain only the team names,
# actual wins and losses, win percentage, expected wins and losses, and expected win percentage.

pub_regular_season <- regular_season[c(1:3, 8, 4:5, 9, 6:7, 10, 14:15, 12, 16)]

colnames(pub_regular_season) <- c("Team", "League", "Division", "Games Played", "Actual Wins", 
                                  "Actual Losses", "Win %", "Runs Scored", "Runs Against",
                                  "Difference", "Expected Wins",
                                  "Expected Losses", "Expected Win %", "Actual vs Expected")

View(pub_regular_season)

# pub_regular_season$performance <- NA

write.xlsx(pub_regular_season, 
           file = "~/Documents/R/2023 MLB Season - Publish.xlsx",
           sheetName = "2023 Regular Season", 
           append = FALSE)


