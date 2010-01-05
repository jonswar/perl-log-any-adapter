package Log::Any::Adapter::Base;
use Log::Any;
use Log::Any::Adapter::Util qw(make_method);
use strict;
use warnings;
use base qw(Log::Any::Adapter::Core);    # In Log-Any distribution

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->init(@_);
    return $self;
}

sub init { }

sub delegate_method_to_slot {
    my ( $class, $slot, $method, $adapter_method ) = @_;

    make_method( $method,
        sub { my $self = shift; return $self->{$slot}->$adapter_method(@_) },
        $class );
}

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Base

=head1 DESCRIPTION

This is the base class for Log::Any adapters. See
L<Log::Any::Adapter::Development|Log::Any::Adapter::Development> for
information on developing Log::Any adapters.

=head1 AUTHOR

Jonathan Swartz

=head1 COPYRIGHT & LICENSE

Copyright (C) 2009 Jonathan Swartz, all rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
