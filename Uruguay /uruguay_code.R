#### EAP: EX COMM ####

### THIS CODE IS MADE TO CREATE THE FUNCTION TO WEBSCRAP INFORMATION FROM URUGUAY EXE COMM ###
# Setup
rm(list=ls())

library(tidyverse)  # General-purpose data wrangling
library(rvest)      # Parsing of HTML/XML files  
library(stringr)    # String manipulation
library(lubridate)  # DateTime manipulation
library(tictoc)
library(dplyr)
library(stringi)

# Create functions to extract key information of each press release
f.date<-function(html){
  html %>%
    html_element(".Page-date") %>%
    html_text2() %>%
    dmy()
}

f.title<-function(html){
  html %>%
    html_element(".Page-Title") %>%
    html_text2() 
}

f.text <-function(html){
    html %>%
      html_elements("#block-starterkits-content > article > div") %>%
      html_elements("p") %>%
      html_text2()
}


# Create function that creates main matrix for each press release
f.all <- function(html){ 
  tibble(
    date = f.date(html),
    title = f.title(html),
    text = f.text(html)
    )
  }

# Function to extract and prepend URLs from a single page
f.extract_urls <- function(page) { 
  page %>%
    html_elements("#block-starterkits-content > div > div > ul > li > article > h3 > a") %>%
    html_attr("href") %>%
    paste0("https://www.gub.uy", .)
}

# Main function to perform the scraping
f.main.extract <- function(n_intial, n_pages) {
  
  url_pattern <- str_c("https://www.gub.uy", '/presidencia/comunicacion/noticias?page=')
  
  list_of_pages <- str_c(url_pattern, n_intial:n_pages) %>% 
    map(read_html)
  
  all_urls <- list_of_pages %>% 
    map( ~{
      Sys.sleep(runif(1, 0.05, 0.1))
      f.extract_urls(.)
  }) %>% 
    unlist()
  
  result <- map2_dfr(all_urls, 
                     all_urls %>% map(read_html), 
                     ~ {
                       Sys.sleep(runif(1, 0.05, 0.1))
                       extracted_data <- f.all(.y)
                       extracted_data$url <- .x
                       extracted_data
                     })
  
  return(result)
  
}


# Since the government website blocks scraping when attempting all the pages at once, the code collects the press releases in four stages

# Stage 1: extract 0:1000 pages
ntotal <- 1000
nintial <- 0
base_url <- "https://www.gub.uy"

tic()
data1 <- f.main.extract(nintial, ntotal)
toc()

# Stage 2: extract 1001:2000 pages
ntotal2 <- 2000
nintial2 <- 1001

tic()
data2 <- f.main.extract(nintial2, ntotal2)
toc()

# Stage 3: extract 2001:3000 pages
ntotal3 <- 3000
nintial3 <- 2001

tic()
data3 <- f.main.extract(nintial3, ntotal3)
toc()

# Stage 4: 3001:3303 pages url
ntotal4 <- 3322
nintial4 <- 3001

tic()
data4 <- f.main.extract(nintial4, ntotal4)
toc()

# Store raw file to cvs format
setwd("/Users/jaimelindh/Dropbox/1. UNC/4. RA/Executive Approval/Paper Dataset/uruguay")

write.csv(data1, "data1.csv")
write.csv(data2, "data2.csv")
write.csv(data3, "data3.csv")
write.csv(data4, "data4.csv")


# Select relevant columns from each data frame and bind them together
data <- data_list %>%
  map(~ select(., date, title, text, url)) %>%
  bind_rows()

# Filter out blank rows without text
data <- data %>%
  mutate(text_cleaned = trimws(text)) %>%
  filter(text_cleaned !="")


# Filter out press release that only about executive
df <- data %>%
  group_by(title) %>%
  mutate(exe_com = ifelse(any(grepl("presidente de la republica|mujica|lacalle|vásquez", text, ignore.case = TRUE)), 1, 0)) %>%
  filter(exe_com==1) %>%
  select(date, title, text) %>%
  mutate(type = "press release",
         speaker = "president") %>%
   ungroup()

# Export to csv
write.csv(df, "exe_com_uruguay.csv")



