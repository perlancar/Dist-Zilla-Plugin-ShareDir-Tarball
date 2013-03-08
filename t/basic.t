use strict;
use warnings;

use Test::More tests => 2;

use Test::DZil;

for my $corpus ( qw/ corpus corpus-dir / ) {

    subtest "with corpus $corpus" => sub {
        plan tests => 6;

        my $tzil = Builder->from_config( { dist_root => "t/$corpus" },);

        $tzil->build;

        my @shared = grep { $_->name =~ m#share/# } @{ $tzil->files };

        is @shared => 1, "there is only one file";

        is $shared[0]->name => 'share/shared-files.tar.gz', "and it's the tarball";

        my $content = Compress::Zlib::memGunzip($shared[0]->content);
        open my $fh, '<', \$content;

        my $tar = Archive::Tar->new;
        $tar->read($fh);

        ok $tar->contains_file($_), "$_ present" for qw/ foo bar /;

        my ($makefile) = grep { $_->name =~ /Makefile.PL/ } @{$tzil->files};

        ok $makefile, "Makefile.PL present";

        like
            $makefile->content,
            qr/use File::ShareDir::Install;/,
            "Makefile.PL has the sharedir directive" 
        ;
    }
}
