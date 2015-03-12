package Bio::PanGenome::PostAnalysis;

# ABSTRACT: Post analysis of pan genomes

=head1 SYNOPSIS

Create a pan genome

=cut

use Moose;
use File::Copy;
use Bio::PanGenome::InflateClusters;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::GroupLabels;
use Bio::PanGenome::AnnotateGroups;
use Bio::PanGenome::GroupStatistics;
use Bio::PanGenome::Output::GroupsMultifastasNucleotide;
use Bio::PanGenome::Output::NumberOfGroups;
use Bio::PanGenome::OrderGenes;
use Bio::PanGenome::Output::EmblGroups;
use Bio::PanGenome::SplitGroups;

has 'fasta_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'input_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'output_filename'             => ( is => 'rw', isa => 'Str',      default  => 'clustered_proteins' );
has 'output_pan_geneome_filename' => ( is => 'rw', isa => 'Str',      default  => 'pan_genome.fa' );
has 'output_statistics_filename'  => ( is => 'rw', isa => 'Str',      default  => 'gene_presence_absence.csv' );
has 'output_multifasta_files'     => ( is => 'ro', isa => 'Bool',     default  => 0 );

has 'clusters_filename'           => ( is => 'rw', isa => 'Str',      required => 1 );
has 'dont_delete_files'           => ( is => 'ro', isa => 'Bool',     default  => 0 );
has 'dont_split_groups'           => ( is => 'ro', isa => 'Bool',     default  => 0 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool',     default => 1 );
has 'group_limit'                 => ( is => 'rw', isa => 'Num',      default => 50000 );

has '_output_mcl_filename'               => ( is => 'ro', isa => 'Str', default  => '_uninflated_mcl_groups' );
has '_output_inflate_unsplit_clusters_filename'  => ( is => 'ro', isa => 'Str', default  => '_inflated_unsplit_mcl_groups' );
has '_output_inflate_clusters_filename'  => ( is => 'ro', isa => 'Str', default  => '_inflated_mcl_groups' );
has '_output_group_labels_filename'      => ( is => 'ro', isa => 'Str', default  => '_labeled_mcl_groups' );
has '_output_combined_filename'          => ( is => 'ro', isa => 'Str', default  => '_combined_files' );
has '_input_cd_hit_groups_file'          => ( is => 'ro', isa => 'Str', default  => '_combined_files.groups' );
has 'core_accessory_tab_output_filename' => ( is => 'ro', isa => 'Str', default  => 'core_accessory.tab' );
has 'accessory_tab_output_filename'      => ( is => 'ro', isa => 'Str', default  => 'accessory.tab' );
has 'core_accessory_ordering_key'        => ( is => 'ro', isa => 'Str', default  => 'core_accessory_overall_order_filtered' );
has 'accessory_ordering_key'             => ( is => 'ro', isa => 'Str', default  => 'accessory_overall_order_filtered' );
has 'core_definition'                    => ( is => 'ro', isa => 'Num', default  => 1.0 );

has '_inflate_clusters_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::InflateClusters',        lazy => 1, builder => '_build__inflate_clusters_obj' );
has '_group_labels_obj'      => ( is => 'ro', isa => 'Bio::PanGenome::GroupLabels',            lazy => 1, builder => '_build__group_labels_obj' );
has '_annotate_groups_obj'   => ( is => 'ro', isa => 'Bio::PanGenome::AnnotateGroups',         lazy => 1, builder => '_build__annotate_groups_obj' );
has '_analyse_groups_obj'    => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups',          lazy => 1, builder => '_build__analyse_groups_obj' );
has '_order_genes_obj'       => ( is => 'ro', isa => 'Bio::PanGenome::OrderGenes',             lazy => 1, builder => '_build__order_genes_obj' );
has '_group_statistics_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::GroupStatistics',        lazy => 1, builder => '_build__group_statistics_obj' );
has '_number_of_groups_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::Output::NumberOfGroups', lazy => 1, builder => '_build__number_of_groups_obj' );
has '_groups_multifastas_nuc_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::Output::GroupsMultifastasNucleotide', lazy => 1, builder => '_build__groups_multifastas_nuc_obj' );
has '_split_groups_obj'      => ( is => 'ro', isa => 'Bio::PanGenome::SplitGroups', lazy_build => 1 );

has 'verbose_stats' => ( is => 'rw', isa => 'Bool', default => 0 ); 

sub run {
    my ($self) = @_;

    $self->_inflate_clusters_obj->inflate();

    ## SPLIT GROUPS WITH PARALOGS ##
    if ( $self->dont_split_groups ){
      move( $self->_output_inflate_unsplit_clusters_filename, $self->_output_inflate_clusters_filename );
    }
    else {
      $self->_split_groups_obj->split_groups;
    }

    $self->_group_labels_obj->add_labels();
    $self->_annotate_groups_obj->reannotate;
    $self->_group_statistics_obj->create_spreadsheet;
    $self->_number_of_groups_obj->create_output_files;
    system("create_pan_genome_plots.R") unless($self->dont_create_rplots == 1);
    $self->_create_embl_files;
    
    $self->_groups_multifastas_nuc_obj->create_files() if($self->output_multifasta_files);

    $self->_delete_intermediate_files;
}

