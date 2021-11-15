
# TO DO
#   - Turn resulting data into DF
#   - Test additional handles for stability
#   - Scale into something that can run over handles dataset
#   - Set up raspberry pi to do it.


import requests
from lxml import html
from bs4 import BeautifulSoup


print(requests.get(url = 'https://google.com').text)

handle = "10986/6384"
# handle = "10986/35594"
# page = requests.get('https://openknowledge.worldbank.org/handle/10986/35594')
url = 'https://openknowledge.worldbank.org/handle/{}'.format(handle)

# Send request for static page
page = requests.get(url)

# Format html
tree = html.fromstring(page.content)

#save html for reference 
with open("temp2.html", "w", encoding='utf-8') as file:
    file.write(str(soup))

#---------------------------------------------------------------------
# Process HTML for interest params

# Soupify
soup = BeautifulSoup(page.content, 'html.parser')

# citation
citation =  soup.find_all("div", {"class": "citation"})[0].text

# remove special characters
citation = citation.replace('\n', "").replace('“', '')


# Get dsoid param from static html -> class="embed-cua-widget" data-dso-id = (...)
embed_html_elem = soup.find_all("div", {"class": "embed-cua-widget"})
dsoid = embed_html_elem[0]["data-dso-id"]

#---------------------------------------------------------------------
# Get stats with HTTP request

# dsoid = 6711

stats_request =  "https://openknowledge.worldbank.org//rest/statlets?dsotype=2&dsoid={dsoid}&ids%5B%5D=abstract-views&ids%5B%5D=abstract-views-past-year&ids%5B%5D=file-downloads&ids%5B%5D=file-downloads-past-year"

stats_request = stats_request.format(dsoid = dsoid)

stats_response = requests.get(stats_request)

#---------------------------------------------------------------------
# Process stats JSON


"""
Result is a list of ordered JSONs, first contains information on abstract views and third on file downloads

"""

def process_json(list_index, json_source = stats_response):
    # Turn into dict and get the nth element
    json = json_source.json()[list_index]
    
    # Find matrix element
    matrix = json['dataset']['matrix']
    
    # Sum all elements in matrix
    return sum(matrix[0])

abstract_views = process_json(0)
downloads = process_json(2)

