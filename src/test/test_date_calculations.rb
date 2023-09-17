require 'test/unit'
require 'date_calculations'
require 'business_calendar'

class DateCalculationsTestCase < Test::Unit::TestCase

    def test_beginning_of_day
        expected = Time.new(2000, 1, 1, 0, 0, 0)

        assert_equal expected, Time.new(2000, 1, 1,  0,  0,  0).beginning_of_day
        assert_equal expected, Time.new(2000, 1, 1,  0,  0,  1).beginning_of_day
        assert_equal expected, Time.new(2000, 1, 1, 23, 59, 59).beginning_of_day
    end

    def test_end_of_day
        expected = Time.new(2000, 1, 1, 23, 59, 59)

        assert_equal expected, Time.new(2000, 1, 1,  0,  0,  0).end_of_day
        assert_equal expected, Time.new(2000, 1, 1,  0,  0,  1).end_of_day
        assert_equal expected, Time.new(2000, 1, 1, 23, 59, 59).end_of_day
    end

    def test_beginning_of_week
        # 2000-01-16 は日曜日.
        today = Date.new(2000, 1, 16)

        assert_equal Date.new(2000, 1, 16), today.beginning_of_week(0)
        assert_equal Date.new(2000, 1, 10), today.beginning_of_week(1)
        assert_equal Date.new(2000, 1, 11), today.beginning_of_week(2)
        assert_equal Date.new(2000, 1, 12), today.beginning_of_week(3)
        assert_equal Date.new(2000, 1, 13), today.beginning_of_week(4)
        assert_equal Date.new(2000, 1, 14), today.beginning_of_week(5)
        assert_equal Date.new(2000, 1, 15), today.beginning_of_week(6)
    end

    def test_end_of_week
        # 2000-01-16 は日曜日.
        today = Date.new(2000, 1, 16)

        assert_equal Date.new(2000, 1, 22), today.end_of_week(0)
        assert_equal Date.new(2000, 1, 16), today.end_of_week(1)
        assert_equal Date.new(2000, 1, 17), today.end_of_week(2)
        assert_equal Date.new(2000, 1, 18), today.end_of_week(3)
        assert_equal Date.new(2000, 1, 19), today.end_of_week(4)
        assert_equal Date.new(2000, 1, 20), today.end_of_week(5)
        assert_equal Date.new(2000, 1, 21), today.end_of_week(6)
    end

    def test_beginning_of_month
        expected = Date.new(2000, 1, 1)

        assert_equal expected, Date.new(2000, 1,  1).beginning_of_month
        assert_equal expected, Date.new(2000, 1,  2).beginning_of_month
        assert_equal expected, Date.new(2000, 1, 31).beginning_of_month
    end

    def test_end_of_month
        expected = Date.new(2000, 1, 31)

        assert_equal expected, Date.new(2000, 1,  1).end_of_month
        assert_equal expected, Date.new(2000, 1, 30).end_of_month
        assert_equal expected, Date.new(2000, 1, 31).end_of_month
    end

    def test_beginning_of_quater
        assert_equal Date.new(2000,  1, 1), Date.new(2000,  1,  1).beginning_of_quater
        assert_equal Date.new(2000,  1, 1), Date.new(2000,  1,  2).beginning_of_quater
        assert_equal Date.new(2000,  1, 1), Date.new(2000,  3, 31).beginning_of_quater

        assert_equal Date.new(2000,  4, 1), Date.new(2000,  4,  1).beginning_of_quater
        assert_equal Date.new(2000,  4, 1), Date.new(2000,  4,  2).beginning_of_quater
        assert_equal Date.new(2000,  4, 1), Date.new(2000,  6, 30).beginning_of_quater

        assert_equal Date.new(2000,  7, 1), Date.new(2000,  7,  1).beginning_of_quater
        assert_equal Date.new(2000,  7, 1), Date.new(2000,  7,  2).beginning_of_quater
        assert_equal Date.new(2000,  7, 1), Date.new(2000,  9, 30).beginning_of_quater

        assert_equal Date.new(2000, 10, 1), Date.new(2000, 10,  1).beginning_of_quater
        assert_equal Date.new(2000, 10, 1), Date.new(2000, 10,  2).beginning_of_quater
        assert_equal Date.new(2000, 10, 1), Date.new(2000, 12, 31).beginning_of_quater
    end

    def test_end_of_quater
        assert_equal Date.new(2000,  3, 31), Date.new(2000,  1,  1).end_of_quater
        assert_equal Date.new(2000,  3, 31), Date.new(2000,  3, 30).end_of_quater
        assert_equal Date.new(2000,  3, 31), Date.new(2000,  3, 31).end_of_quater

        assert_equal Date.new(2000,  6, 30), Date.new(2000,  4,  1).end_of_quater
        assert_equal Date.new(2000,  6, 30), Date.new(2000,  6, 29).end_of_quater
        assert_equal Date.new(2000,  6, 30), Date.new(2000,  6, 30).end_of_quater

        assert_equal Date.new(2000,  9, 30), Date.new(2000,  7,  1).end_of_quater
        assert_equal Date.new(2000,  9, 30), Date.new(2000,  9, 29).end_of_quater
        assert_equal Date.new(2000,  9, 30), Date.new(2000,  9, 30).end_of_quater

        assert_equal Date.new(2000, 12, 31), Date.new(2000, 10,  1).end_of_quater
        assert_equal Date.new(2000, 12, 31), Date.new(2000, 12, 30).end_of_quater
        assert_equal Date.new(2000, 12, 31), Date.new(2000, 12, 31).end_of_quater
    end

    def test_beginning_of_year
        assert_equal Date.new(2000, 1, 1), Date.new(2000,  1,  1).beginning_of_year
        assert_equal Date.new(2000, 1, 1), Date.new(2000,  1,  2).beginning_of_year
        assert_equal Date.new(2000, 1, 1), Date.new(2000, 12, 31).beginning_of_year

        assert_equal Date.new(2001, 1, 1), Date.new(2001,  1,  1).beginning_of_year
        assert_equal Date.new(2001, 1, 1), Date.new(2001,  1,  2).beginning_of_year
        assert_equal Date.new(2001, 1, 1), Date.new(2001, 12, 31).beginning_of_year
    end

    def test_end_of_year
        assert_equal Date.new(2000, 12, 31), Date.new(2000,  1,  1).end_of_year
        assert_equal Date.new(2000, 12, 31), Date.new(2000, 12, 30).end_of_year
        assert_equal Date.new(2000, 12, 31), Date.new(2000, 12, 31).end_of_year

        assert_equal Date.new(2001, 12, 31), Date.new(2001,  1,  1).end_of_year
        assert_equal Date.new(2001, 12, 31), Date.new(2001, 12, 30).end_of_year
        assert_equal Date.new(2001, 12, 31), Date.new(2001, 12, 31).end_of_year
    end

    def test_quater
        assert_equal 1, Date.new(2000,  1,  1).quater
        assert_equal 1, Date.new(2000,  3, 31).quater
        assert_equal 2, Date.new(2000,  4,  1).quater
        assert_equal 2, Date.new(2000,  6, 30).quater
        assert_equal 3, Date.new(2000,  7,  1).quater
        assert_equal 3, Date.new(2000,  9, 30).quater
        assert_equal 4, Date.new(2000, 10,  1).quater
        assert_equal 4, Date.new(2000, 12, 31).quater
    end

    def test_remaining_days
        to_date = Date.new(2000, 12, 31)
        calendar = new_business_calendar_2000

        assert_equal 42, Date.new(2000, 10, 30).remaining_days(to_date, calendar)
        assert_equal 38, Date.new(2000, 11,  6).remaining_days(to_date, calendar)
        assert_equal 33, Date.new(2000, 11, 13).remaining_days(to_date, calendar)
        assert_equal 28, Date.new(2000, 11, 20).remaining_days(to_date, calendar)
        assert_equal 24, Date.new(2000, 11, 27).remaining_days(to_date, calendar)
        assert_equal 19, Date.new(2000, 12,  4).remaining_days(to_date, calendar)
        assert_equal 14, Date.new(2000, 12, 11).remaining_days(to_date, calendar)
        assert_equal  9, Date.new(2000, 12, 18).remaining_days(to_date, calendar)
        assert_equal  4, Date.new(2000, 12, 25).remaining_days(to_date, calendar)
    end

    def new_business_calendar_2000
        holiday_map = {
            Date.new(2000,  1,  1) => '元日',
            Date.new(2000,  1,  2) => '会社休業日',
            Date.new(2000,  1,  3) => '会社休業日',
            Date.new(2000,  1, 10) => '成人の日',
            Date.new(2000,  2, 11) => '建国記念の日',
            Date.new(2000,  3, 20) => '春分の日',
            Date.new(2000,  4, 29) => 'みどりの日',
            Date.new(2000,  5,  3) => '憲法記念日',
            Date.new(2000,  5,  4) => '休日',
            Date.new(2000,  5,  5) => 'こどもの日',
            Date.new(2000,  7, 20) => '海の日',
            Date.new(2000,  9, 15) => '敬老の日',
            Date.new(2000,  9, 23) => '秋分の日',
            Date.new(2000, 10,  9) => '体育の日',
            Date.new(2000, 11,  3) => '文化の日',
            Date.new(2000, 11, 23) => '勤労感謝の日',
            Date.new(2000, 12, 23) => '天皇誕生日',
            Date.new(2000, 12, 29) => '会社休業日',
            Date.new(2000, 12, 30) => '会社休業日',
            Date.new(2000, 12, 31) => '会社休業日',
        }
        BusinessCalendar.new(holiday_map)
    end

end

