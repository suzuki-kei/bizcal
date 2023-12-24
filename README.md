# bizcal

営業日/非営業日を考慮したカレンダーを表示します.
また, 特定日までの残り営業日を表示することもできます.

# 利用情報

## 必須ソフトウェア

 * Ruby

## インストール

    make install
    source ~/.bashrc
    bizcal updatedb

## 使い方

    bizcal help

# 開発情報

    # テストを実行する
    make test

# 祝日/休日情報

祝日/休日情報として以下のデータを利用しています.

 * 昭和30年（1955年）から令和2年（2020年）国民の祝日等（いわゆる振替休日等を含む）（csv形式：19KB）
   - https://data.e-gov.go.jp/data/dataset/cao_20190522_0002/resource/d9ad35a5-6c9c-4127-bdbe-aa138fdffe42
   - https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv

