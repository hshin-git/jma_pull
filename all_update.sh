#!/bin/bash
echo "##################################################"
echo "ENTER:" $(date)

#DEBUG=echo

PYTHON=/home/shin/anaconda3/bin/python
JMA_PATH=~/Documents/python/jma_pull
#PYTHON=/home/ubuntu/anaconda3/bin/python
#JMA_PATH=/home/ubuntu/jma_pull

for x in pdf png txt xml latest; do
  mkdir -p ${JMA_PATH}/$x
done

#PDF2PNG_OPT="-scale-to 1240"


echo "##################################################"
##### 年月日時の計算（毎時15分頃に起動）
JST_DATE=$(date "+%Y%m%d%H")
UTC_DATE=$(date "+%Y%m%d%H" -d "-9 hours")
#JST_DATE="2020053108"
#UTC_DATE="2020053023"

JST_HOUR=${JST_DATE:8}
UTC_HOUR=${UTC_DATE:8}
echo "JST" $JST_DATE $JST_HOUR
echo "UTC" $UTC_DATE $UTC_HOUR

## タイムスタンプの調整（6h毎、12h毎へ丸める）
UTC_HOUR_06=$(printf "%02d" $(expr $(expr $UTC_HOUR / 6) "*" 6))
UTC_HOUR_12=$(printf "%02d" $(expr $(expr $UTC_HOUR / 12) "*" 12))

UTC_DATE_00=${UTC_DATE:0:8}00
UTC_DATE_06=${UTC_DATE:0:8}${UTC_HOUR_06}
UTC_DATE_12=${UTC_DATE:0:8}${UTC_HOUR_12}

echo "UTC_00" $UTC_DATE_00
echo "UTC_06" $UTC_DATE_06 $UTC_HOUR_06
echo "UTC_12" $UTC_DATE_12 $UTC_HOUR_12


#################### リソースURLの定義
## 実況天気図（UTC=00,06,12,18）
PDF_ASAS=https://www.jma.go.jp/jp/g3/images/asia/pdf/asas.pdf
PDF_ASAS_COLOR=https://www.data.jma.go.jp/fcd/yoho/data/wxchart/quick/ASAS_COLOR.pdf
PNG_ASJP=https://www.jma.go.jp/jp/g3/images/jp_c/${UTC_DATE_06:2}.png

## 予想天気図（UTC=00,12）
PDF_FSAS24=https://www.jma.go.jp/jp/g3/images/24h/pdf/fsas24.pdf
PDF_FSAS48=https://www.jma.go.jp/jp/g3/images/48h/pdf/fsas48.pdf
PNG_FSJP24=https://www.jma.go.jp/jp/g3/images/jp_c/24h/${JST_DATE_06:2}.png
PNG_FSJP48=https://www.jma.go.jp/jp/g3/images/jp_c/48h/${JST_DATE_06:2}.png

## 高層天気図（UTC=00,12）
PDF_AUPA20=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupa20_${UTC_HOUR_12}.pdf
PDF_AUPN30=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupn30_${UTC_HOUR_12}.pdf
PDF_AUPQ78=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupq78_${UTC_HOUR_12}.pdf
PDF_AXFE578=https://www.jma.go.jp/jp/metcht/pdf/kosou/axfe578_${UTC_HOUR_12}.pdf
PDF_AXJP140=https://www.jma.go.jp/jp/metcht/pdf/kosou/axjp140_${UTC_HOUR_12}.pdf
PDF_AUPA25=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupa25_${UTC_HOUR_12}.pdf
PDF_AUPQ35=https://www.jma.go.jp/jp/metcht/pdf/kosou/aupq35_${UTC_HOUR_12}.pdf

## 高層天気図（UTC=12）
PDF_AUXN50=https://www.jma.go.jp/jp/metcht/pdf/kosou/auxn50_${UTC_HOUR_12}.pdf
PDF_FEAS50=https://www.jma.go.jp/jp/metcht/pdf/kosou/feas50_${UTC_HOUR_12}.pdf

## 波浪解析図（UTC=00,12）
PDF_AWJP=https://www.data.jma.go.jp/gmd/waveinf/data/chart/awjp${UTC_DATE_12:2}.pdf
PDF_AWJP_COL=https://www.data.jma.go.jp/gmd/waveinf/data/chart/awjp${UTC_DATE_12:2}_col.pdf
PNG_AWJP=https://www.data.jma.go.jp/gmd/waveinf/data/chart/awjp${UTC_DATE_12:2}.png
PNG_AWPN=https://www.data.jma.go.jp/gmd/waveinf/data/chart/awpn${UTC_DATE_12:2}.png

