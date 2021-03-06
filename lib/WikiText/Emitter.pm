package WikiText::Emitter;
use strict;
use warnings;

use base 'WikiText::Receiver';

sub init {
    my $self = shift;
    $self->{output} = '';
}

sub content {
    my $self = shift;
    return $self->{output};
}

sub insert {
    my $self = shift;
    my $ast = shift;
    no warnings 'uninitialized';
    $self->{output} .= $ast->{output};
}

1;
