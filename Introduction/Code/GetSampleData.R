############
# Primary Author: Jenna Goldberg 
# Last Editor: 
# Creation date: 11/8/2022
# Last Modified: 

# Grab census data for R intro session

# Setup #### 
#clear environment 
rm(list=ls())
gc()
# load packages 
library(here)
library(tidyverse)
library(tidycensus)


census_api_key("ab42f2f3c51bdba9537f3dc8e2e01b79f3c3b6cc")

#lookup variables 
v20 <- load_variables(2020, "acs5", cache = TRUE)

variables <- 
  c("B01001_001",
    "B19013_001",
    "B06012_002"
    )

acs_data <- 
  get_acs(
    geography = "county",
    variables = variables,
    year = 2020,
    output = "wide"
  ) %>% 
  select(
    GEOID, 
    Med_HH_Inc = B19013_001E,
    County_Population = B01001_001E,
    Pop_Below_Poverty_Rate = B06012_002E
    #E = estimate, M = margin of error, P = percent 
  ) 


fips_codes_lim <-
  fips_codes %>% 
  mutate(
    GEOID = paste0(state_code, county_code)
  ) %>% 
  select(GEOID,
         State_Name = state_name,
         County_Name = county)

wide_data <- 
  acs_data %>% 
  left_join(fips_codes_lim)

county_pop <- 
  wide_data %>% 
  select(GEOID, 
         State_Name,
         County_Name,
         County_Population,
         Pop_Below_Poverty_Rate) 


county_income <- 
  wide_data %>% 
  select(GEOID, 
         Med_HH_Inc) 

write.csv(
  county_income,
  here("Data", "county_income.csv"),
  
  row.names = FALSE
)

openxlsx::write.xlsx(
  county_pop,
  here("Data", "county_population.xlsx"),
  rowNames = FALSE
)
