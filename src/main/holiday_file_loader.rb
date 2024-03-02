require 'date'
require 'holiday'

class HolidayFileLoader

    def load(*file_paths)
        holidays_from_files(file_paths)
    end

    private

    def holidays_from_files(file_paths)
        file_paths.map(&method(:holidays_from_file)).reduce([], &:+)
    end

    def holidays_from_file(file_path)
        lines = File.readlines(file_path).map(&:chomp)
        lines.map(&method(:holiday_from_line))
    end

    def holiday_from_line(line)
        if line =~ /^(\d{4}-\d{2}-\d{2})\t(.+)$/
            Holiday.new(Date.parse($1), $2)
        else
            raise ArgumentError, "Invalid format: [#{line}]"
        end
    end

end

