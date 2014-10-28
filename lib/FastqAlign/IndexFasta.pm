package FastqAlign::IndexFasta;

use strict;
use warnings;
use parent qw/FastqAlign::Base/;
use PerlIO::gzip;

sub run {
  my ($self) = @_;
  my $reference = $self->param_required('reference');
  my $bwa = $self->param_required('bwa');
  
  # If the index already exists skip we're good
  if(-f $reference.'.bwt') {
    $self->param('index', $reference);
    return;
  }
  
  # Check if it was gzipped & if bwt was there skip otherwise decompress
  my $target = $reference;
  if($reference =~ /\.gz/) {
    $target =~ s/\.gz//;
    if(-f $target.'.bwt') {
      $self->param('index', $target);
      return;
    }
    $self->decompress($reference, $target);
  }
  
  # Assume we can attempt indexing
  my $cmd_line = qq{${bwa} index ${target}};
  $self->run_command_line($cmd_line);
  $self->param('index', $target); #bwa index is XXXXXX.fa not XXXXXXX.fa.bwt (bwa already adds that on)
  
  return;
}

sub decompress {
  my ($self, $source, $target) = @_;
  my $cmd_line = qq{gzip -dc ${source} > ${target}};
  $self->run_command_line($cmd_line);
  return;
}

1;