## 波浪予想図（UTC=00,12）
PDF_FWJP=https://www.data.jma.go.jp/gmd/waveinf/data/chart/fwjp${UTC_DATE_12:2}.pdf
PDF_FWJP_COL=https://www.data.jma.go.jp/gmd/waveinf/data/chart/fwjp${UTC_DATE_12:2}_col.pdf
PNG_FWJP=https://www.data.jma.go.jp/gmd/waveinf/data/chart/fwjp${UTC_DATE_12:2}.png
PNG_FWPN=https://www.data.jma.go.jp/gmd/waveinf/data/chart/fwpn${UTC_DATE_12:2}.png

## 長期予報（JST=15）
PNG_2WEEK=https://www.data.jma.go.jp/gmd/cpd/twoweek/image_issue/Latest/map.png
PNG_1MONTH=https://www.jma.go.jp/jp/longfcst/imgs/1/temp/temp-00.png
PNG_3MONTH=https://www.jma.go.jp/jp/longfcst/imgs/3/temp/temp-10.png

## 航空気象
PNG_FBJP=https://www.data.jma.go.jp/airinfo/data/pict/fbjp/fbjp.png

## 短期予報解説資料（JST=05,17）
PDF_TANKI=https://www.data.jma.go.jp/fcd/yoho/data/jishin/kaisetsu_tanki_latest.pdf

## 週間予報解説資料（JST=11）
PDF_SHUKAN=https://www.data.jma.go.jp/fcd/yoho/data/jishin/kaisetsu_shukan_latest.pdf

## 地上観測（1h毎）
CSV_PREALL=https://www.data.jma.go.jp/obd/stats/data/mdrr/pre_rct/alltable/preall00_rct.csv
CSV_MXWSP=https://www.data.jma.go.jp/obd/stats/data/mdrr/wind_rct/alltable/mxwsp00_rct.csv
CSV_GUST=https://www.data.jma.go.jp/obd/stats/data/mdrr/wind_rct/alltable/gust00_rct.csv
CSV_MXTEM=https://www.data.jma.go.jp/obd/stats/data/mdrr/tem_rct/alltable/mxtemsadext00_rct.csv
CSV_MNTEM=https://www.data.jma.go.jp/obd/stats/data/mdrr/tem_rct/alltable/mntemsadext00_rct.csv

## 気象通報（JST=18）
TXT_JIKKYO=https://www.data.jma.go.jp/fcd/yoho/gyogyou/jikkyo12.txt
TXT_TSUHO=https://www.data.jma.go.jp/fcd/yoho/gyogyou/tsuho12.txt

## 防災情報（1h毎、随時）
XML_REGULAR=http://www.data.jma.go.jp/developer/xml/feed/regular.xml
XML_EXTRA=http://www.data.jma.go.jp/developer/xml/feed/extra.xml
XML_EQVOL=http://www.data.jma.go.jp/developer/xml/feed/eqvol.xml

## 気象衛星画像（10分毎）
PNG_GMS_IR=https://www.jma.go.jp/jp/gms/imgs/0/infrared/1/${JST_DATE}00-00.png
PNG_GMS_VS=https://www.jma.go.jp/jp/gms/imgs/0/visible/1/${JST_DATE}00-00.png
PNG_GMS_WV=https://www.jma.go.jp/jp/gms/imgs/0/watervapor/1/${JST_DATE}00-00.png
PNG_GMF_IR_COL=https://www.jma.go.jp/jp/gms/imgs_c/0/infrared/1/${JST_DATE}00-00.png
PNG_GMS_VS_COL=https://www.jma.go.jp/jp/gms/imgs_c/0/visible/1/${JST_DATE}00-00.png
PNG_GMS_WV_COL=https://www.jma.go.jp/jp/gms/imgs_c/0/watervapor/1/${JST_DATE}00-00.png

## 気象レーダ画像（10分毎）
PNG_RADAR_JAPAN=https://www.jma.go.jp/jp/radnowc/imgs/radar/000/${JST_DATE}00-00.png
PNG_RADAR_KANTO=https://www.jma.go.jp/jp/radnowc/imgs/radar/206/${JST_DATE}00-00.png
PNG_RADAR_TOKAI=https://www.jma.go.jp/jp/radnowc/imgs/radar/210/${JST_DATE}00-00.png
PNG_RADAR_KINKI=https://www.jma.go.jp/jp/radnowc/imgs/radar/211/${JST_DATE}00-00.png
PNG_RADAR_CHUGOKU=https://www.jma.go.jp/jp/radnowc/imgs/radar/212/${JST_DATE}00-00.png
PNG_RADAR_SHIKOKU=https://www.jma.go.jp/jp/radnowc/imgs/radar/213/${JST_DATE}00-00.png
PNG_THUNDER_JAPAN=https://www.jma.go.jp/jp/radnowc/imgs/thunder/000/${JST_DATE}00-00.png
PNG_THUNDER_KANTO=https://www.jma.go.jp/jp/radnowc/imgs/thunder/206/${JST_DATE}00-00.png

