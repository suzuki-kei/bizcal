
#
# アプリケーション定義エラー.
#
# アプリケーションが独自に定義する全ての例外クラスは本クラスのサブクラスとして定義する.
#
class BizCalError < StandardError

end

#
# 祝日/休日ファイルの読み込みに失敗したことを表す例外.
#
class LoadHolidaysFileFailed < BizCalError

    def initialize
        super(<<~'EOS')
            Failed to load holidays files.

            Run the following command. You may be able to recover from the error.

                bizcal updatedb
        EOS
    end

end

#
# オプションの解析に失敗したことを表す例外.
#
class ParseOptionFailed < BizCalError

    def initialize(exception)
        super(exception)
    end

end

#
# 日付の解析に失敗したことを表す例外.
#
class ParseDateFailed < BizCalError

    def initialize(string)
        super(<<~"EOS")
            Faild to parse date: [#{string}]

            Specify the date in "YYYY-MM-DD" format.
        EOS
    end

end

#
# 日付が有効範囲外であることを表す例外.
#
class DateOutOfRangeError < BizCalError

    def initialize(range)
        super(<<~"EOS")
            Date out of range.

            Specify the date in [#{range.min}, #{range.max}].

            Run the following command. You may be able to recover from the error.

                bizcal updatedb
        EOS
    end

end

