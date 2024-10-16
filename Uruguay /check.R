library(tidyverse)

ur = read_csv('exe_com_uruguay.csv')

ur$text[1]


## lets just write it to ur statements 


write_csv(ur,'uruguay_statements.csv ')