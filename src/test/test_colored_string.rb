require 'test/unit'
require 'colored_string'

class ColoredStringTestCase < Test::Unit::TestCase

    def test_to_s
        assert_equal '', ColoredString.new('').to_s

        assert_equal "\e[0;39;49mtext\e[0m",
                     ColoredString.new('text').to_s

        assert_equal "\e[1;31;40mtext\e[0m",
                     ColoredString.new('text', text_attribute: :bold, foreground: :red, background: :black).to_s
    end

end

