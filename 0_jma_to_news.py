# -*- coding: utf-8 -*-
import numpy  as np
import pandas as pd
import os, sys, glob, time
from datetime import datetime,timedelta
import sqlite3
import feedparser

##
print("enter:",sys.argv)
NOW = datetime.now()
print("now:",NOW)
##################################################
## パラメータ
ENCODING = "cp932"
JMA_FILE = "./pub/news.sqlite3"	# SQLiteファイル名
JMA_NEWS = "jma_news"	# SQLiteテーブル名
JMA_DAYS = 7	# ニュース保持期間（日）
JMA_HOUR = 2	# ニュース表示期間（時）
JMA_MAX = 200	# ニュース表示件数
JMA_HTML = "./pub/news.html"

## 高頻度フィード
XML_REGUL = "http://www.data.jma.go.jp/developer/xml/feed/regular.xml"
XML_EXTRA = "http://www.data.jma.go.jp/developer/xml/feed/extra.xml"
XML_EQVOL = "http://www.data.jma.go.jp/developer/xml/feed/eqvol.xml"
XML_OTHER = "http://www.data.jma.go.jp/developer/xml/feed/other.xml"

## 長期フィード
XML_REGUL_ = "http://www.data.jma.go.jp/developer/xml/feed/regular_l.xml"
XML_EXTRA_ = "http://www.data.jma.go.jp/developer/xml/feed/extra_l.xml"
XML_EQVOL_ = "http://www.data.jma.go.jp/developer/xml/feed/eqvol_l.xml"
XML_OTHER_ = "http://www.data.jma.go.jp/developer/xml/feed/other_l.xml"

## 購読XMLリスト
XML_SUBSCRIBE = [XML_REGUL,XML_EXTRA,XML_EQVOL,XML_OTHER]

## RDBテーブル定義
SQL_INITIALIZE = [
  "create table if not exists {0} (utc text, author text, title text, href text, content text, feed text, primary key(utc,author,title))".format(JMA_NEWS),
  "create index if not exists utc_index on {0}(utc)".format(JMA_NEWS),
  "delete from {0} where datetime(utc) <= datetime('now','-{1} days')".format(JMA_NEWS,JMA_DAYS),
]


##################################################
conn = sqlite3.connect(JMA_FILE)

## RDBスキーマ登録
for sql in SQL_INITIALIZE: conn.execute(sql)

## XMLデータ登録
for xml in XML_SUBSCRIBE:
  feed = os.path.basename(xml).split(".")[0]
  print(sys.argv[0],xml)
  jma_news = feedparser.parse(xml)
  for e in jma_news["entries"]:
    ## 項目
    title = e["title"]
    link = e["link"]
    updated = e["updated"]
    utc = datetime.strptime(updated,"%Y-%m-%dT%H:%M:%SZ")
    jst = utc + timedelta(hours=9)
    author = e["author"]
    href = e["links"][0]["href"]
    content = e["content"][0]["value"]
    summary = e["summary"]
    ##
    print(jst,author,title)
    #print(summary)
    sql = "insert or replace into {6} values ('{0}','{1}','{2}','{3}','{4}','{5}')".format(utc,author,title,href,content,feed, JMA_NEWS)
    conn.execute(sql)
    ##
conn.commit()

## 直近ニュース作成
#sql = "select datetime(utc,'localtime') jst,author,title,content,feed,href from {0} where datetime(utc) >= datetime('now','-{1} hours') order by jst desc limit {2}".format(JMA_NEWS,JMA_HOUR,JMA_MAX)
sql = "select datetime(utc,'localtime') jst,author,content from {0} where datetime(utc) >= datetime('now','-{1} hours') order by jst desc limit {2}".format(JMA_NEWS,JMA_HOUR,JMA_MAX)
df = pd.read_sql_query(sql, conn)
##
conn.close()


##################################################
## HTMLファイル生成
FORMATTERS = { 'href': lambda x: "<a href='{0}'>xml</a>".format(x), }
pd.set_option('display.max_colwidth', -1)
html = '''
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<title>JMA XML</title>
<link rel="icon" type="image/png" href="./favicon/icon-192x192.png"/>
<link rel="apple-touch-icon" type="image/png" href="./favicon/apple-touch-icon-180x180.png"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css"/>
<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
<script>
$(document).ready( function () { $('.dataframe').DataTable({ "scrollX":false, "stateSave":true, }); } );
setTimeout( function() { location.reload(); }, 15*60*1000);
</script>
</head>
<body>
'''
#html += "<h2>気象庁 ({0:%H:%M}〜{1:%H:%M})</h2>\n".format(NOW-timedelta(hours=JMA_HOUR), NOW)
html += df.to_html(formatters=FORMATTERS,escape=False,index=False,border=0,classes="compact row-border stripe")
html = html.replace("\\n","<br>")
html += '''
</body>
</html>
'''
with open(JMA_HTML,'w') as f:
  f.write(html)
  f.close()


##################################################
print("leave:",sys.argv)
sys.exit(0)
