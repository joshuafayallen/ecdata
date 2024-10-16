import polars as pl 
from selenium import webdriver
import numpy as np
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException, StaleElementReferenceException
import time 


## lets check that we actually have no paragraph data 

links_scraped = pl.read_csv('webpage_links.csv')

links_vec = links_scraped['scrape_this_url']

driver = webdriver.Firefox()

def get_texts(driver):
    text = driver.find_elements(By.CSS_SELECTOR, '#tdTesto > div > p')
    text_on_page = [text.get_attribute('textContent') for text in text]
    return text_on_page


def get_subject(driver):
    subject = driver.find_element(By.CSS_SELECTOR, '#dvTestaPagina')
    subject_page = subject.get_attribute('textContent')
    return subject_page


data = {
    'text':[],
    'subject' : [],
    'url' : []
}

next_button = driver.find_element(By.XPATH, "//*[contains(text(), 'successiva')]")




def find_next_button(driver):
    try:
        next_button = driver.find_element(By.XPATH,"//a[contains(text(), 'successiva')]")
        return next_button
    except NoSuchElementException:
        return None


def scrape_page(driver, url, max_retries=3):
    for attempt in range(max_retries):
        try:
            driver.get(url)
            time.sleep(5)
            
            while True:
                text = get_texts(driver)
                subject = get_subject(driver)
                for paragraph in text:
                    data['subject'].append(subject)
                    data['text'].append(paragraph)
                    data['url'].append(url)
                
                next_button = find_next_button(driver)
                if next_button is None:
                    break
                
                try:
                    WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, "//a[contains(text(), 'successiva')]")))
                    next_button.click()
                    time.sleep(5)  
                except (TimeoutException, NoSuchElementException, StaleElementReferenceException) as e:
                    print(f"Next button not here: {str(e)}")
                    break
            
            return True
        except Exception as e:
            print(f"Attempt {attempt + 1} failed for {url}: {str(e)}")
            if attempt < max_retries - 1:
                time.sleep(5)
    
    print(f"Failed to scrape {url} after {max_retries} attempts")
    failed_urls.append(url)
    return False

def scrape_multiple_pages(driver, urls, max_retries=3):
    for url in urls:
        success = scrape_page(driver, url, max_retries)
        if not success:
            print(f"Failed to scrape: {url}")


test_vec = links_vec[0:3]

test_data = scrape_multiple_pages(driver, urls = test_vec)


big_data = scrape_multiple_pages(driver, urls = links_vec)


monti_statements = pl.DataFrame(data)


monti_statements.head()

## so this is really just a weird ones

import os


os.mkdir('data')

monti_statements.write_csv('data/raw_monti_data.csv')


