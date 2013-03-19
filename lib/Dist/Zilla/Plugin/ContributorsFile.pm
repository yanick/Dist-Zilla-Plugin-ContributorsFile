package Dist::Zilla::Plugin::ContributorsFile;
BEGIN {
  $Dist::Zilla::Plugin::ContributorsFile::AUTHORITY = 'cpan:YANICK';
}
{
  $Dist::Zilla::Plugin::ContributorsFile::VERSION = '0.1.0';
}
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

=head1 NAME

Dist::Zilla::Plugin::ContributorsFile - add a file listing all contributors

=head1 VERSION

version 0.1.0

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

L<http://p3rl.org/Pod::Weaver::Section::Contributors>

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
