=head1 LICENSE

Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut
package FastqAlign::MergeBAMs;

use strict;
use warnings;
use parent qw/FastqAlign::Base/;

sub run {
  my ($self) = @_;
  my $fastq = $self->param_required('fastq');
  my $bams = $self->param_required('bams');
  $bams = (ref($bams) eq 'ARRAY') ? $bams : [$bams];
  my $samtools = $self->param_required('samtools');
  my $tmpdir = $self->param_required('tmpdir');
  
  # create a name which is the same as the input but with .bam
  my $output = $fastq;
  $output =~ s/\.fq(?:\.gz)?$/.bam/;
  my $input = join(q{ }, @{$bams});
  
  if(scalar(@{$bams}) == 1) {
    $self->run_command_line(qq{cp $input $output});
  }
  else {
    # Single command line to merge all sorted bams into a single one
    my $cmd_line = qq{${samtools} merge ${output} ${input}};
    $self->run_command_line($cmd_line);
  }
  
  $self->param('bam', $output);
  
  return;
}

1;