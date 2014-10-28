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