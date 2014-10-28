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
package FastqAlign::Base;

use strict;
use warnings;
use parent qw/Bio::EnsEMBL::Hive::Process/;

use File::Spec;

sub param_defaults {
  return {
    tmpdir => File::Spec->tmpdir(),
  };
}

sub run_command_line {
  my ($self, $cmd_line) = @_;
  system($cmd_line);
  my $rc = $? >> 8;
  if($rc != 0) {
    $self->throw("Could not run command '${cmd_line}' with return code ${rc}: $!");
  }
  return $rc;
}

1;