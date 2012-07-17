package Log::Any::Adapter::Stderr;
use strict;
use warnings;
use base qw(Log::Any::Adapter::FileScreenBase);

__PACKAGE__->make_logging_methods(
    sub {
        my ( $self, $text ) = @_;
        my $msg = sprintf( "[%s] %s\n", scalar(localtime), $text );
        print STDERR $msg;
    }
);

1;
