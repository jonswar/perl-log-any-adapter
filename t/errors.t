#!perl
use Test::More tests => 3;
use Log::Any;
use strict;
use warnings;

eval { Log::Any->set_adapter('Blah') };
like($@, qr{Can't locate Log/Any/Adapter/Blah}, "adapter = Blah");
eval { Log::Any->set_adapter('+My::Adapter::Blah') };
like($@, qr{Can't locate My/Adapter/Blah}, "adapter = +My::Adapter::Blah");
eval { Log::Any->set_adapter('') };
like($@, qr{expected adapter name}, "adapter = ''");
