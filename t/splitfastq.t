use strict;
use warnings;
use Test::More;
use Test::File;

use FastqAlign::SplitFastq;
use Bio::EnsEMBL::Hive::Params;
use Cwd;
use File::Basename;
use File::Spec;
use File::Copy;
use File::Temp qw/tempdir/;

my $dirname = dirname(Cwd::realpath(__FILE__));
my $source = File::Spec->catfile(File::Spec->catdir($dirname, File::Spec->updir(), 'test_data'), 'one.fq.gz');
my $tmp_dir = tempdir( CLEANUP => 1 );
# my $target = File::Spec->catfile($tmp_dir, 'one.fq.gz');
# copy($source, $target);

my $p = FastqAlign::SplitFastq->new();
$p->process_file($source, $tmp_dir, 2);
file_line_count_is(File::Spec->catfile($tmp_dir, '00001.one.fq'), 8, 'File 1 has 8 lines');
file_line_count_is(File::Spec->catfile($tmp_dir, '00002.one.fq'), 8, 'File 2 has 8 lines');
file_line_count_is(File::Spec->catfile($tmp_dir, '00003.one.fq'), 8, 'File 3 has 8 lines');
file_line_count_is(File::Spec->catfile($tmp_dir, '00004.one.fq'), 4, 'File 4 has 4 lines');

done_testing();