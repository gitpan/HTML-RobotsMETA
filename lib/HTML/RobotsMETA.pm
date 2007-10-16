# $Id: /mirror/perl/HTML-RobotsMETA/trunk/lib/HTML/RobotsMETA.pm 3528 2007-10-16T09:36:47.480863Z daisuke  $

package HTML::RobotsMETA;
use strict;
use warnings;
use HTML::Parser;
use HTML::RobotsMETA::Rules;
our $VERSION = '0.00001';
our @ISA = qw(HTML::Parser);

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(
        api_version => 3,
        start_h => [\&_parse_start_h, "self, tagname, attr"]
    );

    return $self;
}

sub parse_rules
{
    my $self = shift;
    delete $self->{rules};
    $self->parse(@_);
    $self->eof;

    # merge rules that were found in this document
    my %directives = (map { %$_ } @{ delete $self->{rules} });
    return HTML::RobotsMETA::Rules->new(%directives);
}

sub _parse_start_h
{
    my ($self, $tag, $attr) = @_;

    return unless $tag eq 'meta';

    # the "name" attribute may contain either "robots", or user-specified
    # robot name, which is specific to a particular crawler
    # XXX - Handle the specific agent part later
    return unless $attr->{name} =~ /^robots$/;

    my %directives;
    # Allowed values
    #   FOLLOW
    #   NOFOLLOW
    #   INDEX
    #   NOINDEX
    #   ARCHIVE
    #   NOARCHIVE
    #   SERVE
    #   NOSERVER
    #   NOIMAGEINDEX
    #   NOIMAGECLICK
    #   ALL
    #   NONE
    my $content = lc $attr->{content};
    while ($content =~ /((?:no)?(follow|index|archive|serve)|(?:noimage(?:index|click))|all|none)/g) {
        $directives{$1}++;
    }

    $self->{rules} ||= [];
    push @{$self->{rules}}, \%directives;
}

1;

__END__

=head1 NAME

HTML::RobotsMETA - Parse HTML For Robots Exclusion META Markup

=head1 SYNOPSIS

  use HTML::RobotsMETA;
  my $p = HTML::RobotsMETA->new;
  my $r = $p->parse_rules($html);
  if ($r->can_follow) {
    # follow links here!
  } else {
    # can't follow...
  }

=head1 DESCRIPTION

HTML::RobotsMETA is a simple HTML::Parser subclass that extracts robots
exclusion information from meta tags. There's not much more to it ;)

=head1 DIRECTIVES

Currently HTML::RobotsMETA understands the following directives:

=over 4

=item ALL

=item NONE

=item INDEX

=item NOINDEX

=item FOLLOW

=item NOFOLLOW

=item ARCHIVE

=item NOARCHIVE

=item SERVE

=item NOSERVE

=item NOIMAGEINDEX

=item NOIMAGECLICK

=back

=head1 METHODS

=head2 new

Creates a new HTML::RobotsMETA parser. Takes no arguments

=head2 parse_rules

Parses an HTML string for META tags, and returns an instance of
HTML::RobotsMETA::Rules object, which you can use in conditionals later

=head1 TODO

Tags that specify the crawler name (e.g. E<lt>META NAME="Googlebot"E<gt>) are
not handled yet.

There also might be more obscure directives that I'm not aware of.

=head1 AUTHOR

Copyright (c) 2007 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=head1 SEE ALSO

L<HTML::RobotsMETA::Rules|HTML::RobotsMETA::Rules> L<HTML::Parser|HTML::Parser>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut