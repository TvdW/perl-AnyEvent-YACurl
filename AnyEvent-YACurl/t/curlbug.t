use v5.14;
use warnings;
use AnyEvent::YACurl qw/:constants/;

my $CLIENT = AnyEvent::YACurl->new({
    CURLMOPT_PIPELINING => CURLPIPE_MULTIPLEX,
    CURLMOPT_MAX_HOST_CONNECTIONS => 4,
    CURLMOPT_MAXCONNECTS => 128,
});

my @urls= qw@
    https://178.128.138.192
    https://178.128.138.192
@;

for (1..50) {
    my @requests;
    for my $url (@urls) {
        my $cv= AE::cv;
        my $request= {
            CURLOPT_URL => $url,
            CURLOPT_PIPEWAIT => 1,
            CURLOPT_SSL_VERIFYHOST => 0,
            CURLOPT_SSL_VERIFYPEER => 0,
	    #CURLOPT_VERBOSE => 1,
        };

        $CLIENT->request($cv, $request);
        push @requests, $cv;
    }
    $_->recv for @requests;

    say STDERR "" for 1..4;
}
