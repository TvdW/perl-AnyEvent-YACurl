set -eo pipefail

rm -rf nghttp2-1.36.0 nghttp2-lib nghttp2-src
rm -rf curl-7.64.0 curl-src curl-lib
rm -rf c-ares-1.15.0 c-ares-src c-ares-lib
rm -rf libbrotli-0.1.0 libbrotli-src libbrotli-lib

tar -xf nghttp2-1.36.0.tar.gz
mv nghttp2-1.36.0 nghttp2-src

tar -xf curl-7.64.0.tar.gz
mv curl-7.64.0 curl-src

tar -xf c-ares-1.15.0.tar.gz
mv c-ares-1.15.0 c-ares-src

tar -xf libbrotli-0.1.0.tar.gz
mv libbrotli-0.1.0 libbrotli-src

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
