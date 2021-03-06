package Repo101::Git;
use Exporter qw(import);
@EXPORT_OK = qw(git clone_or_pull);

use strict;
use warnings;
use Git::Repository;
use Scalar::Util    qw(blessed);


sub git
{
    my $repo = blessed $_[0] ? shift : 'Git::Repository';
    $repo->run(@_, {fatal => '!0'})
}

our $null_tree = git(qw(hash-object -t tree /dev/null));


sub clone_or_pull
{
    my ($dir, $url, $branch) = @_;
    my ($repo, $revision) = -e "$dir/.git" ? pull(@_) : clone(@_);
    git($repo, 'checkout', '-q', $branch) if defined $branch;
    gather_changes($repo, $revision, 'HEAD')
}

sub clone
{
    my ($dir, $url) = @_;
    git('clone', '-q', $url, $dir);
    (Git::Repository->new(work_tree => $dir), undef)
}

sub pull
{
    my ($dir) = @_;
    my $repo     = Git::Repository->new(work_tree => $dir);
    my $revision = git($repo, 'rev-parse', 'HEAD');
    git($repo, 'pull', '-q');
    ($repo, $revision)
}


sub gather_changes
{
    my $repo = shift;
    my $from = shift // $null_tree;
    my $to   = shift // $null_tree;
    my $dir  = $repo->work_tree;

    my %changes = map {
        my ($op, $file) = split /\t/, $_, 2;
        ("$dir/$file" => $op)
    } git($repo, 'diff', '--name-status', $from, $to);

    \%changes
}


1
__END__

=head1 Repo101::Git

Contains a few git functions for pull101repo based on Git::Repository.

=head2 git

    git(@args)
    git(Git::Repository $repo, @args)

Dispatches to C<< $repo->run(@args) >> if a L<Git::Repository> C<$repo> is
given as the first argument and to C<< Git::Repository->run(@args) >>
otherwise. Dies if any exit code but C<0> is returned by the git command and
propagates the return from the C<run> function.

=head2 null_tree

    $null_tree

Hash for an empty git tree, used to get an initial diff. This hash should
always turn out to be C<4b825dc642cb6eb9a060e54bf8d69288fbee4904>. It is used
for getting a sensible C<git diff> for a newly cloned repo.

=head2 clone_or_pull

    clone_or_pull($dir, $url)
    clone_or_pull($dir, $url, $branch)

Dispatches to L</clone> if the folder C<$dir> doesn't exist yet, otherwise
runs L</pull>. If a C<$branch> is given, it will also run C<git checkout> on
it. This is used in L<101test|https://github.com/101companies/101test>.

Returns a diff of changes between the previous and the current state - see
L</gather_changes>.

=head2 clone

    clone($dir, $url)

C<git clone>s the repository from C<$url> into C<$dir>. Returns a two-element
list containing the resulting C<Git::Repository> and C<undef> (because there
was no previous revision).

See also L</pull> and L</clone_or_pull>.

=head2 pull

    pull($dir)

C<git pull>s the repository in C<$dir>. Returns a two-element list containing
the C<Git::Repository> and the revision before the pull.

See also L</clone> and L</clone_or_pull>.

=head2 gather_changes

    gather_changes($repo, $from=$null_tree, $to=$null_tree)

Runs a C<git diff --name-status> between the two revisions C<$from> and C<$to>
on the given C<$repo>. If any one of those revisions is not given or C<undef>,
the L</$null_tree> is used in its place.

Returns a hashref that maps from file path to what happened with the file:
'A' for added, 'M' for modified and 'D' for deleted. Here's an example what
this function could return:

    {
        '/some/path/101repo/added.java' => 'A',
        '/some/path/101repo/modified.c' => 'M',
        '/some/path/101repo/deleted.hs' => 'D',
    }

Usage examples where C<$repo> is some L<Git::Repository> instance:

=over

=item C<gather_changes($repo, undef, 'HEAD')>

Difference between an empty repository and the current revision. Result will
be a bunch of additions for every file in the repo.

=item C<gather_changes($repo, 'HEAD', undef)>

Same as above, except the return will be a deletion for every file in the repo.

=item C<gather_changes($repo, 'HEAD^', 'HEAD')>

The changes from the last commit.

=back

=cut
