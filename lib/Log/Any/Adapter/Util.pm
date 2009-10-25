package Log::Any::Adapter::Util;
use Log::Any::Util qw(dump_one_line);
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(
  cmp_deeply
  read_file
  require_dynamic
);

sub cmp_deeply {
    my ( $ref1, $ref2, $name ) = @_;

    my $tb = Test::Builder->new();
    $tb->is_eq( dump_one_line($ref1), dump_one_line($ref2), $name );
}

sub read_file {
    my ($file) = @_;

    local $/ = undef;
    open( my $fh, '<', $file )
      or die "cannot open '$file': $!";
    my $contents = <$fh>;
    return $contents;
}

sub require_dynamic {
    my ($class) = @_;

    unless ( defined( eval "require $class" ) )
    {    ## no critic (ProhibitStringyEval)
        die $@;
    }
}

1;
