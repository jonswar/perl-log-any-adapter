package Log::Any::Adapter::Stdout;
use strict;
use warnings;
use base qw(Log::Any::Adapter::FileScreenBase);

__PACKAGE__->make_logging_methods(
    sub {
        my ( $self, $text ) = @_;
        my $msg = sprintf( "[%s] %s\n", scalar(localtime), $text );
        print $msg;
    }
);

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Stdout

=head1 SYNOPSIS

    use Log::Any::Adapter ('Stdout');

    # or

    use Log::Any::Adapter;
    ...
    Log::Any::Adapter->set('Stdout');

=head1 DESCRIPTION

This simple built-in L<Log::Any|Log::Any> adapter logs each message to STDOUT,
with a datestamp prefix. Category and log level are ignored.

