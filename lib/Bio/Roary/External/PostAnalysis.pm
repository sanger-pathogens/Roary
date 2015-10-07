package Bio::Roary::External::PostAnalysis;

# ABSTRACT: Perform the post analysis

=head1 SYNOPSIS

Perform the post analysis 

   use Bio::Roary::External::PostAnalysis;
   
   my $seg= Bio::Roary::External::PostAnalysis->new(
     fasta_file => 'contigs.fa',
   );
   
   $seg->run();

=cut

use Moose;
use Cwd  qw(getcwd); 
with 'Bio::Roary::JobRunner::Role';

has 'input_files'                 => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'exec'                        => ( is => 'ro', isa => 'Str', default  => 'pan_genome_post_analysis' );
has 'fasta_files'                 => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output_filename'             => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_pan_geneome_filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_statistics_filename'  => ( is => 'ro', isa => 'Str', required => 1 );
has 'clusters_filename'           => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_multifasta_files'     => ( is => 'ro', isa => 'Bool', required => 1 );
has 'dont_delete_files'           => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'dont_split_groups'           => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'verbose_stats'               => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'translation_table'           => ( is => 'rw', isa => 'Int',  default  => 11 );
has 'group_limit'                 => ( is => 'rw', isa => 'Num',  default  => 50000 );
has 'core_definition'             => ( is => 'ro', isa => 'Num',  default  => 1.0 );
has 'verbose'                     => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'mafft'                       => ( is => 'ro', isa => 'Bool', default  => 0 );
has '_working_directory'          => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_gff_fofn'                   => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__gff_fofn' );
has '_fasta_fofn'                 => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__fasta_fofn'  );

# Overload Role
has 'memory_in_mb' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build_memory_in_mb' );
has '_minimum_memory_mb'    => ( is => 'ro', isa => 'Int', default => 4000 );
has '_memory_per_sample_mb' => ( is => 'ro', isa => 'Int', default => 30 );
has '_queue'                => ( is => 'rw', isa => 'Str',  lazy => 1, builder => '_build__queue');


sub _build__queue {
    my ($self) = @_;
    my $queue = 'normal';
    my $num_samples = @{ $self->input_files };
    if($num_samples > 200)
    {
      $queue = 'long';
    }
    elsif($num_samples > 600)
    {
      $queue = 'basement';
    }
    return $queue;
}


sub _build_memory_in_mb {
    my ($self) = @_;
    my $num_samples = @{ $self->input_files };

    my $memory_required = $num_samples * $self->_memory_per_sample_mb;
    if ( $memory_required < $self->_minimum_memory_mb ) {
        $memory_required = $self->_minimum_memory_mb;
    }

    return $memory_required;
}

sub _build__gff_fofn
{
    my ($self) = @_;
    return join('/', ($self->_working_directory, '/_gff_files'));
}

sub _build__fasta_fofn
{
    my ($self) = @_;
    return join('/', ($self->_working_directory, '/_fasta_files'));
}


sub _output_gff_files
{
  my ($self) = @_;
  open(my $out_fh, '>', $self->_gff_fofn);
  for my $filename (@{$self->input_files})
  {
    print {$out_fh} $filename."\n";
  }
  close($out_fh);
}

sub _output_fasta_files
{
  my ($self) = @_;
  open(my $out_fh, '>', $self->_fasta_fofn);
  for my $filename (@{$self->fasta_files})
  {
    print {$out_fh} $filename."\n";
  }
  close($out_fh);
}

sub _command_to_run {
    my ($self) = @_;
    
    $self->_output_fasta_files;
    $self->_output_gff_files;
    
    my $output_multifasta_files_flag = '';
    $output_multifasta_files_flag = '--output_multifasta_files' if(defined($self->output_multifasta_files) && $self->output_multifasta_files == 1);

    my $dont_delete_files_flag = '';
    $dont_delete_files_flag = '--dont_delete_files' if(defined($self->dont_delete_files) && $self->dont_delete_files == 1);
    
    my $dont_create_rplots_flag = '';
    $dont_create_rplots_flag = '--dont_create_rplots' if(defined($self->dont_create_rplots) && $self->dont_create_rplots == 1);
    
    my $dont_split_groups_flag = '';
    $dont_split_groups_flag = '--dont_split_groups' if ( defined $self->dont_split_groups && $self->dont_split_groups == 1 );

    my $verbose_stats_flag = '';
    $verbose_stats_flag = '--verbose_stats' if ( defined($self->verbose_stats) && $self->verbose_stats == 1 );
	
    my $mafft_flag = '';
    $mafft_flag = '--mafft' if ( defined($self->mafft) && $self->mafft == 1 );
	
    my $verbose_flag = '';
    $verbose_flag = '-v' if ( defined($self->verbose) && $self->verbose == 1 );
    
    return join(
        " ",
        (
            $self->exec,
            '-o', $self->output_filename,
            '-p', $self->output_pan_geneome_filename,
            '-s', $self->output_statistics_filename,
            '-c', $self->clusters_filename,
            $output_multifasta_files_flag,
            '-i', $self->_gff_fofn,
            '-f', $self->_fasta_fofn,
            '-t', $self->translation_table,
            $dont_delete_files_flag,
            $dont_create_rplots_flag,
            $dont_split_groups_flag,
            $verbose_stats_flag,
			$verbose_flag,
			$mafft_flag,
            '-j', $self->job_runner,
            '--processors', $self->cpus,
            '--group_limit', $self->group_limit,
            '-cd', ($self->core_definition*100)
        )
    );
}

sub run {
    my ($self) = @_;

    my @commands_to_run;
    push( @commands_to_run, $self->_command_to_run );
    $self->logger->info( "Running command: " . $self->_command_to_run() );
    my $job_runner_obj = $self->_job_runner_class->new(
        commands_to_run => \@commands_to_run,
        memory_in_mb    => $self->memory_in_mb,
        queue           => $self->_queue,
        dont_wait       => $self->dont_wait,
        cpus            => $self->cpus 
    );
    $job_runner_obj->run();

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
