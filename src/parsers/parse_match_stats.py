import urllib.request as urlreq
from bs4 import BeautifulSoup

#url = 'http://www.tennislive.net/atp/match/rafael-nadal-VS-david-ferrer/us-open-new-york-2018/'
url='http://www.tennislive.net/atp/match/rafael-nadal-VS-dominic-thiem/us-open-new-york-2018/'

print('Going to', url)
page = urlreq.urlopen(url)
print('Getting html')
soup = BeautifulSoup(page, 'html.parser')

print('getting stats table')
data = []
#table = soup.find('table', attrs={'class':'table_pmatches_s'})
rows = soup.find_all('td', attrs={'class':'w50'})
print(len(rows))
for row in rows:
#    cols = row.find_all('td')
#    cols = [ele.text.strip() for ele in cols]
#    data.append([ele for ele in cols]) # Get rid of empty values
#    data.append([ele for ele in cols if ele]) # Get rid of empty values

    ref = row.find('a')
    data.append(a.href)

print(data)
#print('Writing to file', )
#with open(output_name, "w") as file:
#    file.write(str(soup))
#match details: td class='w50' a href

#date: <tr class="pair">  <td align="center" class="w50">02.09.
