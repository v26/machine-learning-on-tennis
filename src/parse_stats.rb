#require 'nokogiri'
#require 'json' 
#require 'watir'
#require 'csv'
require_relative '../lib/stats_parcer'

include StatsParser

url = 'https://www.myscore.ru/match/n73qG54U/#match-statistics;0'
data_file_name = 'test_output_2'
page_file_name = 'match_stats_page'
stats_data = []

# Launch browser
browser = launch_browser('Firefox')

puts "Going to #{url}"
browser.goto url

puts 'Getting HTML...'
page = Nokogiri::HTML.parse(browser.html)

# Write HTML to file
write_HTML(page, page_file_name, 'w')

match_stats = get_match_stats(page, browser)
browser.close

puts match_stats
stats_data << match_stats

# Writing stats to CSV
write_CSV(match_stats, data_file_name, 'w')
