import urllib.request as urlreq
from bs4 import BeautifulSoup, Comment
from datetime import datetime
import pprint
import os
import csv
import time

pp = pprint.PrettyPrinter(indent=4)

#print('Writing to file', )
#with open(output_name, "w") as file:
#    file.write(str(soup))
def get_scheduled_matches_list(url, period, max_num):
    scheduled_matches = get_scheduled_matches_data(url)

    parsed_data_dir = '../data/recent_match_data_parsed/'
    tourney_dir = _get_tourney_dir_from_url(url)
    full_tourney_dir = parsed_data_dir + tourney_dir
    os.makedirs(full_tourney_dir)

    dir_sep = '/'
#    prev_m_str = '_prev_matches'

    for scheduled_match in scheduled_matches:
        p1_name, p2_name = get_players_names(scheduled_match)
        p1_matches, p2_matches = get_prev_matches(scheduled_match)
        scheduled_match_date = _get_scheduled_match_date(scheduled_match)

        scheduled_match_data = {'match_date':scheduled_match_date, 'p1_name':p1_name, 'p2_name':p2_name}
        data_list = []
        data_list.append(scheduled_match_data)
        _write_list_of_dict_to_csv(full_tourney_dir, 'scheduled_matches.csv', 'a', data_list)
        _write_list_of_dict_to_csv(full_tourney_dir, 'prev_matches.csv', 'a', p1_matches)
        _write_list_of_dict_to_csv(full_tourney_dir, 'prev_matches.csv', 'a', p2_matches)
#        match_dir = (p1_name + ' vs ' + p2_name).replace(' ', '_')
#        full_match_dir = full_tourney_dir + dir_sep + match_dir.replace(' ', '_')
#        os.makedirs(full_match_dir)

#        p1_dir = (p1_name + prev_m_str).replace(' ', '_')
#        p2_dir = (p2_name + prev_m_str).replace(' ', '_')
#        full_p1_dir = full_match_dir + dir_sep + p1_dir
#        full_p2_dir = full_match_dir + dir_sep + p2_dir
#        os.makedirs(full_p1_dir)
#        os.makedirs(full_p2_dir)

#        _write_to_csv(full_p1_dir, p1_name + prev_m_str, 'a', p1_matches)
#        _write_to_csv(full_p2_dir, p2_name + prev_m_str, 'a', p2_matches)



def _get_tourney_dir_from_url(url):
    soup = _get_soup_from_url(url)
    tourney_name_str_elem = soup.find('title').text
#    str_end = tourney_name.find('/')
    tourney_name = _get_str_part(tourney_name_str_elem, '', '/')

    today = datetime.now()
    today = _truncate_minutes_from_date(today)

    tourney_data_dir = str(today) + '_' + tourney_name
    tourney_data_dir = tourney_data_dir.replace(' ', '_')
    return tourney_data_dir

def _truncate_minutes_from_date(date):
    return str(date.replace(minute=0, second=0, microsecond=0))[:-3]

def _get_scheduled_match_date(url):
    soup = _get_soup_from_url(url)
    table_elem = soup.find('table', attrs={'class':'table_pmatches'})
    date_elem = table_elem.find_next('td', attrs={'class':'w50'})
    date = date_elem.text
    return date

#def _write_headers_to_file(file_name, headers):
#    print('Writing to file', file_name)
#    with open(file_name, "w") as file:
#        file.write(headers)

def _write_list_of_dict_to_csv(dir, filename, mode, list_of_dict):
    print('Writing dict to file', filename)
    with open(dir + '/' + filename, mode=mode) as csv_file:
        fieldnames = list_of_dict[0].keys()
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        if mode == 'w' or (mode == 'a' and os.stat(dir + '/' + filename).st_size == 0):
            writer.writeheader()
        for dict in list_of_dict:
            writer.writerow(dict)

def _write_match_stats(file_name, stats):
    pass

def get_scheduled_matches_data(url):
    soup = _get_soup_from_file('scheduled_matches.html')
#    soup = _get_soup_from_file('tourney_page.html')
#    soup = _get_soup_from_url(url)

    scheduled_matches = soup.find_all('a', attrs={'title':'H2H stats - match details'})
    scheduled_matches = _turn_to_url(scheduled_matches)
#    pp.pprint(scheduled_matches)
    return scheduled_matches

def _get_soup_from_file(file):
    with open(file) as fp:
        soup = BeautifulSoup(fp, 'html.parser')
    return soup

