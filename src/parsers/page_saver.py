import urllib.request as urlreq
from bs4 import BeautifulSoup

#url = 'http://www.tennislive.net/atp/match/rafael-nadal-VS-david-ferrer/us-open-new-york-2018/'
#url='http://www.tennislive.net/atp/match/rafael-nadal-VS-dominic-thiem/us-open-new-york-2018/'
#url='http://www.tennislive.net/atp-men/usa-f25-laguna-niguel-2018/'
#url='http://www.tennislive.net/atp/match/kei-nishikori-VS-nikoloz-basilashvili/moselle-open-metz-2018/'
#url='http://www.tennislive.net/atp-men/spain-f30-melilla-2018/'
url='http://www.tennislive.net/atp/match/gael-monfils-VS-jo-wilfried-tsonga/european-open-antwerp-2018/'

output_name='scheduled_match_page.html'
print('Going to', url)
page = urlreq.urlopen(url)
print('Getting html')
soup = BeautifulSoup(page, 'html.parser')
print('Writing to file', )
with open(output_name, "w") as file:
    file.write(str(soup))
