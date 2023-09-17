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

        assert_equal true,  calendar.holiday?(Date.new(2000, 1,  1))
        assert_equal true,  calendar.holiday?(Date.new(2000, 1,  2))
        assert_equal true,  calendar.holiday?(Date.new(2000, 1,  3))
        assert_equal false, calendar.holiday?(Date.new(2000, 1,  4))
        assert_equal false, calendar.holiday?(Date.new(2000, 1,  5))
        assert_equal false, calendar.holiday?(Date.new(2000, 1,  6))
        assert_equal false, calendar.holiday?(Date.new(2000, 1,  7))
        assert_equal true,  calendar.holiday?(Date.new(2000, 1,  8))
        assert_equal true,  calendar.holiday?(Date.new(2000, 1,  9))
        assert_equal true,  calendar.holiday?(Date.new(2000, 1, 10))
    end

    def test_lookup_holiday
        calendar = new_business_calendar_2000

        assert_equal Holiday.new(Date.new(2000, 1, 1), '元日'),
                     calendar.lookup_holiday(Date.new(2000, 1, 1))
        assert_equal Holiday.new(Date.new(2000, 1, 2), '会社休業日'),
                     calendar.lookup_holiday(Date.new(2000, 1, 2))
        assert_equal Holiday.new(Date.new(2000, 1, 3), '会社休業日'),
                     calendar.lookup_holiday(Date.new(2000, 1, 3))
        assert_equal nil,
                     calendar.lookup_holiday(Date.new(2000, 1, 4))
        assert_equal nil,
                     calendar.lookup_holiday(Date.new(2000, 1, 5))
        assert_equal nil,
                     calendar.lookup_holiday(Date.new(2000, 1, 6))
        assert_equal nil,
                     calendar.lookup_holiday(Date.new(2000, 1, 7))
        assert_equal Holiday.new(Date.new(2000, 1, 8)),
                     calendar.lookup_holiday(Date.new(2000, 1, 8))
        assert_equal Holiday.new(Date.new(2000, 1, 9)),
                     calendar.lookup_holiday(Date.new(2000, 1, 9))
        assert_equal Holiday.new(Date.new(2000, 1, 10), '成人の日'),
                     calendar.lookup_holiday(Date.new(2000, 1, 10))
    end

end

