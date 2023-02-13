# Header #####
# Primary Author: Jenna Goldberg 
# Last Editor: 
# Creation date: 04/24/2020
# Last Modified: 

# Depends on:
#      Describes scripts that feed into this script

#Purpose of script : Introductory R Script for DEAL Students 

# Change Log:

#### Some notes on R and setting up the environment ####

#1 This "#" symbol comments out code (shortcut is ctrl + shift + c for chunks)

#2 How to set up an r project (and why)

#3 Literally how do I run code? For one line: ctrl + enter
# Keyboard shortcuts are very important! 

#3 How to install and read libraries (and why)
# Think about your phone, when you first got it, you had a few basic apps. 
# If you want different apps, you can download them. 
# There are apps that do the same thing. 
# Packages are what makes open source software so valuable. 
# Today I'm just going to focus on 2 of my favorites. 
install.packages('here')  
#here is a simple package that helps you read & save data to different folders
install.packages('tidyverse') 
# the tidyverse is a set of packages that were developed to enhance R's ability 
# to do data science. It is very popular, for good reasons we'll talk about later! 
# Once you've installed these packages, you don't need to re-install them again
# So you can comment out those two lines of code above once you've run them 
install.packages('read.xlsx')

# Script Setup #### 
#clear environment 
rm(list = ls())
gc()

#tells R that you might want to use functions from these packages :) 
library(here)
library(tidyverse)

# R can do math - see the results in the console! 
5 * 8 
# Run code by clicking "run", pressing ctrl + enter, or just enter in the console
5/8

# you can save values 
value <- 5 + 2
# <- is the assignment vector, you can also use = 
# but it's not best practice for reasons that will become clear 

# you can also save lists 
list <- c(1, 2, 3)
list_100 <- seq(1,100)

mean(list_100)
#looking up functions!! R has nice built in documentation
# each function has arguments, (things you need to specify for it to do what you need) 
?mean()

# OK - those are some important basic ideas! 
# Lets see how R deals with data. 
# But first, look at all this stuff in our environment, lets clear it out 
rm(list = ls())

# Import Data #### 
# import xlsx file 
# here I'm using just one function from a package, so I cite it directly 
county_population <- 
  openxlsx::read.xlsx(
    "/Users/jennagoldberg/Documents/Duke Economics/DEAL R Tutorials/Introduction/Data/county_population.xlsx"
  )
# this code won't work bc its a hard file path 

# this is some ugly code 
# note that I'm using an R project file to set the working directory 
# here package knows where this is 
here()
# this just returns the text string for our wd

# with the here package the data import code from above can become 
county_population <- 
  openxlsx::read.xlsx(
    here("Data", "county_population.xlsx")
  )


# import csv file 
county_income <-
  read.csv(
    here("Data", "county_income.csv"),
    colClasses = c("character", "numeric") # define variable types, not required
  ) 

# note the 'import dataset' menu item
# you can absolutely use this for help, but copy paste the code into your script 
# you can click on these tables in our environment to look at the data directly

# Data Manipulation #### 
# This section shows off two different ways to do common tasks, 
# Demonstrates how legible the tidyverse is by comparison to base R 
# Hence its popularity 
# join tables 
# tidyverse - inner_join 

wide_data <- 
  inner_join(
    county_population, 
    county_income
  )

# implicit - joins on columns with the same name,
# you can define explicitlyy 
wide_data <- 
  inner_join(
    county_population, 
    county_income,
    by = "GEOID"
  )


# filtering observations 
# base R 
nc_only <- 
  wide_data[wide_data$State_Name == "North Carolina",] 
# base R syntax for subsets of data: data[rows, cols]

# tidyverse 
nc_only <-
  filter(
    wide_data,
    State_Name == "North Carolina"
  )

# OR even better! 
nc_only <- 
  wide_data %>% 
  filter(
    State_Name == "North Carolina"
  )

# what is the %>% doing? this is a 'pipe operator'
# it allows you to chain functions together in a nice legible way
# this %>% is the original tidyverse pipe
# newer base R pipe: |>, does same thing for the most part 
# Keyboard shortcut: ctrl + shift + m

# selecting columns
# base R 
subset_cols <- wide_data[, c("GEOID", "County_Population")] 
# tidyverse
subset_cols <- 
  wide_data %>% 
  select(GEOID,
         County_Population
         )

# with the pipe operator, we can chain things together, like so 
sample_pipe_operations <- 
  wide_data %>% 
  filter(
    State_Name == "North Carolina"
  ) %>% 
  select(County_Name, 
         County_Population)
# read it like "take data, then do this, then do this "
# step-by-step structure makes it easier to read & debug code

# defining new variables 
# base R 
wide_data$pct_below_pov_rate <- 
  wide_data$Pop_Below_Poverty_Rate/wide_data$County_Population
# tidyverse
wide_data <-
  wide_data %>% 
  mutate(
    pct_below_pov_rate = Pop_Below_Poverty_Rate/County_Population
  )

# you get the point - tidyverse is very legible, easy to learn 
# I'll mostly focus on tidyverse in these sessions

# Data Analysis 
# group by summarize 
# works like a pivot table 
state_pop <- 
  wide_data %>% 
  group_by(State_Name) %>% 
  summarise( 
    State_Pop = sum(County_Population)
    )
# you can also do summary stats in summarise() - mean(), median(), min/max, sd, etc. 

# basic graph 
# when you run this code it will pop up in the bottom right panel
wide_data %>% 
  ggplot() + 
  geom_point(
    aes(x = pct_below_pov_rate,
        y = Med_HH_Inc)
  )


# linear model 
basic_model <-
  lm(
    Med_HH_Inc ~ pct_below_pov_rate,
    data = wide_data
  )
summary(basic_model)

# Export data to csv - here package is still our friend! 
write.csv(
  wide_data,
  here("Data", paste0("Tutorial_Data_Output_", Sys.Date(), ".csv")),
  row.names = FALSE
)
