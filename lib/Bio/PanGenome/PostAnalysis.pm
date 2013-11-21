package Bio::PanGenome::PostAnalysis;

# ABSTRACT: Post analysis of pan genomes

=head1 SYNOPSIS

Create a pan genome

=cut

use Moose;
use Bio::PanGenome::InflateClusters;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::GroupLabels;
use Bio::PanGenome::AnnotateGroups;
use Bio::PanGenome::Output::OneGenePerGroupFasta;
use Bio::PanGenome::GroupStatistics;
use Bio::PanGenome::Output::GroupsMultifastasNucleotide;
use Bio::PanGenome::Output::NumberOfGroups;
use Bio::PanGenome::OrderGenes;
use Bio::PanGenome::Output::EmblGroups;

has 'fasta_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'input_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'output_filename'             => ( is => 'rw', isa => 'Str',      default  => 'clustered_proteins' );
has 'output_pan_geneome_filename' => ( is => 'rw', isa => 'Str',      default  => 'pan_genome.fa' );
has 'output_statistics_filename'  => ( is => 'rw', isa => 'Str',      default  => 'group_statisics.csv' );
has 'output_multifasta_files'     => ( is => 'ro', isa => 'Bool',     default  => 0 );

has 'clusters_filename'           => ( is => 'rw', isa => 'Str',     required  => 1 );

sub run {
    my ($self) = @_;

    my $output_mcl_filename              = '_uninflated_mcl_groups';
    my $output_inflate_clusters_filename = '_inflated_mcl_groups';
    my $output_group_labels_filename     = '_labeled_mcl_groups';
    my $output_combined_filename         = '_combined_files';
    my $input_cd_hit_groups_file         = '_combined_files.groups';


    my $inflate_clusters = Bio::PanGenome::InflateClusters->new(
        clusters_filename => $self->clusters_filename,
        cdhit_groups_filename => $input_cd_hit_groups_file,
        mcl_filename      => $output_mcl_filename,
        output_file       => $output_inflate_clusters_filename
    );
    $inflate_clusters->inflate();

    my $group_labels = Bio::PanGenome::GroupLabels->new(
        groups_filename => $output_inflate_clusters_filename,
        output_filename => $output_group_labels_filename
    );
    $group_labels->add_labels();

    my $annotate_groups = Bio::PanGenome::AnnotateGroups->new(
        gff_files       => $self->input_files,
        output_filename => $self->output_filename,
        groups_filename => $output_group_labels_filename,
    );
    $annotate_groups->reannotate;

    my $analyse_groups_obj = Bio::PanGenome::AnalyseGroups->new(
        fasta_files     => $self->fasta_files,
        groups_filename => $self->output_filename
    );
    
    my $order_genes_obj = Bio::PanGenome::OrderGenes->new(
      analyse_groups_obj => $analyse_groups_obj,
      gff_files => $self->input_files,
    );
    $order_genes_obj->groups_to_contigs;
  
    my $one_gene_per_fasta = Bio::PanGenome::Output::OneGenePerGroupFasta->new(
        analyse_groups  => $analyse_groups_obj,
        output_filename => $self->output_pan_geneome_filename
    );
    $one_gene_per_fasta->create_file();

    my $group_statistics = Bio::PanGenome::GroupStatistics->new(
        output_filename     => $self->output_statistics_filename,
        annotate_groups_obj => $annotate_groups,
        analyse_groups_obj  => $analyse_groups_obj,
        groups_to_contigs   => $order_genes_obj->groups_to_contigs
    );
    $group_statistics->create_spreadsheet;
    
    my $gene_pool_expansion = Bio::PanGenome::Output::NumberOfGroups->new(
      group_statistics_obj => $group_statistics,
      groups_to_contigs    => $order_genes_obj->groups_to_contigs,
      annotate_groups_obj => $annotate_groups,
    );
    $gene_pool_expansion->create_output_files;
    
    my $core_accessory_tab_obj = Bio::PanGenome::Output::EmblGroups->new(
      output_filename     => 'core_accessory.tab',
      annotate_groups_obj => $annotate_groups,
      analyse_groups_obj  => $analyse_groups_obj,
      ordering_key        => 'core_accessory_overall_order_filtered',
      groups_to_contigs   => $order_genes_obj->groups_to_contigs
    );
    $core_accessory_tab_obj->create_files;
    
    my $accessory_tab_obj = Bio::PanGenome::Output::EmblGroups->new(
      output_filename     => 'accessory.tab',
      annotate_groups_obj => $annotate_groups,
      analyse_groups_obj  => $analyse_groups_obj,
      ordering_key        => 'accessory_overall_order_filtered',
      groups_to_contigs   => $order_genes_obj->groups_to_contigs
    );
    $accessory_tab_obj->create_files;

    if($self->output_multifasta_files)
    {
      my $group_multifastas_nucleotides = Bio::PanGenome::Output::GroupsMultifastasNucleotide->new(
          gff_files       => $self->input_files,
          annotate_groups => $annotate_groups,
          group_names     => $analyse_groups_obj->_groups
        );
      $group_multifastas_nucleotides->create_files();
    }

    unlink($output_mcl_filename);
    unlink($output_inflate_clusters_filename);
    unlink($output_group_labels_filename);
    unlink($output_combined_filename);
    unlink( $self->clusters_filename);
    unlink( $self->clusters_filename . '.clstr' );
    unlink( $self->clusters_filename . '.bak.clstr' );
    unlink('_gff_files');
    unlink('_fasta_files');
    unlink('_clustered_filtered.fa');
    unlink($input_cd_hit_groups_file);

}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
