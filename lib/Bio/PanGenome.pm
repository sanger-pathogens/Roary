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

sub run {
    my ($self) = @_;

    my $output_combined_filename         = '_combined_files';
    my $output_cd_hit_filename           = '_clustered';
    my $output_blast_results_filename    = '_blast_results';
    my $output_mcl_filename              = '_uninflated_mcl_groups';
    my $output_inflate_clusters_filename = '_inflated_mcl_groups';
    my $output_group_labels_filename     = '_labeled_mcl_groups';

    my $combine_fasta_files = Bio::PanGenome::CombinedProteome->new(
        proteome_files        => $self->fasta_files,
        output_filename       => $output_combined_filename,
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

    my $inflate_clusters = Bio::PanGenome::InflateClusters->new(
        clusters_filename => $cdhit_obj->clusters_filename,
        mcl_filename      => $output_mcl_filename,
        output_file       => $output_inflate_clusters_filename
    );
    $inflate_clusters->inflate();

    my $group_labels = Bio::PanGenome::GroupLabels->new(
        groups_filename => $output_inflate_clusters_filename,
        output_filename => $output_group_labels_filename
    );
    $group_labels->add_labels();

    my $analyse_groups_obj = Bio::PanGenome::AnalyseGroups->new(
        fasta_files     => $self->fasta_files,
        groups_filename => $output_group_labels_filename
    );
    $analyse_groups_obj->create_plots();

    my $annotate_groups = Bio::PanGenome::AnnotateGroups->new(
        gff_files       => $self->input_files,
        output_filename => $self->output_filename,
        groups_filename => $output_group_labels_filename,
    );
    $annotate_groups->reannotate;

    my $group_statistics = Bio::PanGenome::GroupStatistics->new(
        output_filename     => $self->output_statistics_filename,
        annotate_groups_obj => $annotate_groups,
        analyse_groups_obj  => $analyse_groups_obj
    );
    $group_statistics->create_spreadsheet;

    my $one_gene_per_fasta = Bio::PanGenome::Output::OneGenePerGroupFasta->new(
        analyse_groups  => $analyse_groups_obj,
        output_filename => $self->output_pan_geneome_filename
    );
    $one_gene_per_fasta->create_file();

    unlink($output_blast_results_filename);
    unlink($output_combined_filename);
    unlink($output_cd_hit_filename);
    unlink($output_mcl_filename);
    unlink($output_inflate_clusters_filename);
    unlink($output_group_labels_filename);
    unlink( $output_cd_hit_filename . '.clstr' );
    unlink( $output_cd_hit_filename . '.bak.clstr' );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
