require 'business_calendar'
require 'colored_string'
require 'date'
require 'date_calculations'
require 'optparse'
require 'exceptions'

ROOT_DIR = File.expand_path("#{__dir__}/../..")
DATA_DIR = "#{ROOT_DIR}/data"
SCRIPTS_DIR = "#{ROOT_DIR}/src/scripts"

WDAY_TO_NAME_MAP = {
    0 => 'Su',
    1 => 'Mo',
    2 => 'Tu',
    3 => 'We',
    4 => 'Th',
    5 => 'Fr',
    6 => 'Sa',
}

def main
    case ARGV[0]
        when nil
            print_calendar_table
        when 'help', '-h', '--help'
            ARGV.shift
            print_help
        when 'updatedb'
            ARGV.shift
            update_holidays_database
        when 'list'
            ARGV.shift
            print_calendar_list
        when 'table'
            ARGV.shift
            print_calendar_table
        when 'remaining-days'
            ARGV.shift
            print_remaining_days
        when /^-/
            print_calendar_table
        else
            print_help
    end
rescue BizCalError => exception
    $stderr.puts "[ERROR] #{exception}"
    exit 1
end

def get_options(mode, today = Date.today)
    if ! %i(list table remaining_days).include?(mode)
        raise ArgumentError, "Invalid mode: [#{mode}]"
    end

    options = {
        :today     => today,
        :from_date => nil,
        :to_date   => nil,
        :columns   => 3,
    }

    OptionParser.new("bizcal #{mode} [OPTION...]").tap do |parser|
        if %i(list table).include?(mode)
            parser.on('-1', '--one', '今月のカレンダーを表示します.') {
                options[:from_date] = today.beginning_of_month
                options[:to_date]   = today.end_of_month
            }
            parser.on('-3', '--three', '今月を中心に 3 ヶ月分のカレンダーを表示します.') {
                options[:from_date] = today.next_month(-1).beginning_of_month
                options[:to_date]   = today.next_month(1).end_of_month
            }
            parser.on('-Y', '--twelve', '今月を起点に 12 ヶ月分のカレンダーを表示します.') {
                options[:from_date] = today.beginning_of_month
                options[:to_date]   = today.next_month(11).end_of_month
            }
            parser.on('-y', '--year', '今年 1 年分のカレンダーを表示します.') {
                options[:from_date] = today.beginning_of_year
                options[:to_date]   = today.end_of_year
            }
            parser.on('-n N', '--months=N', Integer, '今月を起点に N ヶ月分のカレンダーを表示します.') {|n|
                options[:from_date] = today.beginning_of_month
                options[:to_date]   = today.next_month(n - 1).end_of_month
            }
        end

        if %i(table).include?(mode)
            parser.on('-c N', '--columns=N', Integer, 'N ヶ月分のカレンダーを横に表示します.') {|n|
                options[:columns]   = n
            }
        end

        if %i(list remaining_days).include?(mode)
            parser.on('--from=DATE', String, '開始日を YYYY-MM-DD 形式で指定します.') {|date|
                options[:from_date] = parse_date(date)
            }
            parser.on('--to=DATE', String, '終了日を YYYY-MM-DD 形式で指定します.') {|date|
                options[:to_date] = parse_date(date)
            }
        end

        parser.parse!(ARGV)
    end

    options
rescue OptionParser::InvalidOption => exception
    raise ParseOptionFailed, exception
end

def parse_date(string)
    Date.strptime(string, '%Y-%m-%d')
rescue Date::Error
    raise ParseDateFailed, string
end

def print_help
    puts <<~'EOS'
        NAME
            bizcal - business calendar

        SYNOPSIS
            bizcal [SUBCOMMAND] [OPTION...]

        DESCRIPTION
            営業日/非営業日を考慮したカレンダーを表示します.
            また, 特定日までの残り営業日を表示することもできます.

        SUBCOMMAND
            help
                ヘルプメッセージを表示します.

            updatedb
                祝日データベースを更新します.

            list
                カレンダーをリスト表示します.

            table
                カレンダーをテーブル表示します.

            remaining-days
                今日を起点として週末, 月末, 四半期末, 年末までの残り営業日を表示します.
                --from=DATE で起点となる日を変更できます.
                --to=DATE で終点となる日を指定すると, その日までの残り営業日を表示します.

        OPTIONS
            -1, --one
                今月のカレンダーを表示します.
                サブコマンド list, table で有効なオプションです.

            -3, --three
                今月を中心に 3 ヶ月分のカレンダーを表示します.
                サブコマンド list, table で有効なオプションです.

            -Y, --twelve
                今月を起点に 12 ヶ月分のカレンダーを表示します.
                サブコマンド list, table で有効なオプションです.

            -y, --year
                今年 1 年分のカレンダーを表示します.
                サブコマンド list, table で有効なオプションです.

            -n N, --months=N
                今月を起点に N ヶ月分のカレンダーを表示します.
                サブコマンド list, table で有効なオプションです.

            -c N, --columns=N
                N ヶ月分のカレンダーを横に表示します.
                サブコマンド table で有効なオプションです.

            --from=DATE
                開始日を YYYY-MM-DD 形式で指定します.
                サブコマンド table, remaining-days で有効なオプションです.

            --to=DATE
                終了日を YYYY-MM-DD 形式で指定します.
                サブコマンド table, remaining-days で有効なオプションです.

        EXIT STATUS
            処理に成功した場合は 0.
            処理に失敗した場合は 0 以外.
    EOS