def _get_soup_from_url(url):
    time.sleep(2)
    print('Going to', url)
    page = urlreq.urlopen(url)
    print('Getting html...')
    soup = BeautifulSoup(page, 'html.parser')
    return soup

def _turn_to_url(elem_list):
    url_list = [elem.get('href') for elem in elem_list]
    return url_list

def get_prev_matches(url):
    page = _get_soup_from_url(url)

    curr_date_elem = page.find('td', attrs={'class':'w50'})
#    print('Current date:', curr_date_elem.text)

    print('Getting matches table...')
    p1_name, p2_name = get_players_names(url)

    table_tag = page.find('table', attrs={'class':'table_pmatches_s'})
    p1_matches = _get_matches_after(p1_name, table_tag, curr_date_elem)

    table_tag = table_tag.find_next('table', attrs={'class':'table_pmatches_s'})
    p2_matches = _get_matches_after(p2_name, table_tag, curr_date_elem)

    _remove_intersec(p1_matches, p2_matches)
#    _filter_by(period, max_num, pl1_matches, curr_date_elem.text)
#    _filter_by(period, max_num, pl2_matches, curr_date_elem.text)

    return p1_matches, p2_matches

def _get_matches_after(player_name, tag, curr_date_elem):
    elem = tag.find_next('td', attrs={'class':'w50'})

    player_matches = []
    while True:
        if elem is None:
            break

        match = {}
        match['date'] = elem.text[:8]

        match['player_name'] = player_name
        elem = elem.find_next('td', attrs={'class':'w50'})
        url = elem.find('a').get('href')
        match['match_url'] = url

        player_matches.append(match)

        elem = elem.find_next('td', attrs={'class':'w50'})

    return player_matches

def _remove_intersec(list1, list2):
    counter = 0
    for item in list2:
        item_indices = [i for i, e in enumerate(list1) if e['match_url'] == item['match_url']]
        del(list1[item_indices[-1]])

def _filter_by(period, max_num, data, curr_date_str):
    for match in list(data):
        if _days_diff(match['date'], curr_date_str) > period:
            del data[data.index(match)]

    if len(data) > max_num:
        data = data[:10]

def _days_diff(date1_elem, date2_elem):
    date1 = datetime.strptime(date1_elem, '%d.%m.%y')
    date2 = datetime.strptime(date2_elem, '%d.%m.%y')
    return (date2 - date1).days

def get_players_names(url):
    soup = _get_soup_from_url(url)
#<div class="player_msmall">
#<h3><span>Nikoloz Basilashvili - last matches</span></h3>
    div = soup.find('div', attrs={'class':'player_msmall'})
    player1_str_elem = div.find_next('span').text
    player1_name = _get_str_part(player1_str_elem, '', ' - last matches')

    div = div.find_next('div', attrs={'class':'player_msmall'})
    player2_str_elem = div.find_next('span').text
    player2_name = _get_str_part(player2_str_elem, '', ' - last matches')

    return player1_name, player2_name

def get_match_stats(url):
    soup = _get_soup_from_file('match_page.html')
    match_stats = {}

    match_stats['tourney_date'] = _get_date(soup)
    match_stats['winner_name'], match_stats['loser_name'] \
    = _get_names(soup)

    match_stats['winner_age'], match_stats['winner_ht'], \
    match_stats['winner_rank'], match_stats['winner_rank_points'] \
    = _get_player_info(soup, 'winner')

    match_stats['loser_age'], match_stats['loser_ht'], \
    match_stats['loser_rank'], match_stats['loser_rank_points'] \
    = _get_player_info(soup, 'loser')

    match_stats['w_svpt'], match_stats['l_svpt'], \
    match_stats['w_1stIn'], match_stats['l_1stIn'], \
    match_stats['w_1stWon'], match_stats['l_1stWon'], \
    match_stats['w_2ndIn'], match_stats['l_2ndIn'], \
    match_stats['w_2ndWon'], match_stats['l_2ndWon'], \
    match_stats['w_bpFaced'], match_stats['l_bpFaced'], \
    match_stats['w_bpSaved'], match_stats['l_bpSaved'] \
    = _get_match_stats_helper(soup)

    return match_stats


# tourney_id,tourney_name,surface,draw_size,tourney_level,
# tourney_date,match_num,winner_id,winner_seed,winner_entry,
# winner_name,winner_hand,winner_ht,winner_ioc,winner_age,
# winner_rank,winner_rank_points,loser_id,loser_seed,
# loser_entry,loser_name,loser_hand,loser_ht,loser_ioc,
# loser_age,loser_rank,loser_rank_points,score,best_of,
# round,minutes,w_ace,w_df,w_svpt,w_1stIn,w_1stWon,w_2ndWon,
# w_SvGms,w_bpSaved,w_bpFaced,l_ace,l_df,l_svpt,l_1stIn,
# l_1stWon,l_2ndWon,l_SvGms,l_bpSaved,l_bpFaced

