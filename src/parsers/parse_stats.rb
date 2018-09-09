require_relative '../lib/stats_parcer'

include StatsParser

url = 'https://www.myscore.ru/match/n73qG54U/#match-statistics;0'
dir = '../tmp/'
data_file_name = 'test_output'
page_file_name = 'match_stats_page'
stats_data = []
max_attempts = 2
attempt_count = 0

begin
  attempt_count += 1
  # Launch browser
  browser = launch_browser('Firefox')
rescue Net::ReadTimeout => e
  puts "Error: #{e.message}"
  retry if attempt_count < max_attempts
else
  puts "Going to #{url}"
  browser.goto url

  puts 'Getting HTML...'
  page = Nokogiri::HTML.parse(browser.html)

  # Write HTML to file
  write_HTML(page, dir + page_file_name, 'w')

  match_stats = get_match_stats(page, browser)

  puts match_stats
  stats_data << match_stats

  # Writing stats to CSV
  write_CSV(match_stats, dir + data_file_name, 'w')
  browser.close
end
