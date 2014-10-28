package FastqAlign::SplitFastq;

use strict;
use warnings;
use parent qw/Bio::EnsEMBL::Hive::RunnableDB::JobFactory/;

use PerlIO::gzip;
use File::Spec;

sub param_defaults {
  my ($self) = @_;
  return {
    %{$self->SUPER::param_defaults()},
    max_records => 2500,
    column_names => ['fastq']
  };
}

sub fetch_input {
  my ($self) = @_;
  my $directory = $self->param_required('directory');
  my $fastq = $self->param_required('fastq_in');
  my $max_records = $self->param_required('max_records');
  
  $self->throw("Cannot find the file '${fastq}'") if ! -e $fastq;
  $self->throw("File '${fastq}' is not a file") if ! -f $fastq;
  
  $self->process_file($fastq, $directory, $max_records);
  return;
}

# sub write_output {
#   my ($self) = @_;
#   # Flow original file to branch 1
#   $self->dataflow_output_id({fastq => $self->param('fastq')}, 1);
#   # Manually flow to bwa (branch 2) with a fastq file per output  
#   $self->dataflow_output_id($self->param('output'), 2);
#   return;
# }

sub process_file {
  my ($self, $fastq, $directory, $max_records) = @_;
  my @output;
  open my $in_fh, '<:gzip', $fastq or $self->throw("Cannot open '${fastq}' for reading: $!");
  my $out_fh;
  my $out_file_count = 0;
  my $record_count = 0;
  while(my $line = <$in_fh>) {
    
    if(index($line, '@') == 0) {
      $record_count++;
    }
    
    if($record_count > $max_records) {
      close $out_fh or $self->throw("Cannot close output filehandle: $!");
      undef $out_fh;
      $record_count = 1;
    }
    
    if(! defined $out_fh) {
      $out_file_count++;
      my ($vol, $dir, $file) = File::Spec->splitpath($fastq);
      my $out_filename = sprintf('%05d.%s', $out_file_count, $file);
      $out_filename =~ s/\.gz$//;
      my $out_file = File::Spec->catpath(undef, $directory, $out_filename);
      open $out_fh, '>', $out_file or $self->throw("Cannot open '${out_file}' for writing: $!");
      # push(@output, { fastq => $out_file });
      push(@output, $out_file);
    }
    
    print $out_fh $line;
  }
  
  close $in_fh or $self->throw("Cannot close '${fastq}' after reading: $!");
  if(defined $out_fh) {
    close $out_fh or $self->throw("Cannot close output filehandle: $!");
  }
  
  $self->param('inputlist', \@output);
}

1;