require 'calendar'
require 'calendar_2000'
require 'test/unit'

class CalendarTestCase < Test::Unit::TestCase

    def test_range
        calendar = Calendar.new([
            Holiday.new(Date.new(2000, 1, 1)),
        ])
        assert_equal Date.new(2000, 1, 1) .. Date.new(2000, 1, 31), calendar.range

        calendar = Calendar.new([
            Holiday.new(Date.new(2000, 1, 2)),
        ])
        assert_equal Date.new(2000, 1, 1) .. Date.new(2000, 1, 31), calendar.range

        calendar = Calendar.new([
            Holiday.new(Date.new(2000, 1, 31)),
        ])
        assert_equal Date.new(2000, 1, 1) .. Date.new(2000, 1, 31), calendar.range

        calendar = Calendar.new([
            Holiday.new(Date.new(2000, 1, 1)),
            Holiday.new(Date.new(2000, 2, 1)),
        ])
        assert_equal Date.new(2000, 1, 1) .. Date.new(2000, 2, 29), calendar.range
    end

    def test_holiday?
        calendar = new_calendar_2000

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
        calendar = new_calendar_2000

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

