#!/usr/bin/perl

use strict;
use warnings;

use lib './t/lib';

use Test::More tests => 1;

use Test::Data::Split ();

{
    eval { require DataSplitValidateHashTest2; };

    # TEST
    like(
        $@,
        qr/\AThe data contains the word 'Just'/,
        "Exception was thrown.",
    );
}
