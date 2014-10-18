package Dist::Zilla::Plugin::ContributorsFile;
# ABSTRACT: add a file listing all contributors

use strict;
use warnings;

use Moose;
use Dist::Zilla::File::InMemory;

with qw/
    Dist::Zilla::Role::Plugin
    Dist::Zilla::Role::FileGatherer
    Dist::Zilla::Role::FileMunger
    Dist::Zilla::Role::FilePruner
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
        return $self->zilla->distmeta->{x_contributors} || [];
    },
    handles => {
        has_contributors => 'count',
        all_contributors => 'elements',
    },
);

sub munge_file {
    my( $self, $file ) = @_;

    return unless $file->name eq $self->filename;

    return $self->log( 'no contributor detected, skipping file' )
        unless $self->has_contributors;

    $file->content( $self->fill_in_string(
        $file->content, {
            distribution => uc $self->zilla->name,
            contributors => [ $self->all_contributors ],
        }
    ));

}

sub gather_files {
    my $self = shift;

    my $file = Dist::Zilla::File::InMemory->new({ 
            content => $self->contributors_template,
            name    => $self->filename,
        }
    );

    $self->add_file($file);
}

sub prune_files {
    my $self = shift;

    return if $self->has_contributors;

    $self->log( 'no contributors, pruning file' );

    for my $file ( grep { $_->name eq $self->filename } @{ $self->zilla->files } ) {
        $self->zilla->prune_file($file);
    }

}

sub contributors_template {
    return <<'END_CONT';

# {{$distribution}} CONTRIBUTORS #

This is the (likely incomplete) list of people who have helped
make this distribution what it is, either via code contributions, 
patches, bug reports, help with troubleshooting, etc. A huge
'thank you' to all of them.

{{ 
    for my $contributor ( @contributors ) {
        $OUT .= "    * $contributor\n";
    } 
}}

END_CONT

}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__
=pod

=head1 SYNOPSIS

In dist.ini:

    " any plugin populating x_contributors in the META files
    [ContributorsFromGit]

    [ContributorsFile]
    filename = CONTRIBUTORS

=head1 DESCRIPTION

C<Dist::Zilla::Plugin::ContributorsFile> populates a I<CONTRIBUTORS> file
with all the contributors of the project as found by
C<Dist::Zilla::Plugin::ContributorsFromGit> (or any other plugin populating 
the I<x_contributors> in the META files).

The generated file will look like this:

    # FOO-BAR CONTRIBUTORS #

    This is the (likely incomplete) list of people who have helped
    make this distribution what it is, either via code contributions, 
    patches, bug reports, help with troubleshooting, etc. A huge
    'thank you' to all of them.

        * Albert Zoot <zoo@foo.com>
        * Bertrand Maxwell <maxwell@bar.com>

Note that if no contributors beside the actual author(s) are found,
the file will not be created. 

=head1 CONFIGURATION OPTIONS

=head2 filename

The name of the contributor file that is created. Defaults to I<CONTRIBUTORS>.

=head1 TRICKS

Refer to David Golden's blog entry at 
L<http://www.dagolden.com/index.php/1921/how-im-using-distzilla-to-give-credit-to-contributors/>
to get introduced to the C<Dist::Zilla> contributor modules.

Git's C<.mailmap> file is useful to deal with contributors with several email
addresses:
L<https://www.kernel.org/pub/software/scm/git/docs/git-shortlog.html>.

To give credit to bug reporters and other persons who don't commit code
directly, you can use empty git commits:

    git commit --allow-empty --author="David Golden <dagolden@cpan.org>" -m "..."

=head1 SEE ALSO

L<Dist::Zilla::Plugin::ContributorsFromGit>

L<Dist::Zilla::Plugin::Git::Contributors>

L<Pod::Weaver::Section::Contributors>
