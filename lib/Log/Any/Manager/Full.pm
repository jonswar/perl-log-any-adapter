package Log::Any::Manager::Full;
use strict;
use warnings;
use Carp qw(croak);
use Log::Any::Adapter::Null;
use Log::Any::Util qw(require_dynamic);
use base qw(Log::Any::Manager::Base);

sub upgrade_to_full { }

sub initialize_full {
    my ($self) = @_;
    my $null_entry = $self->_new_entry( qr/.*/, 'Log::Any::Adapter::Null', {} );
    $self->{entries} = [$null_entry];
    foreach my $key ( keys( %{ $self->{category_cache} } ) ) {
        $self->{category_cache}->{$key}->{entry} = $null_entry;
    }
}

sub _get_logger_for_category {
    my ( $self, $category ) = @_;

    # Create a new adapter for this category if it is not already in cache
    #
    my $category_cache = $self->{category_cache};
    if ( !defined( $category_cache->{$category} ) ) {
        my $entry = $self->_choose_entry_for_category($category);
        my $adapter = $self->_new_adapter_for_entry( $entry, $category );
        $category_cache->{$category} = { entry => $entry, adapter => $adapter };
    }
    return $category_cache->{$category}->{adapter};
}

sub _choose_entry_for_category {
    my ( $self, $category ) = @_;

    foreach my $entry ( @{ $self->{entries} } ) {
        if ( $category =~ $entry->{pattern} ) {
            return $entry;
        }
    }
    die "no entries matched '$category' - should not get here!";
}

sub _new_adapter_for_entry {
    my ( $self, $entry, $category ) = @_;

    return $entry->{adapter_class}
      ->new( %{ $entry->{adapter_params} }, category => $category );
}

sub set_adapter {
    my ( $self, $adapter_name, %adapter_params ) = @_;

    return $self->set_adapter_for( qr/.*/, $adapter_name, %adapter_params );
}

sub set_adapter_for {
    my ( $self, $pattern, $adapter_name, %adapter_params ) = @_;

    croak "expected regexp for pattern, got '$pattern'"
      unless defined($pattern) && ref($pattern) eq 'Regexp';
    croak "expected adapter name"
      unless defined($adapter_name) && $adapter_name =~ /\S/;

    $adapter_name =~ s/^Log:://;    # Log::Dispatch -> Dispatch, etc.
    my $adapter_class = (
          substr( $adapter_name, 0, 1 ) eq '+'
        ? substr( $adapter_name, 1 )
        : "Log::Any::Adapter::$adapter_name"
    );
    require_dynamic($adapter_class);

    my $entry = $self->_new_entry( $pattern, $adapter_class, \%adapter_params );
    unshift( @{ $self->{entries} }, $entry );

    $self->reselect_matching_adapters($pattern);

    return $entry;
}

sub remove_adapter {
    my ( $self, $entry ) = @_;

    my $pattern = $entry->{pattern};
    $self->{entries} = [ grep { $_ ne $entry } @{ $self->{entries} } ];
    $self->reselect_matching_adapters($pattern);
}

sub _new_entry {
    my ( $self, $pattern, $adapter_class, $adapter_params ) = @_;

    return {
        pattern        => $pattern,
        adapter_class  => $adapter_class,
        adapter_params => $adapter_params,
    };
}

sub reselect_matching_adapters {
    my ( $self, $pattern ) = @_;

    # Reselect adapter for each category matching $pattern
    #
    while ( my ( $category, $category_info ) =
        each( %{ $self->{category_cache} } ) )
    {
        my $new_entry = $self->_choose_entry_for_category($category);
        if ( $new_entry ne $category_info->{entry} ) {
            my $new_adapter =
              $self->_new_adapter_for_entry( $new_entry, $category );
            %{ $category_info->{adapter} } = %$new_adapter;
            bless( $category_info->{adapter}, ref($new_adapter) );
            $category_info->{entry} = $new_entry;
        }
    }
}

1;
