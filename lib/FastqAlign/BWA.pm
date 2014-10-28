package FastqAlign::BWA;

use strict;
use warnings;
use parent qw/FastqAlign::Base/;

sub run {
  my ($self) = @_;  
  my $fastq = $self->param_required('fastq');
  my $reference = $self->param_required('index');
  my $bwa = $self->param_required('bwa');
  my $threads = $self->param_required('threads');
  my $samtools = $self->param_required('samtools');
  my $tmpdir = $self->param_required('tmpdir');
  
  my $output = $fastq;
  $output =~ s/\.fq$/.bam/;
  
  my $bwt_reference = $reference.'.bwt';
  $self->throw("Cannot find a BWT index file at '${bwt_reference}'. You may need to index your FASTA file") if ! -f $bwt_reference;

  # Single command line to align a FASTQ SE file, convert into BAM and sort
  my $cmd_line = qq{${bwa} mem -t ${threads} ${reference} ${fastq} | ${samtools} view -b - | ${samtools} sort -O bam -T ${tmpdir} > ${output}};
  $self->run_command_line($cmd_line);
  $self->param('bam', $output);
  
  return;
}

1;