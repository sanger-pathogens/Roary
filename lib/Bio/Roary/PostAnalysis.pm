package Bio::Roary::PostAnalysis;

# ABSTRACT: Post analysis of pan genomes

=head1 SYNOPSIS

Create a pan genome

=cut

use Moose;
use File::Copy;
use Bio::Roary::InflateClusters;
use Bio::Roary::AnalyseGroups;
use Bio::Roary::GroupLabels;
use Bio::Roary::AnnotateGroups;
use Bio::Roary::GroupStatistics;
use Bio::Roary::Output::GroupsMultifastasNucleotide;
use Bio::Roary::Output::NumberOfGroups;
use Bio::Roary::OrderGenes;
use Bio::Roary::Output::EmblGroups;
use Bio::Roary::SplitGroups;
use Bio::Roary::Output::OneGenePerGroupFasta;

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
has 'pan_genome_reference_filename'      => ( is => 'ro', isa => 'Str', default  => 'pan_genome_reference.fa' );

has '_inflate_clusters_obj'  => ( is => 'ro', isa => 'Bio::Roary::InflateClusters',        lazy => 1, builder => '_build__inflate_clusters_obj' );
has '_group_labels_obj'      => ( is => 'ro', isa => 'Bio::Roary::GroupLabels',            lazy => 1, builder => '_build__group_labels_obj' );
has '_annotate_groups_obj'   => ( is => 'ro', isa => 'Bio::Roary::AnnotateGroups',         lazy => 1, builder => '_build__annotate_groups_obj' );
has '_analyse_groups_obj'    => ( is => 'ro', isa => 'Bio::Roary::AnalyseGroups',          lazy => 1, builder => '_build__analyse_groups_obj' );
has '_order_genes_obj'       => ( is => 'ro', isa => 'Bio::Roary::OrderGenes',             lazy => 1, builder => '_build__order_genes_obj' );
has '_group_statistics_obj'  => ( is => 'ro', isa => 'Bio::Roary::GroupStatistics',        lazy => 1, builder => '_build__group_statistics_obj' );
has '_number_of_groups_obj'  => ( is => 'ro', isa => 'Bio::Roary::Output::NumberOfGroups', lazy => 1, builder => '_build__number_of_groups_obj' );
has '_one_gene_per_group_obj'  => ( is => 'ro', isa => 'Bio::Roary::Output::OneGenePerGroupFasta', lazy => 1, builder => '_build__one_gene_per_group_obj' );
has '_groups_multifastas_nuc_obj'  => ( is => 'ro', isa => 'Bio::Roary::Output::GroupsMultifastasNucleotide', lazy => 1, builder => '_build__groups_multifastas_nuc_obj' );
has '_split_groups_obj'      => ( is => 'ro', isa => 'Bio::Roary::SplitGroups', lazy_build => 1 );

has 'verbose_stats' => ( is => 'rw', isa => 'Bool', default => 0 ); 
has 'verbose'       => ( is => 'rw', isa => 'Bool', default => 0 );

sub run {
    my ($self) = @_;

    print "Reinflate clusters\n" if($self->verbose);
    $self->_inflate_clusters_obj->inflate();

	print "Split groups with paralogs\n" if($self->verbose);
    ## SPLIT GROUPS WITH PARALOGS ##
    if ( $self->dont_split_groups ){
      move( $self->_output_inflate_unsplit_clusters_filename, $self->_output_inflate_clusters_filename );
    }
    else {
      $self->_split_groups_obj->split_groups;
    }

	print "Labelling the groups\n" if($self->verbose);
    $self->_group_labels_obj->add_labels();
	print "Transfering the annotation to the groups\n" if($self->verbose);
    $self->_annotate_groups_obj->reannotate;
	print "Creating the spreadsheet with gene presence and absence\n" if($self->verbose);
    $self->_group_statistics_obj->create_spreadsheet;
	print "Creating tab files for R\n" if($self->verbose);
    $self->_number_of_groups_obj->create_output_files;
    system("create_pan_genome_plots.R") unless($self->dont_create_rplots == 1);
	print "Create EMBL files\n" if($self->verbose);
    $self->_create_embl_files;
	
	print "Create Pan genome reference\n" if($self->verbose);
	$self->_one_gene_per_group_obj->create_file();
    
	print "Creating files with the nucleotide sequences for every cluster\n" if($self->verbose && $self->output_multifasta_files);
    $self->_groups_multifastas_nuc_obj->create_files() if($self->output_multifasta_files);

	print "Cleaning up files\n" if($self->verbose);
    $self->_delete_intermediate_files;
}

sub _build__one_gene_per_group_obj
{
	my($self) = @_;
	return Bio::Roary::Output::OneGenePerGroupFasta->new(
		analyse_groups  => $self->_analyse_groups_obj,
		output_filename => $self->pan_genome_reference_filename
	);
}

sub _build__split_groups_obj {
  my ( $self ) = @_;
  return Bio::Roary::SplitGroups->new(
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
  return Bio::Roary::Output::NumberOfGroups->new(
    group_statistics_obj => $self->_group_statistics_obj,
    groups_to_contigs    => $self->_order_genes_obj->groups_to_contigs,
    annotate_groups_obj  => $self->_annotate_groups_obj,
	core_definition      => $self->core_definition
  );
}

sub _build__group_statistics_obj
{
  my ($self) = @_;
  return Bio::Roary::GroupStatistics->new(
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
  return Bio::Roary::OrderGenes->new(
    analyse_groups_obj => $self->_analyse_groups_obj,
    gff_files          => $self->input_files,
  );
}



sub _build__group_labels_obj
{
  my ($self) = @_;
  return Bio::Roary::GroupLabels->new(
      groups_filename => $self->_output_inflate_clusters_filename,
      output_filename => $self->_output_group_labels_filename
  );
}

sub _build__annotate_groups_obj
{
   my ($self) = @_;
   return  Bio::Roary::AnnotateGroups->new(
       gff_files       => $self->input_files,
       output_filename => $self->output_filename,
       groups_filename => $self->_output_group_labels_filename,
   );
}

sub _build__analyse_groups_obj
{
  my ($self) = @_;
  return Bio::Roary::AnalyseGroups->new(
      fasta_files     => $self->fasta_files,
      groups_filename => $self->output_filename
  );
}

sub _build__inflate_clusters_obj
{
  my ($self) = @_;
  return Bio::Roary::InflateClusters->new(
      clusters_filename     => $self->clusters_filename,
      cdhit_groups_filename => $self->_input_cd_hit_groups_file,
      mcl_filename          => $self->_output_mcl_filename,
      output_file           => $self->_output_inflate_unsplit_clusters_filename
  );
}


sub _build__groups_multifastas_nuc_obj
{
  my ($self) = @_;
  return Bio::Roary::Output::GroupsMultifastasNucleotide->new(
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
  my $core_accessory_tab_obj = Bio::Roary::Output::EmblGroups->new(
    output_filename     => $self->core_accessory_tab_output_filename,
    annotate_groups_obj => $self->_annotate_groups_obj,
    analyse_groups_obj  => $self->_analyse_groups_obj,
    ordering_key        => $self->core_accessory_ordering_key,
    groups_to_contigs   => $self->_order_genes_obj->groups_to_contigs
  );
  $core_accessory_tab_obj->create_files;
  
  my $accessory_tab_obj = Bio::Roary::Output::EmblGroups->new(
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
  
  for my $fasta_file (@{$self->fasta_files})
  {
      unlink($fasta_file) if(-e $fasta_file);
  }
  
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
