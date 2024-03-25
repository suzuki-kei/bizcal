
class StringFormatter

    def initialize(wday_to_name_map)
        @wday_to_name_map = wday_to_name_map
    end

    def strftime(date, format:)
        case format
            when :year_month
                date.strftime('%Y-%m')
            when :date_with_wday
                "#{date.strftime('%F')} (#{@wday_to_name_map[date.wday]})"
            else
                raise ArgumentError, "invalid format: #{format}"
        end
    end

    def format_table(table)
        column_sizes = (0...table.first.size).map do |column_index|
            table.map{|row| display_width(row[column_index])}.max
        end

        lines = table.map do |row|
            padded_row = column_sizes.map.with_index do |column_size, index|
                padding = ' ' * (column_size - display_width(row[index]))
                "#{padding}#{row[index]}"
            end
            padded_row.join('  ')
        end

        lines.join("\n")
    end

    def display_width(text)
        ascii_chars, non_ascii_chars = text.chars.partition(&:ascii_only?)
        ascii_chars.size + non_ascii_chars.size * 2
    end

end

