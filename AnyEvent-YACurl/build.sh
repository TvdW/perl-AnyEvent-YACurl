set -eo pipefail

rm -rf nghttp2-1.35.1 nghttp2-lib nghttp2-src
rm -rf curl-7.63.0 curl-src curl-lib

tar -xf nghttp2-1.35.1.tar.gz
mv nghttp2-1.35.1 nghttp2-src

tar -xf curl-7.63.0.tar.gz
mv curl-7.63.0/ curl-src

pushd curl-src/docs/libcurl
perl symbols.pl > symbols.h
popd

perl sync-symbols.pl

cp MANIFEST.pre MANIFEST
find curl-src -type f >> MANIFEST
find nghttp2-src -type f >> MANIFEST
