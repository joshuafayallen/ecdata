%pip install random
%pip install polars
%pip install requests
%pip install selenium


import random
import time
from selenium.webdriver.common.by import  By
import requests 
from selenium import webdriver
import polars as pl
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from selenium.webdriver.support.ui import Select, WebDriverWait


base_url = 'https://www.bmeia.gv.at/ministerium/presse/reden'


driver = webdriver.Firefox()

driver.maximize_window()

driver.get(base_url)


accept_cookies = driver.find_element(By.CSS_SELECTOR, ".tru_cookie-d-full")


accept_cookies.click()

exit_but = driver.find_element(By.CSS_SELECTOR, '.tru_bnr-close-btn')


exit_but.click()


def move_page(driver, year, month):
    Select(WebDriverWait(driver, 20).until(EC.visibility_of_element_located((By.ID, "press-year")))).select_by_value(year)
    Select(WebDriverWait(driver, 20).until(EC.visibility_of_element_located((By.ID, "press-month")))).select_by_visible_text(month)
    time.sleep(5)
    return driver


def scrape_links(driver):
    get_urls = driver.find_elements(By.XPATH, "/html/body/main/div/div/div[2]/div[2]/div/div[1]/div/div/div/h3/a")
    get_refs = [get_urls.get_attribute('href') for get_urls in get_urls]
    return get_refs


months_lst = ["Jänner", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]

break_out = False

import numpy as np 

years = np.arange(2003, 2023, 1).tolist()

years_lst = [str(element) for element in years]


years_lst.remove('2016')

for year in years_lst:
    for month in months_lst:
        driver = move_page(driver, month = month, year = year)
        links_page = scrape_links(driver)
        links.extend(links_page)
        time.sleep(5)
        if month == "December" and year == "2023":
           break_out = True
           break
        if break_out:
            break

links_df = pl.DataFrame(links, schema=['url'])



links_df.write_csv("austrian_links.csv")

