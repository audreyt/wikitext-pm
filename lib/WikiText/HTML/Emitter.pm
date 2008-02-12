package WikiText::HTML::Emitter;
use strict;
use warnings;

use base 'WikiText::Receiver';
use CGI::Util;

my $type_tags = {
    b => 'strong',
    i => 'em',
    wikilink => 'a',
};

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
    $self->{output} .= $ast->{output} || '';
}

sub uri_escape {
    $_ = shift;
    s/ /\%20/g;
    return $_;
}

sub begin_node {
    my $self = shift;
    my $node = shift;
    my $type = $node->{type};
    my $tag = $type_tags->{$type} || $type;
# XXX For tables maybe...
#    $tag =~ s/-.*//;
    $self->{output} .=
      ($tag =~ /^(br|hr)$/)
        ? "<$tag />\n" 
        : ($type eq "wikilink")
          ?  $self->begin_wikilink($node)
          : "<$tag>" .
            ($tag =~ /^(ul|ol|table|tr)$/ ? "\n" : "");
}

sub begin_wikilink {
    my $self = shift;
    my $node = shift;
    my $tag = $node->{type};

    my $link = $self->{callbacks}{wikilink}
        ? $self->{callbacks}{wikilink}->($node)
        : CGI::Util::escape($node->{attributes}{target});
    return qq{<a href="$link">};
}

sub end_node {
    my $self = shift;
    my $node = shift;
    my $type = $node->{type};
    my $tag = $type_tags->{$type} || $type;
    $tag =~ s/-.*//;
    return if ($tag =~ /^(br|hr)$/);
    if ($tag eq "wikilink") {
        $self->{output} .= '</a>';
        return;
    }
    $self->{output} .= "</$tag>" .
        ($tag =~ /^(p|hr|ul|ol|li|h\d|table|tr|td)$/ ? "\n" : "");
}

sub text_node {
    my $self = shift;
    my $text = shift;
    $self->{output} .= "$text";
}

1;

=head1 NAME

WikiText::HTML::Emitter - A WikiText Receiver That Generates HTML

=head1 SYNOPSIS

    use WikiText::HTML::Emitter;
    
=head1 DESCRIPTION

This receiver module, when hooked up to a parser, produces HTML.

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2008. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
