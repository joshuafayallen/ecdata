import random 
import time 
from selenium.webdriver.common.by import  By
from seleniumbase import Driver
import polars as pl
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException 



scrape_links = pl.read_csv("links_scrape_israel.csv")

landing_page_links = scrape_links["links"]


scrape_links.head()

def get_links(driver):
    list_item_count = len(driver.find_elements(By.XPATH, '//*[@id="content"]/div[2]/div[2]/ul/li'))
    all_refs = []

    for i in range(1, list_item_count + 1):
        xpath_expression = f'//*[@id="content"]/div[2]/div[2]/ul/li[{i}]/h2/a'
        get_refs = driver.find_elements(By.XPATH, xpath_expression)
        hrefs = [get_ref.get_attribute("href") for get_ref in get_refs]
        all_refs.extend(hrefs)

    return all_refs

refs_all = []

skipped_links = []

for i in landing_page_links:
    try:
        driver = Driver(uc=True, agent=user_agent)
        print("scraping ", i)
        driver.get(i)
        refs_page = get_links(driver)
        refs_all.extend(refs_page)
        time.sleep(20)
    except InvalidSessionIdException:
        print("Invalid session ID. Skipping this link.")
        skipped_links.extend(i)


links_scrape_frame = pl.DataFrame(refs_all, schema=["links"])

links_scrape_frame.write_csv("links_from_landing_to_scrape.csv")
