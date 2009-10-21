package Log::Any::Adapter::Util;
use Log::Any::Util qw(dump_one_line);
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(
  cmp_deeply
);

sub cmp_deeply {
    my ( $ref1, $ref2, $name ) = @_;

    my $tb = Test::Builder->new();
    $tb->is_eq( dump_one_line($ref1), dump_one_line($ref2), $name );
}

1;
