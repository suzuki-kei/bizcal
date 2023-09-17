require 'date'
require 'business_calendar'

def new_business_calendar_2000
    date_description_pairs = [
        [Date.new(2000,  1,  1), '元日'],
        [Date.new(2000,  1,  2), '会社休業日'],
        [Date.new(2000,  1,  3), '会社休業日'],
        [Date.new(2000,  1, 10), '成人の日'],
        [Date.new(2000,  2, 11), '建国記念の日'],
        [Date.new(2000,  3, 20), '春分の日'],
        [Date.new(2000,  4, 29), 'みどりの日'],
        [Date.new(2000,  5,  3), '憲法記念日'],
        [Date.new(2000,  5,  4), '休日'],
        [Date.new(2000,  5,  5), 'こどもの日'],
        [Date.new(2000,  7, 20), '海の日'],
        [Date.new(2000,  9, 15), '敬老の日'],
        [Date.new(2000,  9, 23), '秋分の日'],
        [Date.new(2000, 10,  9), '体育の日'],
        [Date.new(2000, 11,  3), '文化の日'],
        [Date.new(2000, 11, 23), '勤労感謝の日'],
        [Date.new(2000, 12, 23), '天皇誕生日'],
        [Date.new(2000, 12, 29), '会社休業日'],
        [Date.new(2000, 12, 30), '会社休業日'],
        [Date.new(2000, 12, 31), '会社休業日'],
    ]

    holiday_map = date_description_pairs.reduce({}) do |map, (date, description)|
        map[date] = Holiday.new(date, description)
        map
    end

    BusinessCalendar.new(holiday_map)
end

