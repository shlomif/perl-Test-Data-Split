package Test::Data::Split::Backend::ValidateHash;

use strict;
use warnings;

use Carp qw/confess/;

use parent 'Test::Data::Split::Backend::Hash';

sub populate
{
    my ($self, $array_ref) = @_;

    my @l = @$array_ref;

    my $tests = $self->get_hash;

    if (@l & 0x1)
    {
        confess("Input length is not even.");
    }
    while (@l)
    {
        my $key = shift@l;
        my $val = shift@l;
        if (exists($tests->{$key}))
        {
            confess("Duplicate key '$key'!");
        }
        $tests->{$key} = $self->validate_and_transform({id => $key, data => $val,});
    }

    return;
}

1;

=head1 NAME

Test::Data::Split::Backend::ValidateHash - hash backend with input validation
and transformation.

=head1 SYNOPSIS

See the tests.

=head1 DESCRIPTION

This inherits from L<Test::Data::Split::Backend::Hash> .

=head1 METHODS

=head2 $pkg->populate([$id1,$data1,$id2,$data2,$id3,$data3...]);

Populate the hash with the IDs and data passed as an even lengthed
array reference. The IDs must be unique and the
L<validate_and_transform> method must be implemented.

The accepts an C<< {id => $id, data => $data} >> hash reference and either
throws an exception or returns the transformed/mutated data (which can be the
same as the original.

=cut
