package Log::Any::Manager::Full;
use strict;
use warnings;
use base qw(Log::Any::Manager::Base);

sub upgrade_to_full { }

sub set_adapter {
    my ( $self, $adapter_name, %adapter_params ) = @_;

    croak "adapter class required"
      unless defined($adapter_name) && $adapter_name =~ /\S/;
    $adapter_name =~ s/^Log:://;
    my $adapter_class = (
          substr( $adapter_name, 0, 1 ) eq '+'
        ? substr( $adapter_name, 1 )
        : "Log::Any::Adapter::$adapter_name"
    );
    $self->{adapter_class}  = $adapter_class;
    $self->{adapter_params} = \%adapter_params;
    require_dynamic($adapter_class);

    # Replace each adapter out in the wild by reblessing and overriding hash
    #
    $self->{adapter_cache} ||= {};
    while ( my ( $category, $adapter ) = each( %{ $self->{adapter_cache} } ) ) {
        my $new_adapter =
          $adapter_class->new( %adapter_params, category => $category );
        %$adapter = %$new_adapter;
        bless( $adapter, $adapter_class );
    }
}

1;
