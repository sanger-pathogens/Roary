package Bio::PanGenome;

# ABSTRACT: Create a pan genome

=head1 SYNOPSIS

Create a pan genome

=cut

use Moose;
use File::Copy;
use Bio::PanGenome::ParallelAllAgainstAllBlast;
use Bio::PanGenome::CombinedProteome;
use Bio::PanGenome::External::Cdhit;
use Bio::PanGenome::External::Mcl;
use Bio::PanGenome::InflateClusters;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::GroupLabels;
use Bio::PanGenome::AnnotateGroups;
use Bio::PanGenome::GroupStatistics;
use Bio::PanGenome::Output::GroupsMultifastasNucleotide;
use Bio::PanGenome::External::PostAnalysis;
use Bio::PanGenome::FilterFullClusters;
use Bio::PanGenome::External::IterativeCdhit;
use Bio::PanGenome::Output::BlastIdentityFrequency;

has 'fasta_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'input_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'output_filename'             => ( is => 'rw', isa => 'Str',      default  => 'clustered_proteins' );
has 'output_pan_geneome_filename' => ( is => 'rw', isa => 'Str',      default  => 'pan_genome.fa' );
has 'output_statistics_filename'  => ( is => 'rw', isa => 'Str',      default  => 'gene_presence_absence.csv' );
has 'job_runner'                  => ( is => 'rw', isa => 'Str',      default  => 'LSF' );
has 'cpus'                        => ( is => 'ro', isa => 'Int',      default => 1 );
has 'makeblastdb_exec'            => ( is => 'rw', isa => 'Str',      default  => 'makeblastdb' );
has 'blastp_exec'                 => ( is => 'rw', isa => 'Str',      default  => 'blastp' );
has 'mcxdeblast_exec'             => ( is => 'ro', isa => 'Str',      default  => 'mcxdeblast' );
has 'mcl_exec'                    => ( is => 'ro', isa => 'Str',      default  => 'mcl' );
has 'perc_identity'               => ( is => 'ro', isa => 'Num',      default  => 98 );
has 'dont_delete_files'           => ( is => 'ro', isa => 'Bool',     default  => 0 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'verbose_stats'               => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'translation_table'           => ( is => 'rw', isa => 'Int',      default  => 11 );
has 'group_limit'                 => ( is => 'rw', isa => 'Num',      default  => 50000 );

has 'output_multifasta_files' => ( is => 'ro', isa => 'Bool', default => 0 );

sub run {
    my ($self) = @_;

    my $output_combined_filename      = '_combined_files';
    my $output_cd_hit_filename        = '_clustered';
    my $output_blast_results_filename = '_blast_results';
    my $output_mcl_filename           = '_uninflated_mcl_groups';
    my $output_filtered_clustered_fasta  = '_clustered_filtered.fa';
    my $cdhit_groups = $output_combined_filename.'.groups';
    
    
    unlink($cdhit_groups) unless($self->dont_delete_files == 1);

    my $combine_fasta_files = Bio::PanGenome::CombinedProteome->new(
        proteome_files  => $self->fasta_files,
        output_filename => $output_combined_filename,
    );
    $combine_fasta_files->create_combined_proteome_file;

    my $number_of_input_files = @{$self->input_files};

    my $iterative_cdhit= Bio::PanGenome::External::IterativeCdhit->new(
      output_cd_hit_filename           => $output_cd_hit_filename,
      output_combined_filename         => $output_combined_filename,
      number_of_input_files            => $number_of_input_files, 
      output_filtered_clustered_fasta  => $output_filtered_clustered_fasta,
      job_runner                       => $self->job_runner,
      cpus                             => $self->cpus
    );
    
    $iterative_cdhit->run();

    my $blast_obj = Bio::PanGenome::ParallelAllAgainstAllBlast->new(
        fasta_file              => $output_cd_hit_filename,
        blast_results_file_name => $output_blast_results_filename,
        job_runner              => $self->job_runner,
        cpus                    => $self->cpus,
        makeblastdb_exec        => $self->makeblastdb_exec,
        blastp_exec             => $self->blastp_exec,
        perc_identity           => $self->perc_identity
    );
    $blast_obj->run();
    
    my $blast_identity_frequency_obj = Bio::PanGenome::Output::BlastIdentityFrequency->new(
        input_filename      => $output_blast_results_filename,
      );
    $blast_identity_frequency_obj->create_file();

    my $mcl = Bio::PanGenome::External::Mcl->new(
        blast_results   => $output_blast_results_filename,
        mcxdeblast_exec => $self->mcxdeblast_exec,
        mcl_exec        => $self->mcl_exec,
        job_runner      => $self->job_runner,
        cpus            => $self->cpus,
        output_file     => $output_mcl_filename
    );
    $mcl->run();

    unlink($output_blast_results_filename) unless($self->dont_delete_files == 1);
    

    my $post_analysis = Bio::PanGenome::External::PostAnalysis->new(
        job_runner                  => $self->job_runner,
        cpus                        => $self->cpus,
        fasta_files                 => $self->fasta_files,
        input_files                 => $self->input_files,
        output_filename             => $self->output_filename,
        output_pan_geneome_filename => $self->output_pan_geneome_filename,
        output_statistics_filename  => $self->output_statistics_filename,
        clusters_filename           => $output_cd_hit_filename.'.clstr',
        dont_wait                   => 1,
        output_multifasta_files     => $self->output_multifasta_files,
        dont_delete_files           => $self->dont_delete_files,
        dont_create_rplots          => $self->dont_create_rplots,
        verbose_stats               => $self->verbose_stats,
        translation_table           => $self->translation_table,
        group_limit                 => $self->group_limit,
    );
    $post_analysis->run();

}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
