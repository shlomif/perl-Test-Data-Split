package Test::Data::Split::Backend::Hash;

use strict;
use warnings;


=head1 NAME

Test::Data::Split::Backend::Hash - hash backend.

=head1 SYNOPSIS

    package DataSplitHashTest;

    use strict;
    use warnings;

    use parent 'Test::Data::Split::Backend::Hash';

    my %hash =
    (
        a => { more => "Hello"},
        b => { more => "Jack"},
        c => { more => "Sophie"},
        d => { more => "Danny"},
        'e100_99' => { more => "Zebra"},
    );

    sub get_hash
    {
        return \%hash;
    }

    1;

=head1 DESCRIPTION

This is a hash backend for L<Test::Data::Split> .

=head1 METHODS

=head2 new()

For internal use.

=head2 $obj->lookup_data($id)

Looks up the data with the ID $id.

=head2 $obj->list_ids()

Lists the IDs - needed by Test::Data::Split;

=head2 $obj->get_hash()

This method should be implemented and return a hash reference to the
keys/values of the data.

=cut

sub new
{
    my $class = shift;

    my $self = bless {}, $class;

    $self->_init(@_);

    return $self;
}

sub _hash
{
    my $self = shift;

    if (@_)
    {
        $self->{_hash} = shift;
    }

    return $self->{_hash};
}

sub _init
{
    my ($self, $args) = @_;

    $self->_hash(scalar ( $self->get_hash() ));

    return;
}

sub list_ids
{
    my ($self) = @_;

    my @keys = keys(%{$self->_hash});

    require List::MoreUtils;

    if (List::MoreUtils::notall( sub { /\A[A-Za-z_\-0-9]{1,80}\z/ }, @keys))
    {
        die "Invalid key in hash reference. All keys must be alphanumeric plus underscores and dashes.";
    }
    return [ sort { $a cmp $b } @keys ];
}

sub lookup_data
{
    my ($self, $id) = @_;

    return $self->_hash->{$id};
}

1;
