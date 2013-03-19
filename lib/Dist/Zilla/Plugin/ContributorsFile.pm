package Dist::Zilla::Plugin::ContributorsFile;
# ABSTRACT: add a file listing all contributors

use strict;
use warnings;

use Moose;
use Dist::Zilla::File::InMemory;

with qw/
    Dist::Zilla::Role::Plugin
    Dist::Zilla::Role::FileGatherer
    Dist::Zilla::Role::TextTemplate
/;

has filename => (
    is => 'ro',
    default => 'CONTRIBUTORS',
);

has contributors => (
    traits => [ 'Array' ],
    isa => 'ArrayRef',
    lazy => 1, 
    default => sub {
        my $self = shift;

        my ($p) = grep { ref $_ eq 'Dist::Zilla::Plugin::ContributorsFromGit' }  
            @{$self->zilla->plugins} or die __PACKAGE__." requires ContributorsFromGit to work";
        return [ @{$p->contributor_list} ];
    },
    handles => {
        has_contributors => 'count',
        all_contributors => 'elements',
    },
);

sub gather_files {
    my $self = shift;

    unless ( $self->has_contributors ) {
        return $self->log( 'no contributor detected, skipping file' );
    }

    my $content = $self->fill_in_string(
        $self->contributors_template(), {   
            distribution        => uc $self->zilla->name,
        }
    );

    my $file = Dist::Zilla::File::InMemory->new({ 
            content => $content,
            name    => $self->filename,
        }
    );

    $self->add_file($file);
}

sub contributors_template {
    my $self = shift;

    my $text = <<'END_CONT';

# {{$distribution}} CONTRIBUTORS #

This is the (likely incomplete) list of people who have helped
make this distribution what it is, either via code contributions, 
patches, bug reports, help with troubleshooting, etc. A huge
thank to all of them.

END_CONT

    $text .= "\t* $_\n" for $self->all_contributors;

    return $text;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__
=pod

=head1 SYNOPSIS

In dist.ini:

    [ContributorsFromGit]

    [ContributorsFile]
    filename = CONTRIBUTORS

=head1 DESCRIPTION

C<Dist::Zilla::Plugin::ContributorsFile> populates a I<CONTRIBUTORS> file
with all the contributors of the project as found by
C<Dist::Zilla::Plugin::ContributorsFromGit> (which also need to be present in
your C<dist.ini>).

The generated file will look like this:

    # FOO-BAR CONTRIBUTORS #

    This is the (likely incomplete) list of people who have helped
    make this distribution what it is, either via code contributions, 
    patches, bug reports, help with troubleshooting, etc. A huge
    thank to all of them.

        * Albert Zoot <zoo@foo.com>
        * Bertrand Maxwell <maxwell@bar.com>

Note that if no contributor is detected beside the actual author of the
module, the file will not be created. 

=head1 CONFIGURATION OPTIONS

=head2 filename

The name of the contributor file that is created. Defaults to I<CONTRIBUTORS>.

