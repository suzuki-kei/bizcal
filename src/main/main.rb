require 'business_calendar'
require 'colored_string'
require 'date'
require 'date_calculations'
require 'optparse'

DATA_DIR = "#{__dir__}/../../data"

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
    if ARGV.empty?
        raise ArgumentError, 'subcommand is no specified.'
    end

    subcommand = ARGV.shift

    case subcommand
        when 'list'
            print_calendar_list
        when 'table'
            print_calendar_table
        when 'remaining-days'
            print_remaining_days
        else
            raise ArgumentError, "Invalid subcommand: [#{subcommand}]"
    end
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

    OptionParser.new.tap do |parser|
        if %i(list table).include?(mode)
            parser.on('-1', '--one') {
                options[:from_date] = today.beginning_of_month
                options[:to_date]   = today.end_of_month
            }
            parser.on('-3', '--three') {
                options[:from_date] = today.next_month(-1).beginning_of_month
                options[:to_date]   = today.next_month(1).end_of_month
            }
            parser.on('-Y', '--twelve') {
                options[:from_date] = today.beginning_of_month
                options[:to_date]   = today.next_month(11).end_of_month
            }
            parser.on('-y', '--year') {
                options[:from_date] = today.beginning_of_year
                options[:to_date]   = today.end_of_year
            }
            parser.on('-n N', '--months=N', Integer) {|n|
                options[:from_date] = today.beginning_of_month
                options[:to_date]   = today.next_month(n - 1).end_of_month
            }
        end

        if %i(table).include?(mode)
            parser.on('-c N', '--columns=N', Integer) {|n|
                options[:columns]   = n
            }
        end

        if %i(list remaining_days).include?(mode)
            parser.on('--from=D', String) {|date|
                options[:from_date] = Date.parse(date)
            }
            parser.on('--to=D', String) {|date|
                options[:to_date] = Date.parse(date)
            }
        end

        parser.parse!(ARGV)
    end

    options
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
    from_date = options[:from_date]
    to_date   = options[:to_date]
    calendar  = new_business_calendar

    if to_date
        base = from_date || today
        remaining_days = base.remaining_days(to_date, calendar)
        puts "#{remaining_days}d"
    else
        base = from_date || today
        remaining_days_list = [
            base.remaining_days(base.end_of_week, calendar),
            base.remaining_days(base.end_of_month, calendar),
            base.remaining_days(base.end_of_quater, calendar),
            base.remaining_days(base.end_of_year, calendar),
        ]
        print_table([
            'week month quater year'.split(' '),
            remaining_days_list.map{|days| "#{days}d"},
        ])
    end
end

def new_business_calendar
    holiday_map = load_holiday_map
    BusinessCalendar.new(holiday_map)
end

def load_holiday_map
    HolidaysFileLoader.new.holiday_map_from_files([
        "#{DATA_DIR}/japanese-holidays.tsv",
        "#{DATA_DIR}/company-holidays.tsv",
    ])
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

