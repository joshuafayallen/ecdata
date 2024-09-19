#### EAP: EX COMM ####
#### ISSUE DATE INPUTTING

### THIS CODE IS MADE TO CREATE THE FUNCTION TO WEBSCRAP INFORMATION FROM ECUADOR EXE COMM ###
# Setup
rm(list=ls())

library(tidyverse)  
library(rvest)      
library(stringr)    
library(lubridate)  
library(tictoc)
library(dplyr)
library(stringi)
library(purrr)
library(pdftools)
library(stringr)


f.extract_urls <- function(page) { 
  
  page %>%
    html_elements("#main") %>%
    html_elements("a") %>%
    html_attr("href")
  
  }


f.pdf.download <- function(url, index){
  
  name <- as.character(index)
  download.file(url, destfile = str_c(name, '.pdf'), mode = "wb")
  
}


f.pdf.import <- function(path) {
  
    text_aux <- pdf_text(path)
    
    # Text
    all_text <- paste(text_aux, collapse = " ") # Concatenate all text data into one string
    paragraphs <- unlist(strsplit(all_text, "(?<=\\.|:)\\s*\n\n", perl = TRUE))  # Split the text into paragraphs based on double newline (\n\n)
    paragraphs <- str_trim(paragraphs) # Remove leading/trailing whitespace from each paragraph
    paragraphs <- str_squish(paragraphs)
    
    df_aux <- data.frame(text = paragraphs, stringsAsFactors = FALSE)
    
    # Title
    first_row_text <- df_aux$text[1]
    title_aux <- str_extract_all(first_row_text, "\\b[A-Z]{2,}\\b")[[1]]
    title <- paste(title_aux, collapse = " ")
    
  
    pattern <- "\\b(?:\\d{1,2} de \\w+ del? \\d{4}|\\w+ \\d{1,2} / \\d{4}|\\d{1,2} de \\w+ \\d{4}|\\w+ \\d{1,2} de \\d{4})\\b"
    date <- str_extract(first_row_text, pattern)
    
    
    
    df_final <- df_aux %>%
      mutate(title = title,
             date = date)
    
  return(df_final)
  
}


f.main.extract <- function(url) {

  
  all_urls <- 
    url %>%
    read_html(.) %>%
    f.extract_urls(.) %>%
    unlist()
  
  all_urls <- all_urls[!all_urls %in% c("#collapse123", "#collapse119")]
  

  imap(all_urls, f.pdf.download)
    
 
    n <- as.numeric(length(all_urls))
    all_path <- paste0(seq(1:n), '.pdf')
    
   all_path %>%
      map_dfr(~ {
        f.pdf.import(.)
      })

}

# Perform the webscrapping:
url <- "https://www.presidencia.gob.ec/discursos/"

wd <- "/Users/jaimelindh/Dropbox/1. UNC/4. RA/Executive Approval/Paper Dataset/ecuador/pdf"
setwd(wd)

tic()
data <- f.main.extract(url)
toc()


df <- data %>%
  group_by(title) %>%
  mutate(type = "speeches",
         speaker = 'president') %>%
   ungroup()


wd <- "/Users/jaimelindh/Dropbox/1. UNC/4. RA/Executive Approval/Paper Dataset/ecuador"
setwd(wd)

write.csv(df, "exe_com_ecuador.csv")





