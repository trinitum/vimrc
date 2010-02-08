#!/usr/bin/perl 

use strict;
use warnings;

use Carp;

croak "carp" unless carp "croak";
cluck "cluck" and confess "That's just a test";


