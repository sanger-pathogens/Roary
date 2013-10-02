package Bio::PanGenome::External::PostAnalysis;

# ABSTRACT: Perform the post analysis

=head1 SYNOPSIS

Perform the post analysis 

   use Bio::PanGenome::External::PostAnalysis;
   
   my $seg= Bio::PanGenome::External::PostAnalysis->new(
     fasta_file => 'contigs.fa',
   );
   
   $seg->run();

=cut

use Moose;
with 'Bio::PanGenome::JobRunner::Role';

has 'input_files'                 => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'exec'                        => ( is => 'ro', isa => 'Str', default  => 'pan_genome_post_analysis' );
has 'fasta_files'                 => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output_filename'             => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_pan_geneome_filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_statistics_filename'  => ( is => 'ro', isa => 'Str', required => 1 );
has 'clusters_filename'           => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_multifasta_files'     => ( is => 'ro', isa => 'Bool', required => 1 );

# Overload Role
has '_memory_required_in_mb' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build__memory_required_in_mb' );
has '_minimum_memory_mb'    => ( is => 'ro', isa => 'Int', default => 1000 );
has '_memory_per_sample_mb' => ( is => 'ro', isa => 'Int', default => 100 );

sub _build__memory_required_in_mb {
    my ($self) = @_;
    my $num_samples = @{ $self->input_files };

    my $memory_required = $num_samples * $self->_memory_per_sample_mb;
    if ( $memory_required < $self->_minimum_memory_mb ) {
        $memory_required = $self->_minimum_memory_mb;
    }

    return $memory_required;
}

sub _command_to_run {
    my ($self) = @_;
    
    my $fasta_files_param = join(' -f ',@{$self->fasta_files});
    $fasta_files_param =  ' -f '.$fasta_files_param;
    
    my $input_files_param = join(' -i ',@{$self->input_files});
    $input_files_param =  ' -i '.$input_files_param;
    
    my $output_multifasta_files_flag = '';
    $output_multifasta_files_flag = '--output_multifasta_files' if(defined($self->output_multifasta_files) && $self->output_multifasta_files == 1);
    
    return join(
        " ",
        (
            $self->exec,
            '-o', $self->output_filename,
            '-p', $self->output_pan_geneome_filename,
            '-s', $self->output_statistics_filename,
            '-c', $self->clusters_filename,
            $output_multifasta_files_flag,
            $fasta_files_param,
            $input_files_param
        )
    );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;
    push( @commands_to_run, $self->_command_to_run );

    my $job_runner_obj = $self->_job_runner_class->new(
        commands_to_run => \@commands_to_run,
        memory_in_mb    => $self->_memory_required_in_mb,
        queue           => $self->_queue,
        dont_wait       => $self->dont_wait,
    );
    $job_runner_obj->run();

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
