%pip install polars 
%pip install selenium

import polars as pl 
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import WebDriverException 
from selenium
import time


base_url = 'https://kormany.hu/miniszterelnok/hirek'


driver = webdriver.Firefox()

driver.maximize_window()

driver.get(base_url)



cookies_button = driver.find_element(By.CSS_SELECTOR, 'button.button:nth-child(1)')

cookies_button.click()


links = driver.find_elements(By.CLASS_NAME, 'title')

check = [links.get_attribute('href') for links in links]

date = driver.find_elements(By.CLASS_NAME, 'date')

[date.get_attribute('textContent') for date in date]

next_button_first_page = driver.find_element(By.XPATH, '/html/body/app-root/app-base/app-ministry/div/div/div[2]/app-ministry-news-list/div/app-pager/div/ul/li[6]/a')

### ugh it looks like this 

next_button = driver.find_element(By.XPATH, '/html/body/app-root/app-base/app-ministry/div/div/div[2]/app-ministry-news-list/div/app-pager/div/ul/li[7]/a')

next_button.click()

def get_links(driver):
    links = driver.find_elements(By.CLASS_NAME, 'title')
    links_all = [links.get_attribute('href') for links in links]
    return links_all


def get_subject(driver):
    title = driver.find_elements(By.CLASS_NAME, 'title')
    title_all = [title.get_attribute('textContent') for title in title]
    return title_all


def get_dates(driver):
    date = driver.find_elements(By.CLASS_NAME, 'date')
    date_all = [date.get_attribute('textContent') for date in date]
    return date_all

data = {
    'links': [],
    'title': []
}

data_two = {
    'date': []
}

first_page_links = get_links(driver)

first_page_dates = get_dates(driver)

first_page_subject = get_subject(driver)

data['links'].append(first_page_links)
data_two['date'].append(first_page_dates)
data['title'].append(first_page_subject)

## ahh it looks like the website design team got lazy
## the name of the links are title and then this is causing you problems

links_subject = pl.DataFrame(data, strict=False).explode(['links', 'title']).filter(pl.col('links').is_not_null())

date_data = pl.DataFrame(data_two).explode('date')

pl.concat([links_subject, date_data], how = 'horizontal')


next_button_first_page = driver.find_element(By.XPATH, '/html/body/app-root/app-base/app-ministry/div/div/div[2]/app-ministry-news-list/div/app-pager/div/ul/li[6]/a')

next_button_first_page.click()

next_button_first_page.get_attribute('class')

next_button = driver.find_element(By.XPATH, '/html/body/app-root/app-base/app-ministry/div/div/div[2]/app-ministry-news-list/div/app-pager/div/ul/li[7]/a')

next_button.click()

next_button.get_attribute('class')


while True:
    try:
        date_page = get_dates(driver)
        data_two['date'].append(date_page)
        
        title_page = get_subject(driver)
        data['title'].append(title_page)
        
        links_page = get_links(driver)
        data['links'].append(links_page)
        
        try:
            next_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, '/html/body/app-root/app-base/app-ministry/div/div/div[2]/app-ministry-news-list/div/app-pager/div/ul/li[7]/a'))
            )
        except NoSuchElementException:
            print('Last page reached')
            break
        
        next_button.click()
        time.sleep(5)
        
    except Exception as e:
        print(f"An error occurred: {e}")
        break

link_title_dat = pl.DataFrame(data).explode(['links', 'title']).filter(pl.col('links').is_not_null())


dates_data = pl.DataFrame(data_two).explode('date')

all_together = pl.concat([dates_data, link_title_dat], how = 'horizontal')

all_together.write_csv('current_hungarian_links.csv')

driver.quit()
