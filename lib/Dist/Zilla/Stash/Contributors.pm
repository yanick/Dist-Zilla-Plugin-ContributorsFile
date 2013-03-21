package Dist::Zilla::Stash::Contributors;
# ABSTRACT: Stash containing list of contributors

use strict;
use warnings;

use Moose;

use Dist::Zilla::Stash::Contributors::Contributor;

has contributors => (
    traits => [ 'Array' ],
    isa => 'ArrayRef[Dist::Zilla::Stash::Contributors::Contributor]',
    is => 'ro',
    default => sub { [] },
    handles => {
        all_contributors => 'elements',
        nbr_contributors => 'count',
        push => 'push',
    },
);

sub add_contributors {
    my ( $self, @contributors ) = @_;

    for my $c ( @contributors ) {
        my $name = $c;
        my $email;
        $email = $1 if $name =~ s/\s*<(.*?)>\s*//;
        $self->push( Dist::Zilla::Stash::Contributors::Contributor->new( 
            name => $name, email => $email 
        ) );
    }

}

__PACKAGE__->meta->make_immutable;

1;
