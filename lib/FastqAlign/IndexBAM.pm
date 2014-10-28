package FastqAlign::IndexBAM;

use strict;
use warnings;
use parent qw/FastqAlign::Base/;

sub run {
  my ($self) = @_;
  my $bam = $self->param_required('bam');
  my $samtools = $self->param_required('samtools');
  my $tmpdir = $self->param_required('tmpdir');
  my $cmd_line = qq{${samtools} index ${bam}};
  $self->run_command_line($cmd_line);
  return;
}

1;