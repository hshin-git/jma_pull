#!/bin/bash
echo "##################################################"
echo "ENTER:" $(date)

#DEBUG=echo
#PYTHON=/home/shin/anaconda3/bin/python
#PYTHON=/home/ubuntu/anaconda3/bin/python

JMA_PATH=~/Documents/python/jma_pull
#JMA_PATH=/home/ubuntu/jma_pull
for x in pdf png latest; do
  mkdir -p ${JMA_PATH}/$x
done

PNG_OPTS="-singlefile -scale-to 1240"
#PNG_OPTS="-singlefile"


echo "##################################################"
##### 年月日時の計算: 毎日JST=00,06,12,18の起動
JST_DATE=$(date "+%Y%m%d%H")
UTC_DATE=$(date "+%Y%m%d%H" -d "-9 hours")
#JST_DATE="2020053108"
#UTC_DATE="2020053023"

JST_HOUR=${JST_DATE:8}
UTC_HOUR=${UTC_DATE:8}
echo "JST" $JST_DATE $JST_HOUR
echo "UTC" $UTC_DATE $UTC_HOUR

## タイムスタンプの調整
UTC_HOUR_06=$(printf "%02d" $(expr $(expr $UTC_HOUR / 6) "*" 6))
UTC_HOUR_12=$(printf "%02d" $(expr $(expr $UTC_HOUR / 12) "*" 12))

UTC_DATE_00=${UTC_DATE:0:8}
UTC_DATE_06=${UTC_DATE:0:8}${UTC_HOUR_06}
UTC_DATE_12=${UTC_DATE:0:8}${UTC_HOUR_12}

echo "UTC_00" $UTC_DATE_00
echo "UTC_06" $UTC_DATE_06 $UTC_HOUR_06
echo "UTC_12" $UTC_DATE_12 $UTC_HOUR_12


##### リソースURLの定義
## 実況天気図（UTC=00,06,12,18）
URL_ASAS=https://www.jma.go.jp/jp/g3/images/asia/pdf/asas.pdf
URL_ASAS_COLOR=https://www.data.jma.go.jp/fcd/yoho/data/wxchart/quick/ASAS_COLOR.pdf

## 予想天気図（UTC=00,12）
URL_FSAS24=https://www.jma.go.jp/jp/g3/images/24h/pdf/fsas24.pdf
URL_FSAS48=https://www.jma.go.jp/jp/g3/images/48h/pdf/fsas48.pdf

## 高層天気図（UTC=00,12）
URL_AUPA20=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupa20_${UTC_HOUR_12}.pdf
URL_AUPN30=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupn30_${UTC_HOUR_12}.pdf
URL_AUPQ78=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupq78_${UTC_HOUR_12}.pdf
URL_AXFE578=https://www.jma.go.jp/jp/metcht/pdf/kosou/axfe578_${UTC_HOUR_12}.pdf
URL_AXJP140=https://www.jma.go.jp/jp/metcht/pdf/kosou/axjp140_${UTC_HOUR_12}.pdf
URL_AUPA25=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupa25_${UTC_HOUR_12}.pdf
URL_AUPQ35=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupq35_${UTC_HOUR_12}.pdf

## 高層天気図（UTC=12）
URL_AUXN50=https://www.jma.go.jp/jp/metcht/pdf/kosou/auxn50_${UTC_HOUR_12}.pdf
URL_FEAS50=https://www.jma.go.jp/jp/metcht/pdf/kosou/feas50_${UTC_HOUR_12}.pdf

## 波浪解析図（UTC=00,12）
URL_AWJP=https://www.data.jma.go.jp/gmd/waveinf/data/chart/awjp${UTC_DATE_12:2}.pdf
URL_AWJP_COL=https://www.data.jma.go.jp/gmd/waveinf/data/chart/awjp${UTC_DATE_12:2}_col.pdf

