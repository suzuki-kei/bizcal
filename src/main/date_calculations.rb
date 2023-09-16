require 'date'
require 'time'

module DateCalculations

    def beginning_of_day
        Time.new(year, month, date)
    end

    def end_of_day
        Time.new(year, month, date + 1) - 1
    end

    def beginning_of_week(base_wday=0)
        # 0=日曜日, 6=土曜日
        duration_days = (wday + 7 - base_wday) % 7
        self - duration_days
    end

    def end_of_week(base_wday=0)
        # 0=日曜日, 6=土曜日
        duration_days = (7 - wday - base_wday) % 7
        self + duration_days
    end

    def beginning_of_month
        Date.new(year, month, 1)
    end

    def end_of_month
        beginning_of_month.next_month - 1
    end

    def beginning_of_quater
        Date.new(year, (quater - 1) * 3 + 1, 1)
    end

    def end_of_quater
        beginning_of_quater.next_month(3) - 1
    end

    def beginning_of_year
        Date.new(year, 1, 1)
    end

    def end_of_year
        Date.new(year, 12, 31)
    end

    def quater
        (month + 2) / 3
    end

    def remaining_days(to_date, calendar)
        upto(to_date).reject(&calendar.method(:holiday?)).size
    end

end

class Date

    include DateCalculations

end

