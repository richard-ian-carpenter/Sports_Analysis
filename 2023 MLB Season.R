# Author: Richard Ian Carpenter
# Date Created: 19 Apr 2023
# Date Updated: 21 Apr 2023

# Project: 2023 MLB Season Analysis

# Purpose: Taking 2023 Regular Season data and using Pythagorean Expectations 
# to create an analysis of performance.

# Acknowledgements: 2023 Regular Season data comes from ESPN MLB website.

# Updates will come as the season progresses.

# Initial libraries:
library(tidyverse)
library(lubridate)
library(openxlsx)

# Reading in the data:
# spring_trng <- read.xlsx("~/Documents/R/2023 MLB Season.xlsx",
#                          sheet = "2023 Spring Trng")

regular_season <- read.xlsx("~/Documents/R/2023 MLB Season.xlsx",
                            sheet = "2023 Regular Season")

# View(spring_trng)
View(regular_season)

# colnames(spring_trng)
# colnames(spring_trng) <- tolower(colnames(spring_trng))
colnames(regular_season) <- tolower(colnames(regular_season))

# # 2023 Spring Training
# 
# # Creating win-loss percentage, run difference, and the exponent for the Pythagorean
# # Expectation model.  This will be based on the work of Chris Davenport at 
# # Baseball Prospectus.
# 
# # Games played:
# spring_trng$games <- spring_trng$w + spring_trng$l
# 
# # Win-loss percentage:
# spring_trng$wl_pct <- round(spring_trng$w/(spring_trng$games), 3)
# 
# # Run difference:
# spring_trng$run_diff <- spring_trng$rs - spring_trng$ra
# 
# # Chris Davenport's exponent:
# spring_trng$exponent <- 1.50*log((spring_trng$rs + spring_trng$ra)/spring_trng$games) + 0.45
# 
# # Pythagorean Expectation:
# spring_trng$expected_win_pct <- spring_trng$rs^spring_trng$exponent/(spring_trng$rs^spring_trng$exponent +
#                                                                     spring_trng$ra^spring_trng$exponent)
# 
# spring_trng$expected_loss_pct <- 1 - spring_trng$expected_win_pct
# 
# spring_trng$expected_wins <- round(spring_trng$expected_win_pct*spring_trng$games, 1)
# 
# spring_trng$expected_losses <- round(spring_trng$games - spring_trng$expected_wins, 1)

# Applying the same analysis to the current regular season:

# 2023 Regular Season

# Standings as of 20 Apr 2023 @ 0900

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

regular_season$expected_wins <- round(regular_season$expected_win_pct*regular_season$games, 1)

regular_season$expected_losses <- round(regular_season$games - regular_season$expected_wins, 1)

# Creating a table for publishing to my blog.  This will contain only the team names,
# actual wins and losses, win percentage, expected wins and losses, and expected win percentage.

pub_regular_season <- regular_season[c(1:3, 8, 4:5, 9, 6:7, 10, 14:15, 12)]

colnames(pub_regular_season) <- c("Team", "League", "Division", "Games Played", "Actual Wins", 
                                  "Actual Losses", "Win %", "Runs Scored", "Runs Against",
                                  "Difference", "Expected Wins",
                                  "Expected Losses", "Expected Win %")

# pub_regular_season$performance <- NA

write.xlsx(pub_regular_season, 
           file = "~/Documents/R/2023 MLB Season - Publish.xlsx",
           sheetName = "2023 Regular Season", 
           append = FALSE)