sub _build__split_groups_obj {
  my ( $self ) = @_;
  return Bio::PanGenome::SplitGroups->new(
    groupfile   => $self->_output_inflate_unsplit_clusters_filename,
    gff_files   => $self->input_files,
    fasta_files => $self->fasta_files,
    outfile     => $self->_output_inflate_clusters_filename,
    dont_delete => $self->dont_delete_files
  );
}

sub _build__number_of_groups_obj
{
  my ($self) = @_;
  return Bio::PanGenome::Output::NumberOfGroups->new(
    group_statistics_obj => $self->_group_statistics_obj,
    groups_to_contigs    => $self->_order_genes_obj->groups_to_contigs,
    annotate_groups_obj  => $self->_annotate_groups_obj,
  );
}

sub _build__group_statistics_obj
{
  my ($self) = @_;
  return Bio::PanGenome::GroupStatistics->new(
      output_filename     => $self->output_statistics_filename,
      annotate_groups_obj => $self->_annotate_groups_obj,
      analyse_groups_obj  => $self->_analyse_groups_obj,
      groups_to_contigs   => $self->_order_genes_obj->groups_to_contigs,
      _verbose            => $self->verbose_stats,
  );
}


sub _build__order_genes_obj
{
  my ($self) = @_;
  return Bio::PanGenome::OrderGenes->new(
    analyse_groups_obj => $self->_analyse_groups_obj,
    gff_files          => $self->input_files,
  );
}



sub _build__group_labels_obj
{
  my ($self) = @_;
  return Bio::PanGenome::GroupLabels->new(
      groups_filename => $self->_output_inflate_clusters_filename,
      output_filename => $self->_output_group_labels_filename
  );
}

sub _build__annotate_groups_obj
{
   my ($self) = @_;
   return  Bio::PanGenome::AnnotateGroups->new(
       gff_files       => $self->input_files,
       output_filename => $self->output_filename,
       groups_filename => $self->_output_group_labels_filename,
   );
}

sub _build__analyse_groups_obj
{
  my ($self) = @_;
  return Bio::PanGenome::AnalyseGroups->new(
      fasta_files     => $self->fasta_files,
      groups_filename => $self->output_filename
  );
}

sub _build__inflate_clusters_obj
{
  my ($self) = @_;
  return Bio::PanGenome::InflateClusters->new(
      clusters_filename     => $self->clusters_filename,
      cdhit_groups_filename => $self->_input_cd_hit_groups_file,
      mcl_filename          => $self->_output_mcl_filename,
      output_file           => $self->_output_inflate_unsplit_clusters_filename
  );
}


sub _build__groups_multifastas_nuc_obj
{
  my ($self) = @_;
  return Bio::PanGenome::Output::GroupsMultifastasNucleotide->new(
      output_multifasta_files  => $self->output_multifasta_files,
      gff_files       => $self->input_files,
      annotate_groups => $self->_annotate_groups_obj,
      group_names     => $self->_analyse_groups_obj->_groups,
      group_limit     => $self->group_limit
    );
}

sub _create_embl_files
{
  my ($self) = @_;
  my $core_accessory_tab_obj = Bio::PanGenome::Output::EmblGroups->new(
    output_filename     => $self->core_accessory_tab_output_filename,
    annotate_groups_obj => $self->_annotate_groups_obj,
    analyse_groups_obj  => $self->_analyse_groups_obj,
    ordering_key        => $self->core_accessory_ordering_key,
    groups_to_contigs   => $self->_order_genes_obj->groups_to_contigs
  );
  $core_accessory_tab_obj->create_files;
  
  my $accessory_tab_obj = Bio::PanGenome::Output::EmblGroups->new(
    output_filename     => $self->accessory_tab_output_filename,
    annotate_groups_obj => $self->_annotate_groups_obj,
    analyse_groups_obj  => $self->_analyse_groups_obj,
    ordering_key        => $self->accessory_ordering_key,
    groups_to_contigs   => $self->_order_genes_obj->groups_to_contigs
  );
  $accessory_tab_obj->create_files;
}

sub _delete_intermediate_files
{
  my ($self) = @_;
  return if($self->dont_delete_files == 1);
  
  unlink($self->_output_mcl_filename)              ;
  unlink($self->_output_inflate_clusters_filename) ;
  unlink($self->_output_group_labels_filename)     ;
  unlink($self->_output_combined_filename)         ;
  unlink($self->clusters_filename)                 ;
  unlink($self->clusters_filename . '.clstr' )     ;
  unlink($self->clusters_filename . '.bak.clstr' ) ;
  unlink('_gff_files')                             ;
  unlink('_fasta_files')                           ;
  unlink('_clustered_filtered.fa')                 ;
  unlink($self->_input_cd_hit_groups_file)         ;
  unlink('database_masking.asnb')                  ;
  unlink('_clustered')                             ;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
