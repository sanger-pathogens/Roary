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
use Bio::Roary::AccessoryBinaryFasta;
use Bio::Roary::External::Fasttree;
use Bio::Roary::AccessoryClustering;
use Bio::Roary::AssemblyStatistics;
use Log::Log4perl qw(:easy);

has 'fasta_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'input_files'                 => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'output_filename'             => ( is => 'rw', isa => 'Str',      default  => 'clustered_proteins' );
has 'output_pan_geneome_filename' => ( is => 'rw', isa => 'Str',      default  => 'pan_genome.fa' );
has 'output_statistics_filename'  => ( is => 'rw', isa => 'Str',      default  => 'gene_presence_absence.csv' );
has 'output_multifasta_files'     => ( is => 'ro', isa => 'Bool',     default  => 0 );
has 'verbose_stats'               => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'verbose'                     => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'cpus'                        => ( is => 'ro', isa => 'Int',      default  => 1 );

has 'clusters_filename'  => ( is => 'rw', isa => 'Str',  required => 1 );
has 'dont_delete_files'  => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'dont_split_groups'  => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'dont_create_rplots' => ( is => 'rw', isa => 'Bool', default  => 1 );
has 'group_limit'        => ( is => 'rw', isa => 'Num',  default  => 50000 );

has '_output_mcl_filename'                      => ( is => 'ro', isa => 'Str', default => '_uninflated_mcl_groups' );
has '_output_inflate_unsplit_clusters_filename' => ( is => 'ro', isa => 'Str', default => '_inflated_unsplit_mcl_groups' );
has '_output_inflate_clusters_filename'         => ( is => 'ro', isa => 'Str', default => '_inflated_mcl_groups' );
has '_output_group_labels_filename'             => ( is => 'ro', isa => 'Str', default => '_labeled_mcl_groups' );
has '_output_combined_filename'                 => ( is => 'ro', isa => 'Str', default => '_combined_files' );
has '_input_cd_hit_groups_file'                 => ( is => 'ro', isa => 'Str', default => '_combined_files.groups' );
has 'core_accessory_tab_output_filename'        => ( is => 'ro', isa => 'Str', default => 'core_accessory.tab' );
has 'accessory_tab_output_filename'             => ( is => 'ro', isa => 'Str', default => 'accessory.tab' );
has 'core_accessory_ordering_key'               => ( is => 'ro', isa => 'Str', default => 'core_accessory_overall_order_filtered' );
has 'accessory_ordering_key'                    => ( is => 'ro', isa => 'Str', default => 'accessory_overall_order_filtered' );
has 'core_definition'                           => ( is => 'ro', isa => 'Num', default => 1.0 );
has 'pan_genome_reference_filename'             => ( is => 'ro', isa => 'Str', default => 'pan_genome_reference.fa' );

has '_inflate_clusters_obj' => ( is => 'ro', isa => 'Bio::Roary::InflateClusters', lazy => 1, builder => '_build__inflate_clusters_obj' );
has '_group_labels_obj'     => ( is => 'ro', isa => 'Bio::Roary::GroupLabels',     lazy => 1, builder => '_build__group_labels_obj' );
has '_annotate_groups_obj'  => ( is => 'ro', isa => 'Bio::Roary::AnnotateGroups',  lazy => 1, builder => '_build__annotate_groups_obj' );
has '_analyse_groups_obj'   => ( is => 'ro', isa => 'Bio::Roary::AnalyseGroups',   lazy => 1, builder => '_build__analyse_groups_obj' );
has '_order_genes_obj'      => ( is => 'ro', isa => 'Bio::Roary::OrderGenes',      lazy => 1, builder => '_build__order_genes_obj' );
has '_group_statistics_obj' => ( is => 'ro', isa => 'Bio::Roary::GroupStatistics', lazy => 1, builder => '_build__group_statistics_obj' );
has '_number_of_groups_obj' =>
  ( is => 'ro', isa => 'Bio::Roary::Output::NumberOfGroups', lazy => 1, builder => '_build__number_of_groups_obj' );
has '_accessory_binary_fasta' =>
  ( is => 'ro', isa => 'Bio::Roary::AccessoryBinaryFasta', lazy => 1, builder => '_build__accessory_binary_fasta' );
has '_groups_multifastas_nuc_obj' =>
  ( is => 'ro', isa => 'Bio::Roary::Output::GroupsMultifastasNucleotide', lazy => 1, builder => '_build__groups_multifastas_nuc_obj' );
has '_split_groups_obj' => ( is => 'ro', isa => 'Bio::Roary::SplitGroups', lazy => 1, builder => '_build__split_groups_obj' );
has '_accessory_binary_tree' =>
  ( is => 'ro', isa => 'Bio::Roary::External::Fasttree', lazy => 1, builder => '_build__accessory_binary_tree' );
has '_accessory_clustering' =>
  ( is => 'ro', isa => 'Maybe[Bio::Roary::AccessoryClustering]', lazy => 1, builder => '_build__accessory_clustering' );