## 波浪予想図（UTC=00,12）
URL_FWJP=https://www.data.jma.go.jp/gmd/waveinf/data/chart/fwjp${UTC_DATE_12:2}.pdf
URL_FWJP_COL=https://www.data.jma.go.jp/gmd/waveinf/data/chart/fwjp${UTC_DATE_12:2}_col.pdf

## 短期予報解説資料（JST=05,17）
URL_TANKI=https://www.data.jma.go.jp/fcd/yoho/data/jishin/kaisetsu_tanki_latest.pdf

## 週間予報解説資料（JST=11）
URL_SHUKAN=https://www.data.jma.go.jp/fcd/yoho/data/jishin/kaisetsu_shukan_latest.pdf

## 地上観測（1h毎）
URL_PREALL=https://www.data.jma.go.jp/obd/stats/data/mdrr/pre_rct/alltable/preall00_rct.csv
URL_MXWSP=https://www.data.jma.go.jp/obd/stats/data/mdrr/wind_rct/alltable/mxwsp00_rct.csv
URL_GUST=https://www.data.jma.go.jp/obd/stats/data/mdrr/wind_rct/alltable/gust00_rct.csv
URL_MXTEM=https://www.data.jma.go.jp/obd/stats/data/mdrr/tem_rct/alltable/mxtemsadext00_rct.csv
URL_MNTEM=https://www.data.jma.go.jp/obd/stats/data/mdrr/tem_rct/alltable/mntemsadext00_rct.csv

## 気象通報（JST=18）
URL_JIKKYO=https://www.data.jma.go.jp/fcd/yoho/gyogyou/jikkyo12.txt
URL_TSUHO=https://www.data.jma.go.jp/fcd/yoho/gyogyou/tsuho12.txt

## 防災情報（1h毎、随時）
URL_REGULAR=http://www.data.jma.go.jp/developer/xml/feed/regular.xml
URL_EXTRA=http://www.data.jma.go.jp/developer/xml/feed/extra.xml
URL_EQVOL=http://www.data.jma.go.jp/developer/xml/feed/eqvol.xml


echo "##################################################"
##### 気象庁データの取得
## PDFファイル（実況図:履歴の保存）
for url in $URL_ASAS_COLOR $URL_AWJP_COL $URL_AUPQ78 $URL_AUPQ35 $URL_TANKI $URL_SHUKAN; do
#for url in $URL_ASAS_COLOR; do
  base=$(basename $url)
  base=${base%.*}
  base=${base/${UTC_DATE_12:2}/}
  base=${base%_*}
  ext=${url##*.}
  echo "GET" $base $ext
  src=${JMA_PATH}/pdf/${UTC_DATE_12}_${base}.pdf
  png=${JMA_PATH}/png/${UTC_DATE_12}_${base}
  dst=${JMA_PATH}/latest/${base}.png
  $DEBUG wget $url -O $src
  if [ -s $src ]; then
    $DEBUG pdftoppm $src -png $png -singlefile ${PNG_OPTS}
    $DEBUG cp ${png}.png $dst
  fi
done

## PDFファイル（予想図：上書き保存）
for url in $URL_FSAS24 $URL_FSAS48 $URL_FWJP_COL; do
  base=$(basename $url)
  base=${base%.*}
  base=${base/${UTC_DATE_12:2}/}
  base=${base%_*}
  ext=${url##*.}
  echo "GET" $base $ext
  src=${JMA_PATH}/latest/${base}.pdf
  png=${JMA_PATH}/latest/${base}
  $DEBUG wget $url -O $src
  if [ -s $src ]; then
    $DEBUG pdftoppm $src -png $png -singlefile ${PNG_OPTS}
  fi
done

## TXT/XMLファイル（その他：上書き保存）
for url in $URL_JIKKYO $URL_TSUHO $URL_REGULAR $URL_EXTRA $URL_EQVOL; do
  ext=${url##*.}
  base=$(basename $url)
  base=${base%.*}
  echo "GET" $base $ext
  src=${JMA_PATH}/latest/${base}.${ext}
  $DEBUG wget $url -O $src
done



echo "##################################################"
echo "LEAVE:" $(date)
exit 0

