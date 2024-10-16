library(tidyverse)


brazil_files = list.files(
                          pattern = "*.csv",
                          full.names = TRUE)

names_vec = basename(brazil_files) |>
  str_remove('.csv') |>
  str_to_lower()

# we gettting rid of brazil statementens
names_vec = names_vec[-1]

brazil_files = brazil_files[-1]

read_in = map(brazil_files, read_csv)  

read_in  = map(read_in, \(x) janitor::clean_names(x))




fix_date_fun = \(data){

  clean = data |>
    mutate(fix_date = dmy(date),
           fix_date_two = mdy(date),
           date = coalesce(fix_date, fix_date_two)) |>
    select(-starts_with('fix'))

  clean


}


cleaned_dates = map(read_in, \(x) fix_date_fun(x))

 bind_data = cleaned_dates |>
  list_rbind(names_to = 'executive')

## umm flagging this here but I there is a weird row with juan's name in it? 
add_titles = bind_data |>
  mutate(id_flag = ifelse(!is.na(file), row_number(), NA), .by = file) |>
  mutate(fix_title = ifelse(!is.na(id_flag), str_remove_all(file, '\\d+'), NA ),
         fix_title = str_remove_all(fix_title, '--|.pdf|---'),
         fix_title = str_to_title(fix_title),
        title = coalesce(title, fix_title),
        text = coalesce(content, text),
        url = coalesce(url, x0 ),
         executive = case_match(president,
        'Lula' ~ 'Lula da Sillva',
        'Rousseff' ~ 'Dilma Rousseff',
        'Sarney' ~ 'José Sarney', 
         'Temer' ~ 'Michel Temer', 
        'Cardoso' ~ 'Fernando Cardosa')) |>
  slice(-3482) |>
  select(-id_flag, -fix_title, -president, -content, -x0, -note, -year)

add_titles$executive |> table()


redo_these = add_titles |>
  filter(is.na(title) | nchar(title) <= 3) |>
  write_csv('/Users/josh/Library/CloudStorage/Dropbox/EAD NSF RA Work/Scraping/Brazil-juan/add_titles_to_these.csv')



clean = add_titles |>
  filter(!is.na(title) | nchar(title) > 3)


glimpse(clean)

write_csv(clean, 'brazil_statements.csv')

