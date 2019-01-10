use v5.010;
use strict;
use warnings;

CONSTANTS: {
    open my $fh, '<', 'curl-src/docs/libcurl/symbols.h' or die $!;
    open my $constants, '>', 'constants.inc' or die $!;

    my %words;
    while (<$fh>) {
        my ($word, $what)= /\s(CURL\S+)_(FIRST|LAST)\s/;
        next unless $word;
        $words{$what}{$word}= 1;
    }

    for my $word (sort keys %{$words{FIRST}}) {
        next if $word =~ /
            CURL_STRICTER
            | CURL_DID_MEMORY_FUNC_TYPEDEFS
        /x;
        unless ($words{LAST}{$word}) {
            print $constants <<EOC;
        hv_stores(the_hv, "$word", newSViv($word));
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
        HTTPHEADER
        PROXYHEADER
        HTTP200ALIASES
        MAIL_RCPT
        POSTQUOTE
        PREQUOTE
        QUOTE
        RESOLVE
        TELNETOPTIONS
        HEADERDATA
        HEADERFUNCTION
        READDATA
        READFUNCTION
        POSTFIELDSIZE
        POSTFIELDSIZE_LARGE
        COPYPOSTFIELDS
        POSTFIELDS
        CONNECT_TO
        MIMEPOST
    ),
    # Don't want: probably not useful
    qw(
        STDERR
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
        DEBUGDATA
        DEBUGFUNCTION
        FNMATCH_DATA
        FNMATCH_FUNCTION
        PROGRESSDATA
        PROGRESSFUNCTION
        SSH_KEYDATA
        SSH_KEYFUNCTION
        STREAM_DEPENDS
        STREAM_DEPENDS_E
        XFERINFOFUNCTION
        CHUNK_BGN_FUNCTION
        CHUNK_DATA
        CHUNK_END_FUNCTION
        TRAILERFUNCTION
        TRAILERDATA
    );

    open my $fh, '<', 'curl-src/include/curl/curl.h';
    open my $strings, '>', 'curlopt-str.inc';
    open my $longs, '>', 'curlopt-long.inc';
    open my $offt, '>', 'curlopt-off-t.inc';

    while (<$fh>) {
        my ($option, $type, $number)= /^\s*CINIT\( (\S+), \s* (\S+), \s (\d+) \)/x;
        next unless $option;
        next if $curlopt_skip{$option};

        if ($type eq 'STRINGPOINT') {
            print $strings <<EOC;
    case CURLOPT_$option:
EOC
        } elsif ($type eq 'LONG') {
            print $longs <<EOC
    case CURLOPT_$option:
EOC
        } elsif ($type eq 'OFF_T') {
            print $offt <<EOC
    case CURLOPT_$option:
EOC
        } else {
            print STDERR "Ignoring unknown option CURLOPT_$option\n";
        }
    }
}
