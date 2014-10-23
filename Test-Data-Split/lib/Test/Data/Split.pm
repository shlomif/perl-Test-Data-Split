package Test::Data::Split;

use strict;
use warnings;
use autodie;

our $VERSION = '0.0.1';

use IO::All qw/ io /;

=head1 NAME

Test::Data::Split - split data-driven test into several test scripts.

=cut

use MooX qw/ late /;

has '_target_dir' => (is => 'ro', isa => 'Str', required => 1, init_arg => 'target_dir',);
has ['_filename_cb'] => (is => 'ro', isa => 'CodeRef', required => 1, init_arg => 'filename_cb',);
has ['_contents_cb'] => (is => 'ro', isa => 'CodeRef', required => 1, init_arg => 'contents_cb',);
has '_data_obj' => (is => 'ro', required => 1, init_arg => 'data_obj');

=head1 METHODS

=head2 $self->run()

Generate the files.

=cut

sub run
{
    my $self = shift;

    my $target_dir = $self->_target_dir;
    my $filename_cb = $self->_filename_cb;
    my $contents_cb = $self->_contents_cb;

    foreach my $id (@{ $self->_data_obj->list_ids() })
    {
        # Croak on bad IDs.
        if ($id !~ /\A[A-Za-z_\-0-9]{1,80}\z/)
        {
            die "Invalid id '$id'.";
        }

        io->catfile($target_dir, $filename_cb->($self, { id => $id, }, ))
          ->assert->print(
              $contents_cb->($self, { id => $id, },)
          );
    }

    return;
}

1;