has '_assembly_statistics' => ( is => 'ro', isa => 'Bio::Roary::AssemblyStatistics', lazy => 1, builder => '_build__assembly_statistics' );

has 'logger' => ( is => 'ro', lazy => 1, builder => '_build_logger' );

sub _build_logger {
    my ($self) = @_;
    Log::Log4perl->easy_init( level => $ERROR );
    my $logger = get_logger();
    return $logger;
}

sub run {
    my ($self) = @_;

    $self->logger->info("Reinflate clusters");
    $self->_inflate_clusters_obj->inflate();

    $self->logger->info("Split groups with paralogs");
    ## SPLIT GROUPS WITH PARALOGS ##
    if ( $self->dont_split_groups ) {
        move( $self->_output_inflate_unsplit_clusters_filename, $self->_output_inflate_clusters_filename );
    }
    else {
        $self->_split_groups_obj->split_groups;
    }

    $self->logger->info("Labelling the groups");
    $self->_group_labels_obj->add_labels();

    $self->logger->info("Transfering the annotation to the groups");
    $self->_annotate_groups_obj->reannotate;

    $self->logger->info("Creating accessory binary gene presence and absence fasta");
    $self->_accessory_binary_fasta->create_accessory_binary_fasta;

    $self->logger->info("Creating accessory binary gene presence and absence tree");
    $self->_accessory_binary_tree->run;

    $self->logger->info("Creating accessory gene presence and absence clusters");
    if ( $self->_accessory_clustering ) {
        $self->_accessory_clustering->sample_weights;
    }

    $self->logger->info("Creating the spreadsheet with gene presence and absence");
    $self->_group_statistics_obj->create_spreadsheet;
	$self->_group_statistics_obj->create_rtab;

    $self->logger->info("Creating summary statistics of the spreadsheet");
    $self->_assembly_statistics->create_summary_output;

    $self->logger->info("Creating tab files for R");
    $self->_number_of_groups_obj->create_output_files;

    system("create_pan_genome_plots.R") unless ( $self->dont_create_rplots == 1 );

    $self->logger->info("Create EMBL files");
    $self->_create_embl_files;

    my $clusters_not_exceeded = 1;
    if ( $self->output_multifasta_files ) {
        $self->logger->info("Creating files with the nucleotide sequences for every cluster");
        $clusters_not_exceeded = $self->_groups_multifastas_nuc_obj->create_files();
    }

    $self->_delete_intermediate_files;
    if ( $clusters_not_exceeded == 0 && $self->output_multifasta_files ) {
        $self->logger->error("Exiting early because number of clusters is too high");
        exit();
    }
}

sub _build__assembly_statistics {
    my ($self) = @_;
    return Bio::Roary::AssemblyStatistics->new(
        spreadsheet     => $self->_group_statistics_obj->output_filename,
        core_definition => $self->core_definition,
        logger          => $self->logger
    );
}

sub _build__accessory_clustering {
    my ($self) = @_;
    if ( ( -e $self->_accessory_binary_fasta->output_filename ) && ( -s $self->_accessory_binary_fasta->output_filename > 5 ) ) {
        $self->logger->info( $self->_accessory_binary_fasta->output_filename );
        return Bio::Roary::AccessoryClustering->new(
            input_file => $self->_accessory_binary_fasta->output_filename,
            cpus       => $self->cpus,
            logger     => $self->logger
        );
    }
    else {
        $self->logger->info("Theres no accessory binary file so skipping accessory binary clustering");
        return undef;
    }

}

sub _build__accessory_binary_tree {
    my ($self) = @_;
    return Bio::Roary::External::Fasttree->new(
        input_file => $self->_accessory_binary_fasta->output_filename,
        verbose    => $self->verbose,
        logger     => $self->logger
    );
}

sub _build__accessory_binary_fasta {
    my ($self) = @_;
    return Bio::Roary::AccessoryBinaryFasta->new(
        input_files         => $self->fasta_files,
        annotate_groups_obj => $self->_annotate_groups_obj,
        analyse_groups_obj  => $self->_analyse_groups_obj,
        logger              => $self->logger
    );
}

sub _build__split_groups_obj {
    my ($self) = @_;
    return Bio::Roary::SplitGroups->new(
        groupfile   => $self->_output_inflate_unsplit_clusters_filename,
        gff_files   => $self->input_files,
        fasta_files => $self->fasta_files,
        outfile     => $self->_output_inflate_clusters_filename,
        dont_delete => $self->dont_delete_files,
        logger      => $self->logger
    );
}

sub _build__number_of_groups_obj {
    my ($self) = @_;
    return Bio::Roary::Output::NumberOfGroups->new(
        group_statistics_obj => $self->_group_statistics_obj,
        groups_to_contigs    => $self->_order_genes_obj->groups_to_contigs,
        annotate_groups_obj  => $self->_annotate_groups_obj,
        core_definition      => $self->core_definition,
        logger               => $self->logger
    );
}

