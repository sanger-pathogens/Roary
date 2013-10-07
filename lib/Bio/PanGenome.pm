package Bio::PanGenome;

# ABSTRACT: Create a pan genome

=head1 SYNOPSIS

Create a pan genome

=cut

use Moose;
use Bio::PanGenome::ParallelAllAgainstAllBlast;
use Bio::PanGenome::CombinedProteome;
use Bio::PanGenome::External::Cdhit;
use Bio::PanGenome::External::Mcl;
use Bio::PanGenome::InflateClusters;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::GroupLabels;
use Bio::PanGenome::AnnotateGroups;
use Bio::PanGenome::Output::OneGenePerGroupFasta;
use Bio::PanGenome::GroupStatistics;
use Bio::PanGenome::Output::GroupsMultifastasNucleotide;
use Bio::PanGenome::External::PostAnalysis;

has 'fasta_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'input_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'output_filename'             => ( is => 'rw', isa => 'Str',      default  => 'clustered_proteins' );
has 'output_pan_geneome_filename' => ( is => 'rw', isa => 'Str',      default  => 'pan_genome.fa' );
has 'output_statistics_filename'  => ( is => 'rw', isa => 'Str',      default  => 'group_statisics.csv' );
has 'job_runner'                  => ( is => 'rw', isa => 'Str',      default  => 'LSF' );
has 'makeblastdb_exec'            => ( is => 'rw', isa => 'Str',      default  => 'makeblastdb' );
has 'blastp_exec'                 => ( is => 'rw', isa => 'Str',      default  => 'blastp' );
has 'mcxdeblast_exec'             => ( is => 'ro', isa => 'Str',      default  => 'mcxdeblast' );
has 'mcl_exec'                    => ( is => 'ro', isa => 'Str',      default  => 'mcl' );

has 'output_multifasta_files' => ( is => 'ro', isa => 'Bool', default => 0 );

sub run {
    my ($self) = @_;

    my $output_combined_filename      = '_combined_files';
    my $output_cd_hit_filename        = '_clustered';
    my $output_blast_results_filename = '_blast_results';
    my $output_mcl_filename           = '_uninflated_mcl_groups';

    my $combine_fasta_files = Bio::PanGenome::CombinedProteome->new(
        proteome_files  => $self->fasta_files,
        output_filename => $output_combined_filename,
    );
    $combine_fasta_files->create_combined_proteome_file;

    my $cdhit_obj = Bio::PanGenome::External::Cdhit->new(
        input_file  => $output_combined_filename,
        job_runner  => $self->job_runner,
        output_base => $output_cd_hit_filename
    );
    $cdhit_obj->run();

    my $blast_obj = Bio::PanGenome::ParallelAllAgainstAllBlast->new(
        fasta_file              => $output_cd_hit_filename,
        blast_results_file_name => $output_blast_results_filename,
        job_runner              => $self->job_runner,
        makeblastdb_exec        => $self->makeblastdb_exec,
        blastp_exec             => $self->blastp_exec
    );
    $blast_obj->run();

    my $mcl = Bio::PanGenome::External::Mcl->new(
        blast_results   => $output_blast_results_filename,
        mcxdeblast_exec => $self->mcxdeblast_exec,
        mcl_exec        => $self->mcl_exec,
        job_runner      => $self->job_runner,
        output_file     => $output_mcl_filename
    );
    $mcl->run();

    unlink($output_blast_results_filename);
    

    my $post_analysis = Bio::PanGenome::External::PostAnalysis->new(
        job_runner                  => $self->job_runner,
        fasta_files                 => $self->fasta_files,
        input_files                 => $self->input_files,
        output_filename             => $self->output_filename,
        output_pan_geneome_filename => $self->output_pan_geneome_filename,
        output_statistics_filename  => $self->output_statistics_filename,
        clusters_filename           => $cdhit_obj->clusters_filename,
        dont_wait                   => 1,
        output_multifasta_files     => $self->output_multifasta_files,
    );
    $post_analysis->run();

}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
