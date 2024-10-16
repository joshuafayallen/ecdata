import ibis 
import ibis.selectors as s 
from ibis import _
import polars as pl 
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.wait import WebDriverWait 
from selenium.webdriver.firefox.options import Options 
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions as EC
import time 



driver = webdriver.Firefox()


url = 'https://www.primeminister.gr/category/activity/statements'

driver.get(url)

def get_urls(driver):
     url_page = driver.find_elements(By.CSS_SELECTOR, "h3 > a")
     all_urls = [url_page.get_attribute('href') for url_page in url_page]
     return all_urls



driver.maximize_window()
refs = []

while True: 
    try: 
        links = get_urls(driver)
        refs.extend(links)
        WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.CSS_SELECTOR, '.td_ajax_load_more > i:nth-child(1)'))).click()
    except TimeoutException:
        break


links_data = ibis.memtable(refs, columns=["urls"])

links_data.head()

remove_dupes = links_data.distinct(on = 'urls')

remove_dupes.head()


write_this = remove_dupes.to_csv("data/greece_data.csv")

links_data = ibis.read_csv("data/greece_data.csv")

url_vec = links_data['urls'].execute()



def get_texts(driver):
    text_data = driver.find_elements(By.CSS_SELECTOR, ".td-post-content p")
    texts = [text_data.get_attribute('textContent') for text_data in text_data]
    return texts


def get_date(driver):
    date_element = driver.find_element(By.CSS_SELECTOR, '.td-post-date')
    date = date_element.get_attribute('textContent')
    return date 

def get_subject(driver):
    subject = driver.find_element(By.CLASS_NAME, 'entry-title')
    subject_text = subject.get_attribute('textContent')
    return subject_text

for i in links_vec:
    driver.get(i)
    text_page = get_texts(driver)
    date_page  = get_date(driver)
    subject_page = get_subject(driver)
    for paragraph in text_page:
        data["date"].append(date_page)
        data["subject"].append(subject_page)
        data["text"].append(paragraph)
        data["url"].append(i)
    print('Done Scraping', i)
    time.sleep(5)



full_data = pl.DataFrame(data)


full_data.write_csv("data/greece_statements.csv")

driver.quit()
