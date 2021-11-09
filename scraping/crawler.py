
import requests
from lxml import html
from bs4 import BeautifulSoup

class OKRCrawler:
    """
    """
    def __init__(self,
                 base_url,
                 handles_df):
        self.base_url = base_url
        self.handles_df = handles_df
    
    def get_static_html(self):
        pass
    def get_stats_json(self):
        pass
    def process_json(self):
        pass
    def crawl(self):
        pass
    def create_df(self):
        pass

if __name__ == "__main__":
    print("Foo!")