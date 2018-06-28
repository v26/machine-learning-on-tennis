require 'nokogiri'
require 'json' 

require 'watir'
stats = []
puts "1"
url = 'https://www.myscore.ru/match/n73qG54U/#match-statistics;0'
browser = Watir::Browser.new :firefox, { headless: true, timeout: 120}
puts "2"
browser.goto url
puts "3"
doc = Nokogiri::HTML.parse(browser.html)

doc.css('div#tab-statistics-0-statistic').each do |stats_html|
  @home_values = stats_html.css('.statText--homeValue')
  @value_titles = stats_html.css('.statText--titleValue')
  @away_values = stats_html.css('.statText--awayValue')
end

(0...@home_values.size).each do |i|
  stats.push(
    value_title: @value_titles[i].text,
    home_value: @home_values[i].text,
    away_value: @away_values[i].text
  )
end

browser.close
=begin
  showing_id = showing['id'].split('_').last.to_i
  tags = showing.css('.tags a').map { |tag| tag.text.strip }
  title_el = showing.at_css('h1 a')
  title_el.children.each { |c| c.remove if c.name == 'span' }
  title = title_el.text.strip
  dates = showing.at_css('.start_and_pricing').inner_html.strip
  dates = dates.split('<br>').map(&:strip).map { |d| DateTime.parse(d) }
  description = showing.at_css('.copy').text.gsub('[more...]', '').strip
  showings.push(
    id: showing_id,
    title: title,
    tags: tags,
    dates: dates,
    description: description
  )
=end

puts JSON.pretty_generate(stats)
IO.write('stats.json', JSON.pretty_generate(stats))
