package Bio::PanGenome::GroupStatistics;

# ABSTRACT: Add labels to the groups

=head1 SYNOPSIS

Add labels to the groups
   use Bio::PanGenome::GroupStatistics;
   
   my $obj = Bio::PanGenome::GroupStatistics->new(
     output_filename => 'group_statitics.csv',
     annotate_groups_obj => $annotate_groups_obj,
     analyse_groups_obj  => $analyse_groups_obj
   );
   $obj->create_spreadsheet;

=cut

use Data::Dumper;

use Moose;
use POSIX;
use Text::CSV;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::AnnotateGroups;

has 'annotate_groups_obj' => ( is => 'ro', isa => 'Bio::PanGenome::AnnotateGroups', required => 1 );
has 'analyse_groups_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups',  required => 1 );
has 'output_filename'     => ( is => 'ro', isa => 'Str',                            default  => 'group_statitics.csv' );
has 'groups_to_contigs'   => ( is => 'ro', isa => 'Maybe[HashRef]');

has '_output_fh'         => ( is => 'ro', lazy => 1,           builder => '_build__output_fh' );
has '_text_csv_obj'      => ( is => 'ro', isa  => 'Text::CSV', lazy    => 1, builder => '_build__text_csv_obj' );
has '_sorted_file_names' => ( is => 'ro', isa  => 'ArrayRef',  lazy    => 1, builder => '_build__sorted_file_names' );
has '_groups_to_files'   => ( is => 'ro', isa  => 'HashRef',   lazy    => 1, builder => '_build__groups_to_files' );
has '_files_to_groups'   => ( is => 'ro', isa  => 'HashRef',   lazy    => 1, builder => '_build__files_to_groups' );

has '_verbose'           => ( is => 'ro', isa => 'Bool', default => 0 );

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw(
        error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _build__text_csv_obj {
    my ($self) = @_;
    return Text::CSV->new( { binary => 1, always_quote => 1, eol => "\r\n" } );
}

sub fixed_headers {
    my ($self) = @_;
    my @header =
      ( 'Gene', 'Non-unique Gene name', 'Annotation', 'No. isolates', 'No. sequences', 'Avg sequences per isolate', 'Genome Fragment','Order within Fragment', 'Accessory Fragement','Accessory Order with Fragment', 'QC' );
    return \@header;
}

sub _header {
    my ($self) = @_;
    my @header = @{ $self->fixed_headers };

    for my $filename ( @{ $self->_sorted_file_names } ) {
        my $filename_cpy = $filename;
        $filename_cpy =~ s!\.gff\.proteome\.faa!!;
        push( @header, $filename_cpy );
    }

    push( @header, 'Inference' ) if ( $self->_verbose );

    return \@header;
}

sub _build__sorted_file_names {
    my ($self) = @_;
    my @sorted_file_names = sort( @{ $self->analyse_groups_obj->fasta_files } );
    return \@sorted_file_names;
}

sub _non_unique_name_for_group {
    my ( $self, $annotated_group_name ) = @_;
    my $duplicate_gene_name = '';
    my $prefix              = $self->annotate_groups_obj->_group_default_prefix;
    if ( $annotated_group_name =~ /$prefix/ ) {
        my $non_unique_name_for_group =
          $self->annotate_groups_obj->_consensus_gene_name_for_group($annotated_group_name);
        if ( !( $non_unique_name_for_group =~ /$prefix/ ) ) {
            $duplicate_gene_name = $non_unique_name_for_group;
        }
    }
    return $duplicate_gene_name;
}

sub _build__groups_to_files {
    my ($self) = @_;
    my %groups_to_files;
    for my $group ( @{ $self->annotate_groups_obj->_groups } ) {
        my $genes = $self->annotate_groups_obj->_groups_to_id_names->{$group};
        my %filenames;
        for my $gene_name ( @{$genes} ) {
            my $filename = $self->analyse_groups_obj->_genes_to_file->{$gene_name};
            push( @{ $filenames{$filename} }, $gene_name );
        }
        $groups_to_files{$group} = \%filenames;
    }
    return \%groups_to_files;
}

sub _build__files_to_groups
{
  my ($self) = @_;
  my %files_to_groups;
  
  for my $group (keys %{$self->_groups_to_files})
  {
    for my $filename (keys %{$self->_groups_to_files->{$group}})
    {
      push(@{$files_to_groups{$filename}}, $group);
    }
  }
  
  return \%files_to_groups;
}


sub _row {
    my ( $self, $group ) = @_;
    my $genes = $self->annotate_groups_obj->_groups_to_id_names->{$group};

    my $num_isolates_in_group     = $self->analyse_groups_obj->_count_num_files_in_group($genes);
    my $num_sequences_in_group    = $#{$genes} + 1;
    my $avg_sequences_per_isolate = ceil( ( $num_sequences_in_group / $num_isolates_in_group ) * 100 ) / 100;

    my $annotation           = $self->annotate_groups_obj->consensus_product_for_id_names($genes);
    my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};

    my $duplicate_gene_name = $self->_non_unique_name_for_group($annotated_group_name);
    
    my $genome_number = '';
    my $qc_comment = '';
    my $order_within_fragement = '';
    my $accessory_order_within_fragement = '';
    my $accessory_genome_number = '';
    if(defined($self->groups_to_contigs) && defined($self->groups_to_contigs->{$annotated_group_name}))
    {
      $genome_number = $self->groups_to_contigs->{$annotated_group_name}->{label};
      $qc_comment = $self->groups_to_contigs->{$annotated_group_name}->{comment};
      $order_within_fragement = $self->groups_to_contigs->{$annotated_group_name}->{order};
      
      $accessory_genome_number = $self->groups_to_contigs->{$annotated_group_name}->{accessory_label};
      $accessory_order_within_fragement = $self->groups_to_contigs->{$annotated_group_name}->{accessory_order};
    }
    
    my @row = (
        $annotated_group_name,  $duplicate_gene_name,    $annotation,
        $num_isolates_in_group, $num_sequences_in_group, $avg_sequences_per_isolate,$genome_number,$order_within_fragement,$accessory_genome_number,$accessory_order_within_fragement,$qc_comment
    );

    for my $filename ( @{ $self->_sorted_file_names } ) {
        my $group_to_file_genes = $self->_groups_to_files->{$group}->{$filename};

        if ( defined($group_to_file_genes) && @{$group_to_file_genes} > 0 ) {

            push( @row, join( "\t", @{$group_to_file_genes} ) );
            next;
        }
        else {
            push( @row, '' );
        }
    }

    ## ADD INFERENCE AND FULL ANNOTATION IF VERBOSE REQUESTED ##
    if ( $self->_verbose ){
      my ( $full_annotation, $inference );
        $row[2] = $self->annotate_groups_obj->full_annotation($group);
        push( @row, $self->annotate_groups_obj->inference($group) );
    }

    return \@row;
}

sub create_spreadsheet {
    my ($self) = @_;

    $self->_text_csv_obj->print( $self->_output_fh, $self->_header );

    my @sorted_groups = sort {
          $self->analyse_groups_obj->_count_num_files_in_group( $self->annotate_groups_obj->_groups_to_id_names->{$b} )
      <=> $self->analyse_groups_obj->_count_num_files_in_group( $self->annotate_groups_obj->_groups_to_id_names->{$a} )
        } @{ $self->annotate_groups_obj->_groups };

    for my $group (@sorted_groups){
        $self->_text_csv_obj->print( $self->_output_fh, $self->_row($group) );
    }
    close( $self->_output_fh );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
