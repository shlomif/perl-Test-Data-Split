#!/usr/bin/perl

use strict;
use warnings;

package DataObj;

use List::MoreUtils qw/notall/;

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

    my $hash_ref = $args->{hash};

    if (notall { /\A[A-Za-z_\-0-9]{1,80}\z/ } keys (%$hash_ref))
    {
        die "Invalid key in hash reference. All keys must be alphanumeric plus underscores and dashes.";
    }
    $self->_hash($hash_ref);

    return;
}

sub list_ids
{
    return [ sort { $a cmp $b } keys(%{shift->_hash}) ];
}

sub lookup_data
{
    my ($self, $id) = @_;

    return $self->_hash->{$id};
}

package main;

use Test::More tests => 1;

use Test::Data::Split;

use File::Temp qw/tempdir/;


1;
{

    my $dir = tempdir( CLEANUP => 1);

    my $tests_dir = "$dir/t";

    my %hash =
    (
        a => { more => "Hello"},
        b => { more => "Jack"},
        c => { more => "Sophie"},
        d => { more => "Danny"},
        'e100_99' => { more => "Zebra"},
    );

    my $data_obj = DataObj->new(
        {
            hash_ref => \%hash,
        }
    );

    my $obj = Test::Data::Split->new(
        {
            target_dir => "$dir/t",
            filename_cb => sub {
                my ($self, $args) = @_;

                my $id = $args->{id};

                return "valgrind-$id";
            },
            contents_cb => sub {
                my ($self, $args) = @_;

                my $id = $args->{id};

                return <<"EOF";
#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;
use MyTest;

# TEST
MyTest->run_id(qq#$id#);

EOF
            },
            data_obj => $data_obj,
        }
    );

    # TEST
    ok ($obj, "Object was initted.");
}

