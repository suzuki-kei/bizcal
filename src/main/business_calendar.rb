require 'date'

#
# ビジネスカレンダー.
#
class BusinessCalendar

    def initialize(holidays)
        @holiday_map = holidays.reduce({}) do |map, holiday|
            map.tap do
                if map.key?(holiday.date)
                    map[holiday.date] = map[holiday.date].merge(holiday)
                else
                    map[holiday.date] = holiday
                end
            end
        end
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

    def merge(holiday)
        if @date != holiday.date
            raise ArgumentError
        end

        Holiday.new(@date, *(@descriptions + holiday.descriptions))
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

