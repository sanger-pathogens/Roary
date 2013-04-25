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

has 'fasta_files'      => ( is => 'rw', isa => 'ArrayRef' );
has 'output_filename'  => ( is => 'rw', isa => 'Str', default => 'clustered_proteins' );
has 'job_runner'       => ( is => 'rw', isa => 'Str', default => 'LSF' );
has 'makeblastdb_exec' => ( is => 'rw', isa => 'Str', default => 'makeblastdb' );
has 'blastp_exec'      => ( is => 'rw', isa => 'Str', default => 'blastp' );
has 'mcxdeblast_exec'  => ( is => 'ro', isa => 'Str', default => 'mcxdeblast' );
has 'mcl_exec'         => ( is => 'ro', isa => 'Str', default => 'mcl' );

sub run {
    my ($self) = @_;

    my $output_combined_filename      = 'combined_files';
    my $output_cd_hit_filename        = 'clustered';
    my $output_blast_results_filename = 'blast_results';
    my $output_mcl_filename           = 'uninflated_mcl_groups';

    my $combine_fasta_files = Bio::PanGenome::CombinedProteome->new(
        proteome_files        => $self->fasta_files,
        output_filename       => $output_combined_filename,
        apply_unknowns_filter => 1
    );
    $combine_fasta_files->create_combined_proteome_file;

    my $cdhit_obj = Bio::PanGenome::External::Cdhit->new(
        input_file  => $output_combined_filename,
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
        output_file     => $output_mcl_filename
    );
    $mcl->run();
    
    my $inflate_clusters = Bio::PanGenome::InflateClusters->new(
      clusters_filename  => $cdhit_obj->clusters_filename,
      mcl_filename       => $output_mcl_filename,
      output_file        => $self->output_filename
    );
    $inflate_clusters->inflate();
    
    my $analyse_groups_obj = Bio::PanGenome::AnalyseGroups->new(
        fasta_files      => $self->fasta_files,
        groups_filename  => $self->output_filename
      );
    $analyse_groups_obj->create_plots();
    
    

    unlink($output_blast_results_filename);
    unlink($output_combined_filename);
    unlink($output_cd_hit_filename );
    unlink($output_mcl_filename );
    
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
