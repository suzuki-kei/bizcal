require 'calendar'
require 'colored_string'
require 'command_line_options'
require 'date_calculations'
require 'exceptions'
require 'holiday_file_loader'
require 'pathname'

module ApplicationCommands

    def print_help
        file_path = ROOT_DIR.join('src', 'main', 'usage.txt')
        puts File.read(file_path).strip
    end

    def update_holiday_database
        file_path = SCRIPTS_DIR.join('updatedb.sh')
        system('bash', file_path, exception: true)
    end

    def print_calendar_list
        options   = CommandLineOptions.new.parse!(:list)
        today     = options[:today]
        from_date = options[:from_date] || today.beginning_of_month
        to_date   = options[:to_date] || today.end_of_month
        calendar  = new_calendar

        from_date.upto(to_date).each do |date|
            if holiday = calendar.lookup_holiday(date)
                puts ColoredString.new(
                    "#{date.strftime('%F (%a)')} #{holiday.descriptions.join(', ')}".strip,
                    **make_colored_string_options(date, today, calendar))
            else
                puts ColoredString.new(
                    date.strftime('%F (%a)'),
                    **make_colored_string_options(date, today, calendar))
            end
        end
    end

    def print_calendar_table
        options   = CommandLineOptions.new.parse!(:table)
        today     = options[:today]
        from_date = options[:from_date] || today.beginning_of_month
        to_date   = options[:to_date] || today.end_of_month
        columns   = options[:columns]
        calendar  = new_calendar

        from_year_month       = from_date.beginning_of_month
        to_year_month         = to_date.beginning_of_month
        year_month            = from_year_month
        year_month_lines_list = []

        while year_month <= to_year_month
            lines = build_year_month_table_lines(calendar, year_month, today)
            year_month_lines_list.append(lines)
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

    def print_remaining_days
        options   = CommandLineOptions.new.parse!(:remaining_days)
        today     = options[:today]
        from_date = options[:from_date] || today
        to_date   = options[:to_date]
        calendar  = new_calendar

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
                %w(week month quater year),
                remaining_days_list.map{|days| "#{days}d"},
            ])
        end
    end

    private

    ROOT_DIR = Pathname.new(File.expand_path(File.join(__dir__, '..', '..')))
    DATA_DIR = ROOT_DIR.join('data')
    SCRIPTS_DIR = ROOT_DIR.join('src', 'scripts')

    WDAY_TO_NAME_MAP = {
        0 => 'Su',
        1 => 'Mo',
        2 => 'Tu',
        3 => 'We',
        4 => 'Th',
        5 => 'Fr',
        6 => 'Sa',
    }

    def new_calendar
        holidays = HolidayFileLoader.new.load(
            DATA_DIR.join('japanese-holidays.tsv'),
            DATA_DIR.join('company-holidays.tsv'),
        )
        Calendar.new(holidays)
    rescue Errno::ENOENT
        raise LoadHolidayFileFailed
    end

    def make_colored_string_options(date, today, calendar)
        text_attribute = case
            when date == today
                :invert
            else
                :normal
        end

        holiday = calendar.lookup_holiday(date)

        foreground = case
            when holiday.nil?
                :default
            when date.saturday? && holiday.descriptions.empty?
                :blue
            when date.sunday? && holiday.descriptions.empty?
                :red
            else
                :red
        end

        {
            :text_attribute => text_attribute,
            :foreground => foreground,
            :background => :default,
        }
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
                        **make_colored_string_options(date, today, calendar))
                else
                    '  '
                end
            }.join(' '))
            date += 7
        end

        lines
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

end

