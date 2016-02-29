package Test::Data::Split;

use strict;
use warnings;
use autodie;

use 5.008;

our $VERSION = '0.0.4';

use IO::All qw/ io /;

=head1 NAME

Test::Data::Split - split data-driven tests into several test scripts.

=head1 SYNOPSIS

    use Test::Data::Split;

    # Implements Test::Data::Split::Backend::Hash
    use MyTest;

    my $tests_dir = "./t";

    my $obj = Test::Data::Split->new(
        {
            target_dir => $tests_dir,
            filename_cb => sub {
                my ($self, $args) = @_;

                my $id = $args->{id};

                return "valgrind-$id.t";
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

    @{['# TEST']}
    MyTest->run_id(qq#$id#);

    EOF
            },
            data_obj => MyTest->new,
        }
    );

    $obj->run;

    # And later in the shell:
    prove t/*.t

=head1 DESCRIPTION

This module splits a set of data with IDs and arbitrary values into one
test file per (key+value) for easy parallelisation.

=cut

use MooX qw/ late /;

has '_target_dir' => (is => 'ro', isa => 'Str', required => 1, init_arg => 'target_dir',);
has ['_filename_cb'] => (is => 'ro', isa => 'CodeRef', required => 1, init_arg => 'filename_cb',);
has ['_contents_cb'] => (is => 'ro', isa => 'CodeRef', required => 1, init_arg => 'contents_cb',);
has '_data_obj' => (is => 'ro', required => 1, init_arg => 'data_obj');

=head1 METHODS

=head2 my $obj = Test::Data::Split->new({ %PARAMS })

Accepts the following parameters:

=over 4

=item * target_dir

The path to the target directory - a string.

=item * filename_cb

A subroutine references that accepts C<< ($self, {id => $id }) >>
and returns the filename.

=item * contents_cb

A subroutine references that accepts
C<< ($self, {id => $id, data => $data }) >> and returns the contents inside
the file.

=item * data_obj

An object reference that implements the C<< ->list_ids() >> methods
that returns an array reference of IDs to generate as files.

=back

An example for using it can be found in the synopsis.

=head2 $self->run()

Generate the files.

=cut

sub run
{
    my $self = shift;

    my $target_dir = $self->_target_dir;
    my $filename_cb = $self->_filename_cb;
    my $contents_cb = $self->_contents_cb;

    my $data_obj = $self->_data_obj;

    foreach my $id (@{ $data_obj->list_ids() })
    {
        # Croak on bad IDs.
        if ($id !~ /\A[A-Za-z_\-0-9]{1,80}\z/)
        {
            die "Invalid id '$id'.";
        }

        io->catfile($target_dir, $filename_cb->($self, { id => $id, }, ))
          ->assert->print(
              $contents_cb->($self, { id => $id, data => $data_obj->lookup_data($id) },)
          );
    }

    return;
}

1;

