use v5.010;
use strict;
use warnings;

CONSTANTS: {
    open my $fh, '<', 'libcurl-symbols.h' or die $!;
    open my $constants, '>', 'constants.inc' or die $!;

    my %words;
    while (<$fh>) {
        my ($word, $what)= /\s(CURL\S+)_(FIRST|LAST)\s/;
        next unless $word;
        $words{$what}{$word}= 1;
    }

    for my $word (sort keys %{$words{FIRST}}) {
        next if $word =~ /\A(?:
            CURL_STRICTER
            | CURL_DID_MEMORY_FUNC_TYPEDEFS
            | CURLOPT
            | CURL_WIN32
        )\z/x;
        unless ($words{LAST}{$word}) {
            print $constants <<EOC;
#if LIBCURL_HAS($word)
        hv_stores(the_hv, "$word", newSViv($word));
#endif
EOC
        }
    }
}

CURLOPT: {
    my %curlopt_skip= map { $_ => 1 }
    # Implemented directly / privately
    qw(
        PRIVATE
        WRITEFUNCTION
        WRITEDATA
        ERRORBUFFER
        HEADERDATA
        HEADERFUNCTION
        READDATA
        READFUNCTION
        POSTFIELDSIZE
        POSTFIELDSIZE_LARGE
        COPYPOSTFIELDS
        POSTFIELDS
        MIMEPOST
        DEBUGDATA
        DEBUGFUNCTION
        STDERR
        TRAILERFUNCTION
        TRAILERDATA
    ),
    # Don't want: probably not useful
    qw(
        SHARE
        CLOSESOCKETDATA
        CLOSESOCKETFUNCTION
        IOCTLDATA
        IOCTLFUNCTION
        SSL_CTX_DATA
        SSL_CTX_FUNCTION
        INTERLEAVEDATA
        INTERLEAVEFUNCTION
        OPENSOCKETDATA
        OPENSOCKETFUNCTION
        RESOLVER_START_DATA
        RESOLVER_START_FUNCTION
        CONV_FROM_NETWORK_FUNCTION
        CONV_FROM_UTF8_FUNCTION
        CONV_TO_NETWORK_FUNCTION
        SEEKDATA
        SEEKFUNCTION
        SOCKOPTDATA
        SOCKOPTFUNCTION
        OBSOLETE40
        HTTPPOST
    ),
    # Want, just not done yet
    qw(
        CURLU
        FNMATCH_DATA
        FNMATCH_FUNCTION
        PROGRESSDATA
        PROGRESSFUNCTION
        SSH_KEYDATA
        SSH_KEYFUNCTION
        STREAM_DEPENDS
        STREAM_DEPENDS_E
        XFERINFOFUNCTION
        XFERINFODATA
        CHUNK_BGN_FUNCTION
        CHUNK_DATA
        CHUNK_END_FUNCTION
    );

    open my $fh, '<', 'curl-src/include/curl/curl.h';
    open my $strings, '>', 'curlopt-str.inc';
    open my $longs, '>', 'curlopt-long.inc';
    open my $offt, '>', 'curlopt-off-t.inc';
    open my $slists, '>', 'curlopt-slist.inc';
    open my $blobs, '>', 'curlopt-blob.inc';

    while (<$fh>) {
        my ($option, $type, $number)= /^\s*CURLOPT\( CURLOPT_(\S+), \s* CURLOPTTYPE_(\S+), \s (\d+) \)/x;
        next unless $option;
        next if $curlopt_skip{$option};

        if ($type eq 'STRINGPOINT') {
            print $strings <<EOC;
#if LIBCURL_HAS(CURLOPT_$option)
    case CURLOPT_$option:
#endif
EOC
        } elsif ($type eq 'LONG' or $type eq 'VALUES') {
            print $longs <<EOC
#if LIBCURL_HAS(CURLOPT_$option)
    case CURLOPT_$option:
#endif
EOC
        } elsif ($type eq 'OFF_T') {
            print $offt <<EOC
#if LIBCURL_HAS(CURLOPT_$option)
    case CURLOPT_$option:
#endif
EOC
        } elsif ($type eq 'SLISTPOINT') {
            print $slists <<EOC
#if LIBCURL_HAS(CURLOPT_$option)
    case CURLOPT_$option:
#endif
EOC
        } elsif ($type eq 'BLOB') {
            print $blobs <<EOC
#if LIBCURL_HAS(CURLOPT_$option)
    case CURLOPT_$option:
#endif
EOC
        } else {
            print STDERR "Ignoring unknown option CURLOPT_$option\n";
        }
    }
}
