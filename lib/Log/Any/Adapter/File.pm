package Log::Any::Adapter::File;
use IO::File;
use strict;
use warnings;
use base qw(Log::Any::Adapter::FileScreenBase);

sub new {
    my $category = pop;
    pop;
    my ( $class, $file, $layer ) = @_;
    return $class->SUPER::new( file => $file, layer => $layer // undef );
}

sub init {
    my $self = shift;
    my $file = $self->{file};
    open( $self->{fh}, ">>", $file )
      or die "cannot open '$file' for append: $!";
    $self->{fh}->autoflush(1);
    if(defined $self->{layer}){
        binmode( $self->{fh}, $self->{layer} );
    }
}

__PACKAGE__->make_logging_methods(
    sub {
        my ( $self, $text ) = @_;
        my $msg = sprintf( "[%s] %s\n", scalar(localtime), $text );
        $self->{fh}->print($msg);
    }
);

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::File - Simple adapter for logging to files

=head1 SYNOPSIS

    use Log::Any::Adapter ('File', '/path/to/file.log', ':utf8');

    # or

    use Log::Any::Adapter;
    ...
    Log::Any::Adapter->set('File', '/path/to/file.log', ':utf8');

=head1 DESCRIPTION

This simple built-in L<Log::Any|Log::Any> adapter logs each message to the
specified file, with a datestamp prefix and newline appended. The file is
opened for append with autoflush on. Category and log level are ignored.

