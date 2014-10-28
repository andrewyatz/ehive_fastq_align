package FastqAlign::FastqAlign_conf;

use strict;
use warnings;

use parent qw/Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf/;

sub default_options {
  my ($self) = @_;
  return {
    %{$self->SUPER::default_options()},
    
    #### User parameters

    # directory => '', # location of fastq files
    # reference => '', # location of a single index file for BWA to use
    
    #### Defaults
    pipeline_name => 'FastqAlign',
    samtools => 'samtools', # samtools binary location
    bwa => 'bwa', #bwa binary location
    
    # Number of records to split fastq files into
    max_records => 2500,
    
    # bwa defaults
    bwa_threads => 1,
    
    # lsf default
    lsf_queue => 'normal',
  };
}

sub pipeline_analyses {
  my ($self) = @_;
  return [
  
    {
      -logic_name => 'create_bwt',
      -module => 'FastqAlign::IndexFasta',
      -input_ids => [{ reference => $self->o('reference') }],
      -flow_into => {1 => {'fastq_factory' => { 'index' => '#index#' } }},
    },
    
    {
      -logic_name => 'fastq_factory',
      -module => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
      -parameters => {
        inputcmd => q{find #directory# -type f -name '*.fq.gz'},
        column_names => [qw/fastq/],
      },
      -flow_into => { 2 => { split_factory => { fastq_in => '#fastq#', index => '#index#' } } }
    },
    
    {
      -logic_name => 'split_factory',
      -module => 'FastqAlign::SplitFastq',
      -parameters => {
        max_records => $self->o('max_records'),
      },
      -flow_into => {
        '2->A' => { bwa => { 'fastq' => '#fastq#', index => '#index#' } },
        'A->1' => { merge_bams => { 'fastq' => '#fastq_in#' } },
      }
    },
    
    {
      -logic_name => 'bwa',
      -module => 'FastqAlign::BWA',
      -parameters => {
        threads => $self->o('bwa_threads'),
      },
      -rc_name => 'bwa',
      # Note about accumulators. The accumulator key (bams=[]) needs a
      # hash with the same key. This is how it knows what to flow
      # into the accumulator i.e.
      #                 The accumulator key    Repeated Key       Value to insert
      #                                   |            |          |
      -flow_into => { 1 => { ':////accu?bams=[]' => { bams =>  '#bam#' }}}
    },
    
    {
      -logic_name => 'merge_bams',
      -module => 'FastqAlign::MergeBAMs',
      -flow_into => { 1 => {'index_bam' => {'bam' => '#bam#'}}},
    },
    
    {
      -logic_name => 'index_bam',
      -module => 'FastqAlign::IndexBAM',
    },
    
  ];
}

sub pipeline_wide_parameters {
  my ($self) = @_;
  return {
    %{$self->SUPER::pipeline_wide_parameters()},
    directory => $self->o('directory'),
    samtools => $self->o('samtools'),
    bwa => $self->o('bwa'),
  };
}

sub resource_classes {
  my ($self) = @_;
  return {
    %{$self->SUPER::resource_classes()},
    'default' => { LSF => '-R"select[mem>100] rusage[mem=100]" -q '.$self->o('lsf_queue') },
    'bwa' => { LSF => '-R"select[mem>1000] rusage[mem=1000]"-q '.$self->o('lsf_queue') }
  };
}

1;