sub _build__group_statistics_obj {
    my ($self) = @_;
    return Bio::Roary::GroupStatistics->new(
        output_filename     => $self->output_statistics_filename,
        annotate_groups_obj => $self->_annotate_groups_obj,
        analyse_groups_obj  => $self->_analyse_groups_obj,
        groups_to_contigs   => $self->_order_genes_obj->groups_to_contigs,
        _verbose            => $self->verbose_stats,
        logger              => $self->logger
    );
}

sub _build__order_genes_obj {
    my ($self) = @_;
    if ( defined( $self->_accessory_clustering ) ) {
        return Bio::Roary::OrderGenes->new(
            analyse_groups_obj  => $self->_analyse_groups_obj,
            gff_files           => $self->input_files,
            core_definition     => $self->core_definition,
            sample_weights      => $self->_accessory_clustering->sample_weights,
            samples_to_clusters => $self->_accessory_clustering->samples_to_clusters,
            logger              => $self->logger
        );
    }
    else {
        return Bio::Roary::OrderGenes->new(
            analyse_groups_obj => $self->_analyse_groups_obj,
            gff_files          => $self->input_files,
            core_definition    => $self->core_definition,
            logger             => $self->logger
        );
    }
}

sub _build__group_labels_obj {
    my ($self) = @_;
    return Bio::Roary::GroupLabels->new(
        groups_filename => $self->_output_inflate_clusters_filename,
        output_filename => $self->_output_group_labels_filename,
        logger          => $self->logger
    );
}

sub _build__annotate_groups_obj {
    my ($self) = @_;
    return Bio::Roary::AnnotateGroups->new(
        gff_files       => $self->input_files,
        output_filename => $self->output_filename,
        groups_filename => $self->_output_group_labels_filename,
        logger          => $self->logger
    );
}

sub _build__analyse_groups_obj {
    my ($self) = @_;
    return Bio::Roary::AnalyseGroups->new(
        fasta_files     => $self->fasta_files,
        groups_filename => $self->output_filename,
        logger          => $self->logger
    );
}

sub _build__inflate_clusters_obj {
    my ($self) = @_;
    return Bio::Roary::InflateClusters->new(
        clusters_filename     => $self->clusters_filename,
        cdhit_groups_filename => $self->_input_cd_hit_groups_file,
        mcl_filename          => $self->_output_mcl_filename,
        output_file           => $self->_output_inflate_unsplit_clusters_filename,
        logger                => $self->logger
    );
}

sub _build__groups_multifastas_nuc_obj {
    my ($self) = @_;
    return Bio::Roary::Output::GroupsMultifastasNucleotide->new(
        output_multifasta_files => $self->output_multifasta_files,
        gff_files               => $self->input_files,
        annotate_groups         => $self->_annotate_groups_obj,
        group_names             => $self->_analyse_groups_obj->_groups,
        group_limit             => $self->group_limit,
        core_definition         => $self->core_definition,
        dont_delete_files       => $self->dont_delete_files,
        logger                  => $self->logger
    );
}

sub _create_embl_files {
    my ($self) = @_;
    my $core_accessory_tab_obj = Bio::Roary::Output::EmblGroups->new(
        output_filename     => $self->core_accessory_tab_output_filename,
        annotate_groups_obj => $self->_annotate_groups_obj,
        analyse_groups_obj  => $self->_analyse_groups_obj,
        ordering_key        => $self->core_accessory_ordering_key,
        groups_to_contigs   => $self->_order_genes_obj->groups_to_contigs,
        logger              => $self->logger
    );
    $core_accessory_tab_obj->create_files;

    my $accessory_tab_obj = Bio::Roary::Output::EmblGroups->new(
        output_filename     => $self->accessory_tab_output_filename,
        annotate_groups_obj => $self->_annotate_groups_obj,
        analyse_groups_obj  => $self->_analyse_groups_obj,
        ordering_key        => $self->accessory_ordering_key,
        groups_to_contigs   => $self->_order_genes_obj->groups_to_contigs,
        logger              => $self->logger
    );
    $accessory_tab_obj->create_files;
}

sub _delete_intermediate_files {
    my ($self) = @_;
    return if ( $self->dont_delete_files == 1 );
	$self->logger->info("Cleaning up files");

    for my $fasta_file ( @{ $self->fasta_files } ) {
        unlink($fasta_file) if ( -e $fasta_file );
    }

    unlink( $self->_output_mcl_filename );
    unlink( $self->_output_inflate_clusters_filename );
    unlink( $self->_output_group_labels_filename );
    unlink( $self->_output_combined_filename );
    unlink( $self->clusters_filename );
    unlink( $self->clusters_filename . '.clstr' );
    unlink( $self->clusters_filename . '.bak.clstr' );
    unlink('_gff_files');
    unlink('_fasta_files');
    unlink('_clustered_filtered.fa');
    unlink( $self->_input_cd_hit_groups_file );
    unlink('database_masking.asnb');
    unlink('_clustered');
    unlink('_accessory_clusters');
    unlink('_accessory_clusters.clstr');
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
