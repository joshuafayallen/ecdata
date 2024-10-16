%pip install polars
%pip install selenium
%pip install numpy

import polars as pl
import selenium 
import numpy as np
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException, StaleElementReferenceException
from selenium import webdriver
import time 


driver = webdriver.Firefox()

links_dat = pl.read_csv('links.csv').filter(pl.col('speaker').is_in(['Presidenza', 'Presidente CdM']))

links_vec = links_dat['url']

driver.get(links_vec[0])


text = driver.find_elements(By.CSS_SELECTOR, '#tdTesto > div > p')

texts = [text.get_attribute('textContent') for text in text]

subject = driver.find_element(By.CSS_SELECTOR, '#dvTestaPagina')

subject.get_attribute('textContent')

find_links = driver.find_element(By.CSS_SELECTOR, '#tdTesto > div > ul > li > a')

find_links.get_attribute('href')

def get_texts(driver):
    text = driver.find_elements(By.CSS_SELECTOR, '#tdTesto > div > p')
    text_on_page = [text.get_attribute('textContent') for text in text]
    return text_on_page


def get_subject(driver):
    subject = driver.find_element(By.CSS_SELECTOR, '#dvTestaPagina')
    subject_page = subject.get_attribute('textContent')
    return subject_page

def get_links(driver):
    try:
        links = driver.find_element(By.CSS_SELECTOR, '#tdTesto > div > ul > li > a')
        links_on_page = links.get_attribute('href')
        return links_on_page
    except NoSuchElementException:
        return False


def scrape_page(driver, url):
    for attempt in range(max_retries):
        try:
            driver.get(url)
            time.sleep(5)
            
            text = get_texts(driver)
            subject = get_subject(driver)
            link = get_links(driver)
            
            if link is None:
                data['subject'].append(subject)
                data['text'].append(text)
                data['url'].append(url)
            else:
                second_data['og_url'].append(url)
                second_data['scrape_this_url'].append(link)
            
            return True
        except Exception as e:
            print(f"Attempt {attempt + 1} failed for {url}: {str(e)}")
            if attempt < max_retries - 1:
                time.sleep(5)
    
    print(f"Failed to scrape {url} after {max_retries} attempts")
    failed_urls.append(url)
    return False

# Initialize data structures
data = {
    'text': [],
    'subject': [],
    'url': []
}

second_data = {
    'og_url': [],
    'scrape_this_url': []
}

failed_urls = []
max_retries = 2

# Main scraping loop
for url in test_vec:
    scrape_page(driver, url)

driver.quit()

data_check = pl.DataFrame(second_data)

driver = webdriver.Firefox()


for url in links_vec:
    scrape_page(driver, url)


regular_monti_dat = pl.DataFrame(data)

more_scrapping_data = pl.DataFrame(second_data, strict = False)

regular_monti_dat.head()


more_scrapping_data[3,1]


## it is probably just going to be easier to go and scrape everything 

subject = driver.find_elements(By.XPATH, '//*[@id="tdSecondoTesto"]/div/table/tbody/tr[2]/td[2]/a/font/font')

subject.get_attribute('textContent')

driver.get(more_scrapping_data[0,1])


## honestly it may be to hard to grab the individualized subjects

subject = driver.find_element(By.CSS_SELECTOR, '#dvTestaPagina > h1')

subject.get_attribute('textContent')


date = driver.find_element(By.CSS_SELECTOR, '#pData')

date.get_attribute('textContent')



text = driver.find_elements(By.CSS_SELECTOR, '#tdTesto > div')

[text.get_attribute('textContent') for text in text]

next_button = driver.find_element(By.XPATH, "//*[contains(text(), 'successiva')]")


next_button.click()


## okay we have our functions 

def get_texts(driver):
    text = driver.find_elements(By.CSS_SELECTOR, '#tdTesto > div > p')
    text_on_page = [text.get_attribute('textContent') for text in text]
    return text_on_page


def get_subject(driver):
    subject = driver.find_element(By.CSS_SELECTOR, '#dvTestaPagina > h1')
    subject_page = subject.get_attribute('textContent')
    return subject_page


def get_date(driver):
    date = driver.find_element(By.CSS_SELECTOR, "#pData")
    date_page = date.get_attribute('textContent')
    return date_page


links_vec  = second_data['scrape_this_url']

def find_next_button(driver):
    # Implement your logic to find the next button
    # Return the button element if found, otherwise return None
    try:
        next_button = driver.find_element(By.XPATH,"//a[contains(text(), 'Next')]")
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
                data_two['subject'].append(subject)
                data_two['text'].append(text)
                data_two['url'].append(url)
                
                next_button = find_next_button(driver)
                if next_button is None:
                    break
                
                try:
                    WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, "//a[contains(text(), 'Next')]")))
                    next_button.click()
                    time.sleep(5)  # Wait for the next page to load
                except (TimeoutException, NoSuchElementException, StaleElementReferenceException) as e:
                    print(f"Failed to click next button: {str(e)}")
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

# Usage
data_two = {'subject': [], 'text': [], 'url': []}



test_vec = more_scrapping_data.sample(n = 5)

test_vec = test_vec['scrape_this_url']

failed_urls = []


#### ugh it looks like I have successfully found some of the pdfs which is annoying 


more_scrapping_data.write_csv('scrapping_linked_pages.csv')


