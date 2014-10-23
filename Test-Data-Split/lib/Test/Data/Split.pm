package Test::Data::Split;

use strict;
use warnings;

our $VERSION = '0.0.1';

=head1 NAME

Test::Data::Split - split data-driven test into several test scripts.

=cut

use MooX qw/ late /;

has '_target_dir' => (is => 'ro', isa => 'Str', required => 1, init_arg => 'target_dir',);
has ['_filename_cb'] => (is => 'ro', isa => 'CodeRef', required => 1, init_arg => 'filename_cb',);
has ['_contents_cb'] => (is => 'ro', isa => 'CodeRef', required => 1, init_arg => 'contents_cb',);
has '_data_obj' => (is => 'ro', required => 1, init_arg => 'data_obj');

1;

