import urllib.request
from bs4 import BeautifulSoup

root = "http://lkml.iu.edu/hypermail/linux/kernel/"


with urllib.request.urlopen(root) as html:
    soup = BeautifulSoup(html, "lxml-xml")
    pages = [l["href"] for l in soup.find_all("a", href=True)]
    print(sorted(pages))
