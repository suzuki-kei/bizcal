require 'application_commands'

class Application

    include ApplicationCommands

    def run
        case ARGV[0]
            when nil
                print_calendar_table
            when 'help', '-h', '--help'
                ARGV.shift
                print_help
            when 'updatedb'
                ARGV.shift
                update_holiday_database
            when 'list'
                ARGV.shift
                print_calendar_list
            when 'table'
                ARGV.shift
                print_calendar_table
            when 'remaining-days'
                ARGV.shift
                print_remaining_days
            when /^-/
                print_calendar_table
            else
                print_help
        end
    rescue BizCalError => exception
        $stderr.puts "[ERROR] #{exception}"
        exit 1
    end

end

