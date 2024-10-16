library(ecdata)
library(countrycode)
library(arrow)
library(tidyverse)

full_ecd = load_ecd(full_ecd = TRUE)

leader_data = read_csv(here::here('leader-data', 'executives.csv')) |>
  janitor::clean_names() |>
  mutate(across(starts_with('term'), \(x) mdy(x)))

clean_leader_data = leader_data |>
  mutate(country = case_when(
         country == 'South Korea' ~ 'Republic of South Korea',
         country == 'USA' ~ 'United States of America',
         country == 'Azerbijan' ~ 'Azerbaijan',
         .default = country
  )) |>
  filter(str_detect(country, 'Portugal', negate = TRUE))

sans_portugal = full_ecd |>
  filter(country != 'Portugal')


## the problem is that 
## it is joining by exact term dates 

## this will cover the ones where there is no na 
joined_data = sans_portugal |>
  left_join(clean_leader_data, join_by(country, closest(date <= term_end))) |>
  mutate(executive = coalesce(executive, exec_name)) |>
  select(-c(exec_name:term_end))







check = joined_data |>
  filter(country == 'United Kingdom') 


portugal_ecd = full_ecd |>
  filter(country == 'Portugal') |>
  mutate(office = 'President')

portugal_pm = read_csv('Portugal-Josh/PM/portugal_statements_add_urls.csv') |>
  mutate(office = 'Prime Minister')


bound_portugal = bind_rows(portugal_ecd, portugal_pm)

leader_portugal_data = leader_data |>
  filter(str_detect(country, 'Portugal')) |>
  separate_wider_delim(cols = country, names = c('country', 'office') ,delim = ' ') |>
  mutate(office = ifelse(office == 'PM', 'Prime Minister', 'President'))

joined_portugal = bound_portugal |>
  left_join(leader_portugal_data, join_by(country, office, closest(date >= term_start))) |>
  mutate(exec_name = case_when(
         is.na(exec_name) & office == 'Prime Minister' ~ 'Luis Montenegro',
         is.na(exec_name) & office == 'President' ~ 'Marcelo Rebelo de Sousa',
         .default = exec_name),
         url = ifelse(is.na(url), 'https://www.portugal.gov.pt/pt/gc23/comunicacao/noticia?i=portugal-apoia-com-dez-milhoes-de-euros-agencia-da-onu-para-os-refugiados-palestinianos',
        url),
      executive = coalesce(executive, exec_name),
      ) |>
  select(-c(exec_name:term_end), -tags) 


joined_portugal$tags |> table()

check2 = joined_data |>
  filter(is.na(executive))


bound_with_portugal = joined_data |>
  bind_rows(joined_portugal)

sans_na = bound_with_portugal|>
  filter(!is.na(executive))


fix_these = bound_with_portugal |>
  filter(is.na(executive)) |>
  left_join(clean_leader_data, join_by(country, closest(date >= term_start))) |>
  mutate(executive = coalesce(executive, exec_name)) |>
  select(-c(exec_name:term_end)) |>
  mutate(executive = case_when(country == 'Germany' ~ 'Olaf Scholz',
                              country == 'Indonesia' ~ 'Joko Widodo', 
                               country == 'Republic of South Korea'  ~ 'Yoon Suk Yeol',
                               country == 'Venezuela' ~ 'Nicolás Maduro',
                              .default = executive))


all_together = bind_rows(sans_na, fix_these)

all_together = all_together |>
  mutate(country = ifelse(country == 'Republic of South Korea', 'Republic of Korea', country),
                          isonumber = countrycode(sourcevar = country,
                          origin = 'country.name',
                          destination = 'iso3n'),
                          gwc = countrycode(sourcevar = isonumber,
                          origin = 'iso3n',
                          ## gledistch ward country codes for hong kong are na 
                          ## because well ..
                          destination = 'gwc'),
                          cowcodes = countrycode(sourcevar = country,
                          origin = 'country.name',
                          destination = 'cowc'),
                          polity_v = countrycode(sourcevar = country,
                          origin = 'country.name',
                          destination = 'p5c'),
                          polity_iv = countrycode(sourcevar = country,
                          origin = 'country.name',
                          destination = 'p4c'),
                          vdem = countrycode(sourcevar = country,
                          origin = 'country.name',
                          destination = 'vdem'),
                          year_of_statement = year(date),
                          saving_name = str_replace_all(country, ' ', '_'),
                          saving_name = str_squish(saving_name),
                          saving_name = str_to_lower(saving_name)
                )

all_together |>
  select(-saving_name) |>
write_parquet('piggyback-release-data/full_ecd.parquet')

make_splits = split(all_together, all_together$saving_name)

saving_name = names(make_splits)

make_splits = map(make_splits, \(x) select(x, -saving_name))


walk2(make_splits, saving_name, \(data, name) write_parquet(data, paste0('piggyback-release-data/', paste0(name, '.parquet'))))

country_files = list.files('piggyback-release-data', pattern = '*.parquet', full.names = TRUE)


walk(country_files, \(x) piggyback::pb_upload(x, repo ='Executive-Communications-Dataset/ecdata', tag = '1.0.0'))



