set -e

CURLVER=7.74.0
[ -f curl-$CURLVER.tar.gz ] || curl --output curl-$CURLVER.tar.gz https://curl.se/download/curl-$CURLVER.tar.gz
tar -xf curl-$CURLVER.tar.gz
mv curl-$CURLVER curl-src

cd curl-src/docs/libcurl
perl symbols.pl > ../../../libcurl-symbols.h
cd ../../..

perl sync-symbols.pl
rm -rf curl-src
