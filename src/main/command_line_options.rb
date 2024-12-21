require 'date'
require 'optparse'

class CommandLineOptions

    def parse!(mode, today: Date.today, argv: ARGV)
        parser, options = new_parser(mode, today)
        parser.parse!(argv)
        options
    rescue OptionParser::InvalidOption => exception
        raise ParseOptionFailed, exception
    end

    private

    def new_parser(mode, today)
        if ! %i(list table remaining_days).include?(mode)
            raise ArgumentError, "Invalid mode: [#{mode}]"
        end

        options = {
            :locale    => :en,
            :color     => true,
            :today     => today,
            :from_date => nil,
            :to_date   => nil,
            :columns   => 3,
        }

        parser = OptionParser.new("bizcal #{mode} [OPTION...]").tap do |parser|
            if %i(list table remaining_days).include?(mode)
                parser.on('--en', 'ロケール依存の文字列を英語で表示します') {
                    options[:locale] = :en
                }
                parser.on('--ja', 'ロケール依存の文字列を日本語で表示します') {
                    options[:locale] = :ja
                }
                parser.on('--no-color', '色付けせずに出力します') {
                    options[:color] = false
                }
            end

            if %i(list table).include?(mode)
                parser.on('-1', '--one', '今月のカレンダーを表示します.') {
                    options[:from_date] = today.beginning_of_month
                    options[:to_date] = today.end_of_month
                }
                parser.on('-3', '--three', '今月を中心に 3 ヶ月分のカレンダーを表示します.') {
                    options[:from_date] = today.next_month(-1).beginning_of_month
                    options[:to_date] = today.next_month(1).end_of_month
                }
                parser.on('-Y', '--twelve', '今月を起点に 12 ヶ月分のカレンダーを表示します.') {
                    options[:from_date] = today.beginning_of_month
                    options[:to_date] = today.next_month(11).end_of_month
                }
                parser.on('-y', '--year', '今年 1 年分のカレンダーを表示します.') {
                    options[:from_date] = today.beginning_of_year
                    options[:to_date] = today.end_of_year
                }
                parser.on('-n N', '--months=N', Integer, '今月を起点に N ヶ月分のカレンダーを表示します.') {|n|
                    options[:from_date] = today.beginning_of_month
                    options[:to_date] = today.next_month(n - 1).end_of_month
                }
            end

            if %i(table).include?(mode)
                parser.on('-c N', '--columns=N', Integer, 'N ヶ月分のカレンダーを横に表示します.') {|n|
                    options[:columns] = n
                }
            end

            if %i(list remaining_days).include?(mode)
                parser.on('--from=DATE', String, '開始日を YYYY-MM-DD 形式で指定します.') {|date|
                    options[:from_date] = parse_date(date)
                }
                parser.on('--to=DATE', String, '終了日を YYYY-MM-DD 形式で指定します.') {|date|
                    options[:to_date] = parse_date(date)
                }
            end
        end

        [parser, options]
    end

    def parse_date(string)
        Date.strptime(string, '%Y-%m-%d')
    rescue Date::Error
        raise ParseDateFailed, string
    end

end

