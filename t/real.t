#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use SunRiser;
use SunRiser::Config;
use SunRiser::Publisher;
use SunRiser::Test;

use FindBin;
use lib $FindBin::Dir."/lib";

SKIP: {
  skip "No SUNRISER_TEST_REAL environment variable set", 1 unless defined $ENV{SUNRISER_TEST_REAL};
  my $publisher = SunRiser::Publisher->new( config => SunRiser::Config->new );
  my $ts = SunRiser::Test->new( pub => $publisher, remote => 'http://'.$ENV{SUNRISER_TEST_REAL} );
  my $sr = SunRiser->new( host => $ENV{SUNRISER_TEST_REAL} );
  my $t = $ts->t;

  my $r = $t->get('/');
  ok($r->is_success,'Successful access to /');

  $r = $t->execute_request($sr->mp_request( PUT => '', {
    testvalue => undef
  } ));

  ok($r->is_success,'Successful PUT request setting testvalue to undefined');

  $r = $t->execute_request($sr->mp_request( POST => '', ['testvalue']));

  ok($r->is_success,'Successful POST request for testvalue after set undefined');

  my $mp = $sr->res_mp_body($r);
  delete $mp->{time};

  is_deeply($mp,{ testvalue => undef },'Data correct on POST request for testvalue after set undefined');

  $r = $t->execute_request($sr->mp_request( PUT => '', {
    testvalue => 1
  } ));

  ok($r->is_success,'Successful PUT request setting testvalue to 1');

  $r = $t->execute_request($sr->mp_request( POST => '', ['testvalue']));

  ok($r->is_success,'Successful POST request for testvalue after set 1');

  $mp = $sr->res_mp_body($r);
  delete $mp->{time};

  is_deeply($mp,{ testvalue => 1 },'Data correct on POST request for testvalue after set 1');

}

done_testing;
