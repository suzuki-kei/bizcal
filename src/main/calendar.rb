require 'exceptions'

class Calendar

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

    def range
        dates = @holiday_map.keys
        dates.min.beginning_of_month .. dates.max.end_of_month
    end

    def holiday?(date)
        lookup_holiday(date) != nil
    end

    def lookup_holiday(date)
        if !range.cover?(date)
            raise DateOutOfRangeError.new(range)
        end

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

