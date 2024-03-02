require 'application'

def main
    Application.new.run
rescue BizCalError => exception
    $stderr.puts "[ERROR] #{exception}"
    exit 1
end

