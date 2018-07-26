require 'smarter_csv'
require 'csv'

module Data_Restruct
  def sort_matches(path, file)
    dir_sep = "/"

    # read entire csv
    matches = SmarterCSV.process("#{path}#{dir_sep}#{file}")
    sort_matches_hlpr!(matches)
    matches
  end

  def print_m(matches)
    id = :tourney_id
    date = :tourney_date

    matches.each { |match| puts "#{match[id]}  #{match[date]}  #{match[:round]}" }
  end

  def unite_csv_files(res_file_name, path, *files)
    headers = CSV.open(path + "/" + files[0]).shift.join(',')
    File.open(res_file_name, "w") { |csv| csv << headers}

    files.each do |file|
      sorted_matches = sort_matches(path, file)
      
      CSV.open(res_file_name, "a") do |csv|
        sorted_matches.each { |match| csv << match.values }
      end
    end
  end

  def get_filenames(file_template, first_year, last_year)
    files = []
    last_year.downto(first_year).each do |year|
      files << "#{file_template}#{year}.csv"
    end
    files
  end

  def check_rounds(matches)
    puts
    uniq_rounds = matches.uniq { |match| match[:round] }
    print_m(uniq_rounds)
  end

  private

  def sort_matches_hlpr!(matches)
    # set of tourney rounds from final to first ones
    rounds = ["F", "SF", "QF", "R16", "R32", "R64", "R128", "RR", "BR"]

    # sort data by tourney date, id, round
    # from latest to oldest one
    matches.sort_by! do |match|
      [-(match[:tourney_date].to_i), match[:tourney_id], rounds.index(match[:round].to_s)]
    end
  end
end

include Data_Restruct

path = "../data/match_data_downloaded"
file_template = "atp_matches_"

files = get_filenames(file_template, 1993, 2018)
unite_csv_files("atp_matches_1993-2018.csv", path, *files)
