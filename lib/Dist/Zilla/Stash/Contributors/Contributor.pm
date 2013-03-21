package Dist::Zilla::Stash::Contributors::Contributor;
# ABSTRACT: a contributor in the Contributors stash

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

use overload '""' => sub { sprintf '%s <%s>', $_[0]->name, $_[0]->email };

has name => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has email => (
    is => 'ro',
    required => 0,
);

__PACKAGE__->meta->make_immutable;
1;

