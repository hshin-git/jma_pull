#!/bin/sh
ln -s ../info .
ln -s ../pdf .
ln -s ../png .
ln -s ../latest .
python -m http.server 8000
#google-chrome http://localhost:8000/
