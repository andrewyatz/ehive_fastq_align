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