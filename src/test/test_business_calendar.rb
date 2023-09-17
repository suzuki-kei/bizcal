require 'test/unit'
require 'business_calendar'
require 'business_calendar_2000'

class HolidayTestCase < Test::Unit::TestCase

    def test_equals
        assert_true Holiday.new(Date.new(2000, 1, 1)) == Holiday.new(Date.new(2000, 1, 1))
        assert_false Holiday.new(Date.new(2000, 1, 1)) == Holiday.new(Date.new(2000, 1, 2))
    end

end

class BusinessCalendarTestCase < Test::Unit::TestCase

    def test_holiday?
        calendar = new_business_calendar_2000

        assert_equal true, calendar.holiday?(Date.new(2000, 1, 1))
        assert_equal true, calendar.holiday?(Date.new(2000, 1, 2))
        assert_equal true, calendar.holiday?(Date.new(2000, 1, 3))
        assert_equal false, calendar.holiday?(Date.new(2000, 1, 4))
        assert_equal false, calendar.holiday?(Date.new(2000, 1, 5))
        assert_equal false, calendar.holiday?(Date.new(2000, 1, 6))
        assert_equal false, calendar.holiday?(Date.new(2000, 1, 7))
        assert_equal true, calendar.holiday?(Date.new(2000, 1, 8))
        assert_equal true, calendar.holiday?(Date.new(2000, 1, 9))
        assert_equal true, calendar.holiday?(Date.new(2000, 1, 10))
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