## JTWC
TXT_JTWC=https://www.metoc.navy.mil/jtwc/products/abpwweb.txt
JPG_JTWC=https://www.metoc.navy.mil/jtwc/products/abpwsair.jpg


#################### リソース取得の関数
function GET_URL() {
  ## url=WGET対象のURL
  ## tid=履歴の保存有無（なし:latestへ上書き保存、あり:拡張子フォルダへ保存）
  url=$1
  tid=$2
  ## URL文字列をファイル名と拡張子へ
  base=$(basename $url)
  base=${base%.*}
  base=${base/${JST_DATE}/}
  base=${base/${UTC_DATE_12:2}/}
  base=${base%_*}
  if [ $base = "00-00" ]; then
    #衛星画像、レーダ画像の命名
    dn1=$(dirname $url)
    dn2=$(dirname $dn1)
    base=$(basename $dn2)$(basename $dn1)
  fi
  ext=${url##*.}
  ## リモートurlからローカルsrcへ保存
  echo "GET_URL" $base $ext $tid
  if [ $tid ]; then
    src=${JMA_PATH}/$ext/${tid}_${base}.${ext}
  else
    src=${JMA_PATH}/latest/${base}.${ext}
  fi
  $DEBUG wget $url -O $src --quiet
  dst=${JMA_PATH}/latest/${base}
  ## WGET成功ならPDF変換/dstへ複製
  if [ -s $src ]; then
    if [ $ext = "pdf" ]; then
      $DEBUG pdftoppm $src -png $dst -singlefile ${PDF2PNG_OPT}
    else
      if [ $tid ]; then
        $DEBUG cp $src ${dst}.${ext}
      fi
    fi
  else
    $DEBUG echo not found $url
  fi
}

#for url in $TXT_JIKKYO $PDF_ASAS_COLOR $PNG_RADAR_JAPAN $PNG_GMS_IR; do
#  GET_URL $url
#done
#exit 0


echo "##################################################"
##### 1h毎 #####
## PNG/JPGファイル（衛星画像、レーダー画像）
for url in $PNG_RADAR_KANTO $PNG_RADAR_JAPAN $PNG_THUNDER_JAPAN $PNG_GMS_IR $PNG_GMS_VS $PNG_GMS_WV; do
  GET_URL $url
done
## TXT/XMLファイル（気象通報、警報・注意報）
#for url in $XML_REGULAR $XML_EXTRA $XML_EQVOL; do
#  GET_URL $url
#done
## XMLファイル（防災情報）
if [ $# -ge 1 ]; then
  $DEBUG $PYTHON 0_jma_to_news.py
  echo rapid update
  echo "LEAVE:" $(date)
  exit 0
fi
##### 1h毎 #####


echo "##################################################"
##### 12h毎 #####
if [ $JST_HOUR = "02" -o $JST_HOUR = "14" ]; then
  ## PDFファイル（実況天気図）
  for url in $PDF_ASAS_COLOR $PDF_AWJP_COL; do
    GET_URL $url $UTC_DATE_12
  done
fi
if [ $JST_HOUR = "06" -o $JST_HOUR = "18" ]; then
  ## PDFファイル（予想天気図）
  for url in $PDF_FSAS24 $PDF_FSAS48 $PDF_FWJP_COL; do
    GET_URL $url
  done
fi
##### 12h毎 #####


echo "##################################################"
##### 24h毎 #####
if [ $JST_HOUR = "06" ]; then
  ## TXT/PDFファイル（気象通報、解説資料）
  for url in $TXT_JIKKYO $TXT_TSUHO $PDF_TANKI $PDF_SHUKAN; do
    GET_URL $url $UTC_DATE_12
  done
fi
if [ $JST_HOUR = "15" ]; then
  ## PNGファイル（長期予報）
  for url in $PNG_2WEEK $PNG_1MONTH $PNG_3MONTH; do
    GET_URL $url
  done
fi
if [ $JST_HOUR = "09" -o $JST_HOUR = "21" ]; then
  ## PNG/JPGファイル（衛星画像）
  for url in $PNG_GMS_IR $PNG_GMS_VS $PNG_GMS_WV; do
    GET_URL $url $UTC_DATE_12
  done
fi
##### 24h毎 #####


echo "##################################################"
echo "LEAVE:" $(date)
exit 0
