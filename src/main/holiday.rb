
class Holiday

    attr_reader :date

    # 休日の理由が複数存在する場合があるため配列とする.
    # 例えば "元旦" と "会社休業日" が重なる場合がある.
    attr_reader :descriptions

    def initialize(date, *descriptions)
        @date = date
        @descriptions = descriptions
    end

    def merge(holiday)
        if @date != holiday.date
            raise ArgumentError
        end

        Holiday.new(@date, *(@descriptions + holiday.descriptions))
    end

    def ==(holiday)
        %i(class date descriptions).all? do |name|
            self.send(name) == holiday.send(name)
        end
    end

end

