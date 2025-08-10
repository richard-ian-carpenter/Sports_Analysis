'''
Author: Richard Ian Carpenter

Date Created: 04 Aug 2025
Date Updated: 06 Aug 2025

Project: MLB Season Analysis

Purpose: Taking regular season data and using Pythagorean Expectations 
to create an analysis of performance.

This is version 3 of my R script, which now reads data from the ESPN website.
Webscraping is more efficient than doing copypasta into a spreadsheet.  Also,
this is built off of my earlier iterations that I used during the 2023 and 2024 
MLB seasons.

Acknowledgements: Regular season data comes from ESPN MLB website: https://www.espn.com/mlb/standings

Updates will come as the season progresses.
'''

import os
import pandas as pd # also install dependency 'lxml'
import numpy as np
import requests
import json
# from bs4 import BeautifulSoup
import html5lib


# Initial set up to get data from ESPN:
mlb_season = "2025"
espn_mlb_url = "https://www.espn.com/mlb/standings/"
mlb_standings = pd.read_html(espn_mlb_url)

# Checking data:
mlb_standings

# Creating dataframes from the imported data and only using columns for wins, losses, runs scored, and runs against:
al_team_name = pd.DataFrame(data = mlb_standings[0])
al_team_stats = pd.DataFrame(data = mlb_standings[1][[0,1,6,7]])
nl_team_name = pd.DataFrame(data = mlb_standings[2])
nl_team_stats = pd.DataFrame(data = mlb_standings[3][[0,1,6,7]])

# Cleaning up that dataframes:
al_team_name.columns = al_team_name.columns.astype(str)
al_team_name = al_team_name.rename(columns={"0": "team_name"})
al_team_stats.columns = al_team_stats.columns.astype(str)
al_team_stats = al_team_stats.rename(columns={"0": "win", "1": "loss", "6": "rs", "7": "ra"})
al_team_name = al_team_name.drop(al_team_name.index[[0, 6, 12]])
al_team_stats = al_team_stats.drop(al_team_stats.index[[0, 6, 12]])

nl_team_name.columns = nl_team_name.columns.astype(str)
nl_team_name = nl_team_name.rename(columns={"0": "team_name"})
nl_team_stats.columns = nl_team_stats.columns.astype(str)
nl_team_stats = nl_team_stats.rename(columns={"0": "win", "1": "loss", "6": "rs", "7": "ra"})
nl_team_name = nl_team_name.drop(nl_team_name.index[[0, 6, 12]])
nl_team_stats = nl_team_stats.drop(nl_team_stats.index[[0, 6, 12]])

