package Test::Data::Split::Backend::Hash;

use strict;
use warnings;

use List::MoreUtils qw/notall/;

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

    my $hash_ref = $self->get_hash;

    if (notall { /\A[A-Za-z_\-0-9]{1,80}\z/ } keys (%$hash_ref))
    {
        die "Invalid key in hash reference. All keys must be alphanumeric plus underscores and dashes.";
    }
    $self->_hash($hash_ref);

    return;
}

sub list_ids
{
    my ($self) = @_;

    return [ sort { $a cmp $b } keys(%{$self->_hash}) ];
}

sub lookup_data
{
    my ($self, $id) = @_;

    return $self->_hash->{$id};
}

1;
