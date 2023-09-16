#
# エスケープシーケンスで装飾した文字列.
#
# 実装方針
#  * 全てのエスケープシーケンスに対応しない.
#    (bizcal に必要な機能に対応すれば良い)
#
# 参考情報
#  * https://en.wikipedia.org/wiki/ANSI_escape_code
#
class ColoredString

    TEXT_ATTRIBUTE_MAP = {
        :normal     => 0,
        :bold       => 1,
        :italic     => 3,
        :underline  => 4,
        :blink      => 5,
        :invert     => 7,
        :strike_out => 9,
    }

    FOREGROUND_COLOR_MAP = {
        :default    => 39,
        :black      => 30,
        :red        => 31,
        :green      => 32,
        :yellow     => 33,
        :blue       => 34,
        :magenta    => 34,
        :cyan       => 36,
        :white      => 37,
    }

    BACKGROUND_COLOR_MAP = {
        :default    => 49,
        :black      => 40,
        :red        => 41,
        :green      => 42,
        :yellow     => 43,
        :blue       => 44,
        :magenta    => 44,
        :cyan       => 46,
        :white      => 47,
    }

    def initialize(string, text_attribute: :normal, foreground: :default, background: :default)
        begin
            @string = string
            @text_attribute = TEXT_ATTRIBUTE_MAP.fetch(text_attribute)
            @foreground = FOREGROUND_COLOR_MAP.fetch(foreground)
            @background = BACKGROUND_COLOR_MAP.fetch(background)
        rescue KeyError => error
            raise ArgumentError, "Invalid name: [#{error.key}]"
        end
    end

    def to_s
        "\033[#{@text_attribute};#{@foreground}m\033[#{@background}m#{@string}\033[0m"
    end

end

