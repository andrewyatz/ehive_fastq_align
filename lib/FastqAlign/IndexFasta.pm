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