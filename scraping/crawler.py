# TODO
#   - Catch errors
#   - Find interval for 429 error


import requests
from lxml import html
from bs4 import BeautifulSoup
import pandas as pd

class OKRCrawler:
    """
    """
    def __init__(self,
                 handles_df_path,
                 base_url = 'https://openknowledge.worldbank.org/handle/',
                 stats_request =  "https://openknowledge.worldbank.org//rest/statlets?dsotype=2&dsoid={dsoid}&ids%5B%5D=abstract-views&ids%5B%5D=abstract-views-past-year&ids%5B%5D=file-downloads&ids%5B%5D=file-downloads-past-year"):
        
        self.base_url = base_url
        self.stats_request = stats_request
        self.handles_df_path = handles_df_path
        
        # Load handles df
        self.df = pd.read_csv(self.handles_df_path)
        
    def get_static_html(self, handle, export_html = False):
        """
        Loads html for static page
        """
        
        self.url =  self.base_url + handle
        
        # Send request for static page
        print("Sending GET request for static page HTML...")
        
        self.page = requests.get(self.url)
        
        # Continue only if a 200 response
        try:
            self.page .raise_for_status()
        except requests.exceptions.HTTPError as e:
            # Whoops it wasn't a 200
            error = "Error: " + str(e)
            print(error)
        else:
            print(" Successfully loaded static page HTML...")
        finally:
            # Format html
            self.tree = html.fromstring(self.page.content)
            
            # Soupify
            self.soup = BeautifulSoup(self.page.content, 'html.parser')
            
            #save html for reference 
            if export_html:
                html_file_name = 'okr-{}'.format(handle.replace('/', '-')) + '.html'
                with open(html_file_name, "w", encoding='utf-8') as file:
                    file.write(str(self.soup))
        
    def get_stats_json(self, dsoid):
        """
        Uses dsoid from static html to send API request for download and view stats
        """
        print('Sending API request for stats JSON...')
        stats_request = self.stats_request.format(dsoid = dsoid)
        stats_response = requests.get(stats_request)
        print('Got respose with stats JSON...')
        return stats_response
        
        pass
    def process_json(self, json_source, list_index):
        """ 
        API response is a list of ordered JSONs, first contains information on 
        abstract views and third on file downloads
        
        This function process  the JSON to get matrices with stats """
        
        # Turn into dict and get the nth element
        json = json_source.json()[list_index]
        
        # Find matrix element
        matrix = json['dataset']['matrix']
        
        # Sum all elements in matrix
        return sum(matrix[0])
        
    def crawl(self, handle_list):
        """
        Loops over handles df and sends requests for each entry
        """
        self.get_static_html(handle_list[0])
        
        # Get static info --------------------------------
        
        # citation
        citation =  self.soup.find_all("div", {"class": "citation"})[0].text
        # remove special characters
        citation = citation.replace('\n', "").replace('“', '')
        
        # Get dsoid param from static html -> class="embed-cua-widget" data-dso-id = (...)
        embed_html_elem = self.soup.find_all("div", {"class": "embed-cua-widget"})
        dsoid = embed_html_elem[0]["data-dso-id"]
        
        # Get JSON with stats info -----------------------
        self.json = self.get_stats_json(dsoid)
        
        # Process JSON -----------------------------------
        
        # First item on json has info on abstract views
        abstract_views = self.process_json(self.json, 0)
        
        # Thir item on json has info on n of downloads
        downloads = self.process_json(self.json, 2)
        
        
        return citation, dsoid, abstract_views, downloads
    
    def create_df(self):
        """
        Creates all restults pandas.DataFrame for expoerting
        """
        pass

# if __name__ == "__main__":
#     print("Foo!")

craw = OKRCrawler('C:/Users/wb519128/Downloads/OKR-Data-2014-21.csv')
# craw.df.Handle[0]

# craw.crawl(craw.df.Handle)
# craw.get_static_html(craw.df.Handle[0], export_html= True)

# embed_html_elem = craw.soup.find_all("div", {"class": "embed-cua-widget"})
# dsoid = embed_html_elem[0]["data-dso-id"]

# craw.crawl(craw.df.Handle)
# craw.page