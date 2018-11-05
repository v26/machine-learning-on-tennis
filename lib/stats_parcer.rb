require 'nokogiri'
require 'json' 
require 'watir'
require 'csv'

module StatsParser
  def launch_browser(browser)
    puts "Launching headless #{browser}..."
    params = {
      headless: true,
      timeout: 120
    }
    browser = browser.downcase.to_sym
    browser = Watir::Browser.new browser, params
  end

  def write_HTML(page, file_name, flag)
    puts "Writing HTML to file..."
    File.open(file_name + ".html", flag) do |f|
      f.write(page)
    end
  end

  def write_CSV(match, file_name, flag)
    puts "Writing to CSV..."
    if flag == 'w'
      CSV.open(file_name + '.csv', 'w') do |csv|
        csv << match.keys
      end
      CSV.open(file_name + '.csv', 'a') do |csv|
        csv << match.values
      end
    end

    if flag == 'a'
      CSV.open(file_name + '.csv', 'a') do |csv|
        csv << res.values
      end
    end
  end

  def get_match_stats(page, browser)
#    class="info-status mstat">Завершен</div>

    stats = {}

    title = get_title(browser)

    winner_team = get_winner_team(title)
    loser_team = get_loser_team(winner_team)

    stats[:winner_name] = get_name(title, winner_team)
    stats[:loser_name] = get_name(title, loser_team)

    stats[:tourney_date] = get_date(page)

    save_player_stats(page, winner_team, 'w_', stats)
    save_player_stats(page, loser_team, 'l_', stats)

    website = 'https://www.myscore.ru'
    winner_url = website + get_player_page(page, winner_team)
    loser_url = website + get_player_page(page, loser_team)

    save_player_info(browser, winner_url, 'w_', stats)
    save_player_info(browser, loser_url, 'l_', stats)

    stats
  end

  private

  def get_title(browser)
    str = browser.meta(css: 'meta[property="og:title"]').content
    puts str
    str
  end

  def get_winner_team(title)
    winner = ''
    home_score = title[/.* (.*):(.*)/, 1]
    away_score = title[/.* (.*):(.*)/, 2]
    winner = home_score > away_score ? 'home' : 'away'
  end

  def get_loser_team(winner_team)
    loser = winner_team == 'home' ? 'away' : 'home'
  end

  def get_name(title, team)
    name = ''
    if team == 'home'
      name = title[/(.*) - (.*) .*/, 1]
    else
      name = title[/(.*) - (.*) .*/, 2]
    end
    name
  end

  def get_date(page)
    page.css('div#utime').each do |date|
      date = date.text
      puts date
    end
  end

  def save_player_stats(page, team, prefix, stats)
    values = []
    value_titles = []

    page.css('div#tab-statistics-0-statistic').each do |stats_html|
      values = stats_html.css(".statText--#{team}Value")
      value_titles = stats_html.css('.statText--titleValue')
    end

    (0...values.size).each do |i|
      value_title = value_titles[i].text
      value = values[i].text

      case value_title
      when 'Подачи навылет'
        value_title = 'ace'
      when 'Двойные ошибки'
        value_title = 'df'
      when '% первой подачи'
        value_title = '1stin'
      when 'Очки выигр. на п.п.'
        value_title = '1stwon'
      when 'Очки выигр. на в.п.'
        value_title = '2ndwon'
      else
        return nil
      end
      
      stats[(prefix + value_title).to_sym] = value
    end
  end

  def get_player_page(page, team)
    html_line = page.css("div.tlogo-#{team}").css('a')
    doc = Nokogiri.parse html_line.to_s
    url = doc.xpath('//a[@onclick]').first.attributes['onclick'].content.match(/'([^']+)/)[1]
  end

  def save_player_info(browser, url, prefix, stats)
    browser.goto url
    page = Nokogiri::HTML.parse(browser.html)
    rating = page.css('span.participant-detail-rank').text
puts rating
  end
end
