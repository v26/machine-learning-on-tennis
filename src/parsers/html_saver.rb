require_relative '../lib/stats_parcer'

include StatsParser

#url = 'https://www.myscore.ru/player/raonic-milos/8dRfslyR/'
#url = 'https://www.myscore.ru/match/ru884nU2/#match-statistics;0'
#url = 'https://tennisinsight.com/match/212054116/2018-us-open-atp-slam/r128/kevin-anderson-vs-ryan-harrison/'
url = 'http://www.tennislive.net/atp/match/rafael-nadal-VS-david-ferrer/us-open-new-york-2018/'

dir = '../tmp/'
page_file_name = 'tennislive_match_stats'

# Launch browser
browser = launch_browser('Firefox')

puts "Going to #{url}"
browser.goto url

puts 'Getting HTML...'
page = Nokogiri::HTML.parse(browser.html)

# Write HTML to file
write_HTML(page, dir + page_file_name, 'w')

browser.close
