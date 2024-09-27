

<p align="center">
<a href="https://joshuafayallen.github.io/executivestatements/">
<img src="hex-logo.png" height = "350" class = "center"> </a>
</p>

`ecdata` is a minimal package for downloading *Executive Communications
Dataset*. It includes subsets of all the country data, the full dataset,
data dictionaries, and a sample script to help users expand the dataset.
For our full replication archive, see the relevant subdirectories in
[our
GitHub](https://github.com/joshuafayallen/executivestatements/tree/main/raw-data).
For a Python implementation see
[execcommunications-py](https://github.com/joshuafayallen/executivecommunications-py).

## Installation

To install `ecdata` run.

``` r
pak::pkg_install('joshuafayallen/executivestatements')
```

## Usage

To see a list of countries in our dataset and the associated file name
in the GitHub release, you can run:

``` r
library(ecdata)

ecd_country_dictionary |>
    head()
```

      name_in_dataset  file_name
    1       Argentina  argentina
    2       Australia  australia
    3         Austria    austria
    4      Azerbaijan azerbaijan
    5         Bolivia    bolivia
    6          Brazil     brazil

To load a specific country’s or countries’ data, you can use the
`load_ecd` function like this.

``` r
load_ecd(country = 'United States of America') |>
    head()
```

    ! Warning one of United States of America is not in our dataset. Call country_names() for a list of valid country names

                       country
    1 United States of America
    2 United States of America
    3 United States of America
    4 United States of America
    5 United States of America
    6 United States of America
                                                                                              url
    1 https://www.presidency.ucsb.edu/documents/remarks-luncheon-for-the-us-olympic-medal-winners
    2 https://www.presidency.ucsb.edu/documents/remarks-luncheon-for-the-us-olympic-medal-winners
    3 https://www.presidency.ucsb.edu/documents/remarks-luncheon-for-the-us-olympic-medal-winners
    4 https://www.presidency.ucsb.edu/documents/remarks-luncheon-for-the-us-olympic-medal-winners
    5 https://www.presidency.ucsb.edu/documents/remarks-luncheon-for-the-us-olympic-medal-winners
    6 https://www.presidency.ucsb.edu/documents/remarks-luncheon-for-the-us-olympic-medal-winners
                                                                                                                                                                                                                                                                                                                                                                                            text
    1                                                                                                                                                                                                                                                                                                                                                                               About Search
    2                                                                                                                                                                                                                    I hope you are understanding people. I appreciate your patience and ask for your forgiveness. I would like to introduce to you a few of our distinguished guests today.
    3                                                             There is a saying among some people to never spend your time on a colonel if there is a general in the vicinity. And my beloved friend and distinguished Vice President-elect, Senator Hubert Humphrey, I observe has a rule, "Never sit by a man, if there is a lady in the room." Stand up, Hubert. I want to introduce you.
    4                                                                                                                                                                                                                                                                                    And that may account for the unusually high percentage of female voters that were recorded in November.
    5 I would also like to present Mr. Kenneth L. Wilson, the president of the United States Olympic Committee which did such a superb job of administering affairs for our team and three other high officials of our Government who made their own sparkling place in the record book of sports. If you will, hold your applause until I introduce the other three distinguished guests today.
    6                                                                                                                                                             My good friend and very great public servant, Mr. Justice Byron R. White, presently a member of the Supreme Court, the fabled "Whizzer" White, everybody's All-American when he played football at the University of Colorado.
            date title         executive   type language file isonumber gwc
    1 1964-12-01  <NA> Lyndon B. Johnson Speech  English <NA>       840 USA
    2 1964-12-01  <NA> Lyndon B. Johnson Speech  English <NA>       840 USA
    3 1964-12-01  <NA> Lyndon B. Johnson Speech  English <NA>       840 USA
    4 1964-12-01  <NA> Lyndon B. Johnson Speech  English <NA>       840 USA
    5 1964-12-01  <NA> Lyndon B. Johnson Speech  English <NA>       840 USA
    6 1964-12-01  <NA> Lyndon B. Johnson Speech  English <NA>       840 USA
      cowcodes polity_v polity_iv vdem year_of_statement
    1      USA      USA       USA   20              1964
    2      USA      USA       USA   20              1964
    3      USA      USA       USA   20              1964
    4      USA      USA       USA   20              1964
    5      USA      USA       USA   20              1964
    6      USA      USA       USA   20              1964

``` r
load_ecd(country = c('United States of America', 'Turkey', 'Republic of South Korea')) |>
    tail()
```

    ! Warning one of United States of America, Turkey, and Republic of South Korea is not in our dataset. Call country_names() for a list of valid country names

    ✔ Successfully downloaded data for United States of America, Turkey, and Republic of South Korea

                            country
    330251 United States of America
    330252 United States of America
    330253 United States of America
    330254 United States of America
    330255 United States of America
    330256 United States of America
                                                                                                         url
    330251 https://www.presidency.ucsb.edu/documents/proclamation-10627-national-voter-registration-day-2023
    330252 https://www.presidency.ucsb.edu/documents/proclamation-10627-national-voter-registration-day-2023
    330253 https://www.presidency.ucsb.edu/documents/proclamation-10627-national-voter-registration-day-2023
    330254 https://www.presidency.ucsb.edu/documents/proclamation-10627-national-voter-registration-day-2023
    330255 https://www.presidency.ucsb.edu/documents/proclamation-10627-national-voter-registration-day-2023
    330256 https://www.presidency.ucsb.edu/documents/proclamation-10627-national-voter-registration-day-2023
                                                                                                                                                                                                          text
    330251                                                                                                                                                                                JOSEPH R. BIDEN, JR.
    330252                                                                                                                      NOTE: This proclamation was published in the Federal Register on September 22.
    330253 Joseph R. Biden, Proclamation 10627—National Voter Registration Day, 2023 Online by Gerhard Peters and John T. Woolley, The American Presidency Project https://www.presidency.ucsb.edu/node/365165
    330254                                                                                                                               The American Presidency ProjectJohn Woolley and Gerhard PetersContact
    330255                                                                                                                                                                                    Twitter Facebook
    330256                                                                                                               Copyright © The American Presidency ProjectTerms of Service | Privacy | Accessibility
                 date title       executive                     type language file
    330251 2023-09-18  <NA> Joseph R. Biden Presidential Proclamtion  English <NA>
    330252 2023-09-18  <NA> Joseph R. Biden Presidential Proclamtion  English <NA>
    330253 2023-09-18  <NA> Joseph R. Biden Presidential Proclamtion  English <NA>
    330254 2023-09-18  <NA> Joseph R. Biden Presidential Proclamtion  English <NA>
    330255 2023-09-18  <NA> Joseph R. Biden Presidential Proclamtion  English <NA>
    330256 2023-09-18  <NA> Joseph R. Biden Presidential Proclamtion  English <NA>
           isonumber gwc cowcodes polity_v polity_iv vdem year_of_statement
    330251       840 USA      USA      USA       USA   20              2023
    330252       840 USA      USA      USA       USA   20              2023
    330253       840 USA      USA      USA       USA   20              2023
    330254       840 USA      USA      USA       USA   20              2023
    330255       840 USA      USA      USA       USA   20              2023
    330256       840 USA      USA      USA       USA   20              2023

We also provide a set of an example scrappers in part to quickly
summarize our replication files and for other researchers to either
collect more recent data or expand the cases in our dataset. To call
these scrappers simply run:

``` r
# static website scrapper
example_scrapper(scrapper_type = 'static')

# dynamic website scrapper 

example_scrapper(scrapper_type = 'dynamic')
```
