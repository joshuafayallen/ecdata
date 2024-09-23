test_that('checking the link building function',
{

## we want to test to see what happens when we feed the linkbuilder 
## a bad link 
  
  
objs = link_builder(country = 'United States of America', ecd_version = '1.0.0')
  
expect_equivalent(objs, 'https://github.com/joshuafayallen/executivestatements/releases/download/1.0.0/united_states_of_america.parquet')


})
