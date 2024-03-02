require 'holiday'
require 'test/unit'

class HolidayTestCase < Test::Unit::TestCase

    def test_merge
        holiday1 = Holiday.new(Date.new(2000, 1, 1), '元日')
        holiday2 = Holiday.new(Date.new(2000, 1, 1), '会社休業日')
        merged_holiday = holiday1.merge(holiday2)

        # 元の値は変更せずに新しい Holiday が生成される.
        assert_equal Date.new(2000, 1, 1), holiday1.date
        assert_equal ['元日'], holiday1.descriptions
        assert_equal Date.new(2000, 1, 1), holiday2.date
        assert_equal ['会社休業日'], holiday2.descriptions

        # 日付が同じ場合は descriptions がマージされた Holiday が生成される.
        assert_equal Date.new(2000, 1, 1), merged_holiday.date
        assert_equal ['元日', '会社休業日'], merged_holiday.descriptions

        # 日付が異なる場合は ArgumentError となる.
        assert_raise(ArgumentError) do
            holiday1 = Holiday.new(Date.new(2000, 1, 1))
            holiday2 = Holiday.new(Date.new(2000, 1, 2))
            holiday1.merge(holiday2)
        end
    end

    def test_equals
        assert_true Holiday.new(Date.new(2000, 1, 1)) == Holiday.new(Date.new(2000, 1, 1))
        assert_false Holiday.new(Date.new(2000, 1, 1)) == Holiday.new(Date.new(2000, 1, 2))
    end

end

