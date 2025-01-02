require 'calendar'
require 'colored_string'
require 'command_line_options'
require 'date_calculations'
require 'exceptions'
require 'holiday_file_loader'
require 'pathname'
require 'string_formatter'

module ApplicationCommands

    def print_help
        file_path = ROOT_DIR.join('src', 'main', 'usage.txt')
        puts File.read(file_path).strip
    end

    def update_holiday_database
        file_path = SCRIPTS_DIR.join('updatedb.sh').to_s
        system('bash', file_path, exception: true)
    end

    def print_calendar_list
        options   = CommandLineOptions.new.parse!(:list)
        locale    = options[:locale]
        today     = options[:today]
        from_date = options[:from_date] || today.beginning_of_month
        to_date   = options[:to_date] || today.end_of_month
        calendar  = new_calendar

        formatter = StringFormatter.new(LOCALE_TO_WDAY_TO_NAME_MAP[locale])

        from_date.upto(to_date).each do |date|
            if holiday = calendar.lookup_holiday(date)
                text = "#{formatter.strftime(date, format: :date_with_wday)} #{holiday.descriptions.join(', ')}".strip
                puts make_colored_string(text, date, today, calendar, options)
            else
                text = formatter.strftime(date, format: :date_with_wday)
                puts make_colored_string(text, date, today, calendar, options)
            end
        end
    end

    def print_calendar_table
        options   = CommandLineOptions.new.parse!(:table)
        locale    = options[:locale]
        today     = options[:today]
        from_date = options[:from_date] || today.beginning_of_month
        to_date   = options[:to_date] || today.end_of_month
        columns   = options[:columns]
        calendar  = new_calendar

        formatter = StringFormatter.new(LOCALE_TO_WDAY_TO_NAME_MAP[locale])
        from_year_month       = from_date.beginning_of_month
        to_year_month         = to_date.beginning_of_month
        year_month            = from_year_month
        year_month_lines_list = []

        while year_month <= to_year_month
            lines = build_year_month_table_lines(locale, calendar, year_month, today, options)
            year_month_lines_list.append(lines)
            year_month = year_month.next_month(1)
        end

        year_month_lines_list.each_slice(columns) do |lines_list|
            max_lines = lines_list.map(&:size).max
            header_line = LOCALE_TO_WDAY_TO_NAME_MAP[locale].values.join(' ')
            padding_line = ' ' * formatter.display_width(header_line)

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
        locale    = options[:locale]
        today     = options[:today]
        from_date = options[:from_date] || today
        to_date   = options[:to_date]
        calendar  = new_calendar

        if to_date
            remaining_days = from_date.remaining_days(to_date, calendar)
            puts "#{remaining_days}d"
        else
            titles = {
                en: %w(week month quater year),
                ja: %w(今週 今月 今四半期 今年),
            }[locale]

            remaining_days_list = [
                from_date.remaining_days(from_date.end_of_week, calendar),
                from_date.remaining_days(from_date.end_of_month, calendar),
                from_date.remaining_days(from_date.end_of_quater, calendar),
                from_date.remaining_days(from_date.end_of_year, calendar),
            ]

            remaining_percent_list = [
                remaining_percent(calendar, from_date, :week),
                remaining_percent(calendar, from_date, :month),
                remaining_percent(calendar, from_date, :quater),
                remaining_percent(calendar, from_date, :year),
            ]

            formatter = StringFormatter.new(LOCALE_TO_WDAY_TO_NAME_MAP[locale])
            puts formatter.format_table([
                titles,
                remaining_days_list.map{|days| "#{days}d"},
                remaining_percent_list.map{|percent| sprintf('%.1f%%', percent)},
            ])
        end
    end

    private

    ROOT_DIR = Pathname.new(File.expand_path(File.join(__dir__, '..', '..')))
    DATA_DIR = ROOT_DIR.join('data')
    SCRIPTS_DIR = ROOT_DIR.join('src', 'scripts')

    LOCALE_TO_WDAY_TO_NAME_MAP = {
        en: {
            0 => 'Su',
            1 => 'Mo',
            2 => 'Tu',
            3 => 'We',
            4 => 'Th',
            5 => 'Fr',
            6 => 'Sa',
        },
        ja: {
            0 => '日',
            1 => '月',
            2 => '火',
            3 => '水',
            4 => '木',
            5 => '金',
            6 => '土',
        },
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

    def make_colored_string(string, date, today, calendar, options)
        if options[:color]
            ColoredString.new(string, **make_colored_string_options(date, today, calendar))
        else
            string
        end
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

    def build_year_month_table_lines(locale, calendar, year_month, today, options)
        lines = []

        wday_to_name_map = LOCALE_TO_WDAY_TO_NAME_MAP[locale]
        formatter = StringFormatter.new(wday_to_name_map)

        header = wday_to_name_map.values.join(' ')
        lines.append(formatter.strftime(year_month, format: :year_month).center(formatter.display_width(header)))
        lines.append(header)

        date = year_month.beginning_of_month.beginning_of_week(0)
        while date.beginning_of_month <= year_month
            dates = (0..6).map{|offset| date + offset}
            lines.append(dates.map{|date|
                if date.month == year_month.month
                    text = sprintf('%2s', date.day)
                    make_colored_string(text, date, today, calendar, options)
                else
                    '  '
                end
            }.join(' '))
            date += 7
        end

        lines
    end

    def remaining_percent(calendar, from_date, unit)
        beginning_of_unit = from_date.send("beginning_of_#{unit}")
        end_of_unit = from_date.send("end_of_#{unit}")

        numerator = from_date.remaining_days(end_of_unit, calendar)
        denominator = beginning_of_unit.remaining_days(end_of_unit, calendar)

        if denominator == 0
            0.0
        else
            numerator * 100.0 / denominator
        end
    end

end

