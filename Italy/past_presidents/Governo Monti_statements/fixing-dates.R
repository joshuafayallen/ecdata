library(tidyverse)


pdf_data = read_csv('data/merged_pdfs.csv')

urls = read_csv('data/merged_webs.csv')


monti_statements = bind_rows(pdf_data, urls) |> 
  mutate(date = dmy(date)) 


write_csv(monti_statements, 'data/monti_statements.csv')
