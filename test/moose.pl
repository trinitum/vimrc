#!/usr/bin/perl 

use Moose;
extends 'something';
with 'something else';

has attribute => (is => 'rw');

before start => sub {
    warn "starting...";
};

around process => sub {
    my $orig = shift;
    my $self = shift;
    warn "just before...";
    $self->$orig(@_);
    warn "just after...";
};

after finish => sub {
    warn "finished...";
};

augment as_xml => sub {
    my $self = shift;
    my $xml = '<foo>';
    $xml .= inner();
    $xml .= '</foo>';
    $xml;
};

override name => sub {
    my $self = shift;
    return super() . "->" . "moose";
};