end

def update_holidays_database
    system('bash', "#{SCRIPTS_DIR}/updatedb.sh", exception: true)
end

def print_calendar_list
    options   = get_options(:list)
    today     = options[:today]
    from_date = options[:from_date] || today.beginning_of_month
    to_date   = options[:to_date] || today.end_of_month
    calendar  = new_business_calendar

    from_date.upto(to_date).each do |date|
        if holiday = calendar.lookup_holiday(date)
            puts ColoredString.new(
                "#{date.strftime('%F (%a)')} #{holiday.descriptions.join(', ')}".strip,
                :text_attribute => date == today ? :invert : :normal,
                :foreground     => :red)
        else
            puts ColoredString.new(
                date.strftime('%F (%a)'),
                :text_attribute => date == today ? :invert : :normal,
                :foreground     => :default)
        end
    end
end

def print_calendar_table
    options   = get_options(:table)
    today     = options[:today]
    from_date = options[:from_date] || today.beginning_of_month
    to_date   = options[:to_date] || today.end_of_month
    columns   = options[:columns]
    calendar  = new_business_calendar

    from_year_month       = from_date.beginning_of_month
    to_year_month         = to_date.beginning_of_month
    year_month            = from_year_month
    year_month_lines_list = []

    while year_month <= to_year_month
        year_month_lines_list.append(build_year_month_table_lines(calendar, year_month, today))
        year_month = year_month.next_month(1)
    end

    year_month_lines_list.each_slice(columns) do |lines_list|
        max_lines = lines_list.map(&:size).max
        header_line = WDAY_TO_NAME_MAP.values.join(' ')
        padding_line = ' ' * header_line.size

        lines_list.each do |lines|
            (max_lines - lines.size).times do
                lines.append(padding_line)
            end
        end

        max_lines.times.map do |n|
            puts lines_list.map{|lines| lines[n]}.join('  ')
        end

        puts
    end
end

def build_year_month_table_lines(calendar, year_month, today)
    lines = []

    header = WDAY_TO_NAME_MAP.values.join(' ')
    lines.append(year_month.strftime('%Y-%m').center(header.size))
    lines.append(header)

    date = year_month.beginning_of_month.beginning_of_week(0)
    while date.beginning_of_month <= year_month
        dates = (0..6).map{|offset| date + offset}
        lines.append(dates.map{|date|
            if date.month == year_month.month
                ColoredString.new(
                    sprintf('%2s', date.day),
                    :text_attribute => date == today ? :invert : :normal,
                    :foreground     => calendar.holiday?(date) ? :red : :default)
            else
                '  '
            end
        }.join(' '))
        date += 7
    end

    lines
end

def print_remaining_days
    options   = get_options(:remaining_days)
    today     = options[:today]
    from_date = options[:from_date] || today
    to_date   = options[:to_date]
    calendar  = new_business_calendar

    if to_date
        remaining_days = from_date.remaining_days(to_date, calendar)
        puts "#{remaining_days}d"
    else
        remaining_days_list = [
            from_date.remaining_days(from_date.end_of_week, calendar),
            from_date.remaining_days(from_date.end_of_month, calendar),
            from_date.remaining_days(from_date.end_of_quater, calendar),
            from_date.remaining_days(from_date.end_of_year, calendar),
        ]
        print_table([
            'week month quater year'.split(' '),
            remaining_days_list.map{|days| "#{days}d"},
        ])
    end
end

def new_business_calendar
    holidays = HolidaysFileLoader.new.holidays_from_files([
        "#{DATA_DIR}/japanese-holidays.tsv",
        "#{DATA_DIR}/company-holidays.tsv",
    ])
    BusinessCalendar.new(holidays)
rescue Errno::ENOENT
    raise LoadHolidaysFileFailed
end

def print_table(table)
    column_sizes = (0...table.first.size).map do |column_index|
        table.map{|row| row[column_index].size}.max
    end

    table.each do |row|
        format = column_sizes.map{|size| "%#{size}s"}.join(' ') + "\n"
        printf(format, *row)
    end
end

