require 'date'

#
# ビジネスカレンダー.
#
class BusinessCalendar

    def initialize(holiday_map)
        @holiday_map = holiday_map
    end

    def holiday?(date)
        lookup_holiday(date) != nil
    end

    def lookup_holiday(date)
        case
            when @holiday_map.key?(date)
                @holiday_map[date]
            when date.saturday?
                Holiday.new(date)
            when date.sunday?
                Holiday.new(date)
            else
                nil
        end
    end

end

#
# 休業日.
#
class Holiday

    attr_reader :date

    # 休日の理由が複数存在する場合があるため配列とする.
    # 例えば "元旦" と "会社休業日" が重なる場合がある.
    attr_reader :descriptions

    def initialize(date, *descriptions)
        @date = date
        @descriptions = descriptions
    end

    def ==(holiday)
        self.class == holiday.class &&
            @date == holiday.date &&
            @descriptions == holiday.descriptions
    end

end

#
# 休業日ファイルのローダー.
#
class HolidaysFileLoader

    def holiday_map_from_files(file_paths)
        holidays_from_files(file_paths).reduce({}) do |map, holiday|
            if map.key?(holiday.date)
                map[holiday.date].descriptions.append(*holiday.descriptions)
            else
                map[holiday.date] = holiday
            end

            map
        end
    end

    def holidays_from_files(file_paths)
        file_paths.map(&method(:holidays_from_file)).reduce([], &:+)
    end

    def holidays_from_file(file_path)
        lines = File.readlines(file_path).map(&:chomp)
        lines.map(&method(:holiday_from_line))
    end

    def holiday_from_line(line)
        if line =~ /^(\d{4}-\d{2}-\d{2})\t(.+)$/
            Holiday.new(Date.parse($1), $2)
        else
            raise ArgumentError, "Invalid format: [#{line}]"
        end
    end

end