def _get_date(soup):
    table = soup.find('table', attrs={'class':'table_pmatches'})
    date = table.find('td', attrs={'class':'w50'}).text[:8]
    return date

#def _get_round(soup):
#    rounds = ("F", "SF", "QF", "R16", "R32", "R64", "R128")

def _get_names(soup):
    table = soup.find('table', attrs={'class':'table_pmatches'})
    winner_name_elem = table.find('a')
    winner_name = winner_name_elem.text
    loser_name = winner_name_elem.find_next('a').text
    return winner_name, loser_name

def _get_player_info(soup, player):
    if player == 'winner':
        div = soup.find('div', attrs={'class':'player_comp_info_left'})
    else:
        div = soup.find('div', attrs={'class':'player_comp_info_right'})

    elem = div.find('br')

    next_str = elem.next_sibling
    age = '' if  next_str.strip() == '' else next_str[-8:-6]

    elem = elem.find_next('br')
    next_str = elem.next_sibling
    height = '' if next_str.strip() == '' else next_str.strip(' ').strip('cm')

    elem = elem.find_next('a')
    rank = '' if elem.text.strip() == '' else elem.text

    elem = elem.find_next('br')
    next_str = elem.next_sibling
    rank_points = next_str.strip()

    return age, height, rank, rank_points

def _get_match_stats_helper(soup):
    w_svpt = l_svpt = w_1stIn = l_1stIn \
    =  w_1stWon = l_1stWon =  w_2ndWon = l_2ndWon \
    = w_SvGms = l_SvGms = w_bpSaved = l_bpSaved \
    = w_bpFaced = l_bpFaced = ''

    table = soup.find('table', attrs={'class':'table_stats_match'})
    rows = table.find_all('tr')
    for row in rows:
        cols = row.find_all('td')
        if cols[0].text == '1st SERVE %':
            w_svpt, l_svpt = _get_points(cols, '/', ' ')
        elif cols[0].text == '1st SERVE POINTS WON':
            w_1stIn, l_1stIn = _get_points(cols, '/', ' ')
            w_1stWon, l_1stWon = _get_points(cols, '', '/')
        elif cols[0].text == '2nd SERVE POINTS WON':
            w_2ndIn, l_2ndIn = _get_points(cols, '/', ' ')
            w_2ndWon, l_2ndWon = _get_points(cols, '', '/')
        elif cols[0].text == 'BREAK POINTS WON':
            w_bpFaced, l_bpFaced = _get_points(cols, '/', ' ')
            w_bpSaved, l_bpSaved = _get_points(cols, '', '/')

    return w_svpt, l_svpt, \
           w_1stIn, l_1stIn, \
           w_1stWon, l_1stWon, \
           w_2ndIn, l_2ndIn, \
           w_2ndWon, l_2ndWon, \
           w_bpFaced, l_bpFaced, \
           w_bpSaved, l_bpSaved

def _get_points(cols, start_sym, end_sym):
    w_str = cols[1].text
    w_pts = _get_str_part(w_str, start_sym, end_sym)
    l_str = cols[2].text
    l_pts = _get_str_part(l_str, start_sym, end_sym)

    return w_pts, l_pts

def _get_str_part(str, start_sym, end_sym):
    if start_sym == '':
        start = 0
    else:
        start = str.find(start_sym) + 1

    end = str.find(end_sym, start)
    res = str[start:end]

    return res

#url='http://www.tennislive.net/atp/match/rafael-nadal-VS-dominic-thiem/us-open-new-york-2018/'
period = 14 #days
max_num = 10 #matches

#get_scheduled_matches(url)

#pl1_matches, pl2_matches = get_matches(url, period, max_num)

#print('List1 size:', len(pl1_matches))
#pp.pprint(pl1_matches)
#print('List2 size:', len(pl2_matches))
#pp.pprint(pl2_matches)

# a title 'H2H stats - match details'
#match_url='http://www.tennislive.net/atp/match/kei-nishikori-VS-nikoloz-basilashvili/moselle-open-metz-2018/'
#print(get_match_stats(match_url))

url = 'http://www.tennislive.net/atp-men/stockton-challenger-2018/'
get_scheduled_matches_list(url, period, max_num)
