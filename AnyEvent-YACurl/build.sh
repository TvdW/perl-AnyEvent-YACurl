set -eo pipefail

CURLVER=7.68.0
CARESVER=1.15.0
NGHTTP2VER=1.40.0
BROTLIVER=0.1.0

rm -rf nghttp2-$NGHTTP2VER nghttp2-lib nghttp2-src
rm -rf curl-$CURLVER curl-src curl-lib
rm -rf c-ares-$CARESVER c-ares-src c-ares-lib
rm -rf libbrotli-$BROTLIVER libbrotli-src libbrotli-lib

tar -xf nghttp2-$NGHTTP2VER.tar.gz
mv nghttp2-$NGHTTP2VER nghttp2-src

tar -xf curl-$CURLVER.tar.gz
mv curl-$CURLVER curl-src

tar -xf c-ares-$CARESVER.tar.gz
mv c-ares-$CARESVER c-ares-src

tar -xf libbrotli-$BROTLIVER.tar.gz
mv libbrotli-$BROTLIVER libbrotli-src

for file in patch/*; do
    patch -p1 < $file
done

pushd curl-src/docs/libcurl
perl symbols.pl > symbols.h
popd

perl sync-symbols.pl

# Clean stuff we don't need if they cause trouble
rm -rf nghttp2-src/third-party/mruby
find curl-src nghttp2-src -name \*.pm -delete
find curl-src nghttp2-src -name \*.rb -delete
find curl-src nghttp2-src -name \*.py -delete

cp MANIFEST.pre MANIFEST
find curl-src -type f >> MANIFEST
find nghttp2-src -type f >> MANIFEST
find c-ares-src -type f >> MANIFEST
find libbrotli-src -type f >> MANIFEST
