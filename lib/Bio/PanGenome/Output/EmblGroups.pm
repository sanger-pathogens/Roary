package Bio::PanGenome::Output::EmblGroups;

# ABSTRACT: Create a tab/embl file with the features for drawing pretty pictures

=head1 SYNOPSIS

reate a tab/embl file with the features for drawing pretty pictures
   use Bio::PanGenome::Output::EmblGroups;
   
   my $obj = Bio::PanGenome::Output::EmblGroups->new(
     output_filename => 'group_statitics.csv',
     annotate_groups_obj => $annotate_groups_obj,
     analyse_groups_obj  => $analyse_groups_obj
   );
   $obj->create_file;

=cut

use Moose;
use POSIX;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::AnnotateGroups;

has 'annotate_groups_obj' => ( is => 'ro', isa => 'Bio::PanGenome::AnnotateGroups', required => 1 );
has 'analyse_groups_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups',  required => 1 );
has 'output_filename'     => ( is => 'ro', isa => 'Str',                            default  => 'core_accessory.tab' );
has 'output_header_filename'     => ( is => 'ro', isa => 'Str',             lazy    => 1, builder => '_build_output_header_filename');
has 'groups_to_contigs'   => ( is => 'ro', isa => 'Maybe[HashRef]');
has 'ordering_key'        => ( is => 'ro', isa => 'Str',                            default  => 'core_accessory_overall_order' );

has '_output_fh'         => ( is => 'ro', lazy => 1,           builder => '_build__output_fh' );
has '_output_header_fh'  => ( is => 'ro', lazy => 1,           builder => '_build__output_header_fh' );
has '_sorted_file_names' => ( is => 'ro', isa  => 'ArrayRef',  lazy    => 1, builder => '_build__sorted_file_names' );
has '_groups_to_files'   => ( is => 'ro', isa  => 'HashRef',   lazy    => 1, builder => '_build__groups_to_files' );

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw(
        error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _build__output_header_fh
{
  my ($self) = @_;
  open( my $fh, '>', $self->output_header_filename )
    or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw(
      error => "Couldnt write output file:" . $self->output_filename );
  return $fh;
}

sub _build_output_header_filename
{
    my ($self) = @_;
    my $base_name  = $self->output_filename; 
    $base_name =~ s/\.tab/.header.tab/i;
    return $base_name;
}

sub _build__sorted_file_names {
    my ($self) = @_;
    my @sorted_file_names = sort( @{ $self->analyse_groups_obj->fasta_files } );
    return \@sorted_file_names;
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

sub _block {
    my ( $self, $group ) = @_;
    my @taxon_names_array;
    my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};
    
    return '' if(!(defined($self->groups_to_contigs->{$annotated_group_name}) &&  defined($self->groups_to_contigs->{$annotated_group_name}->{$self->ordering_key}) ));
    
    return '' if(defined($self->groups_to_contigs->{$annotated_group_name}->{comment}) && $self->groups_to_contigs->{$annotated_group_name}->{comment} ne '');
    
    my $coordindates = $self->groups_to_contigs->{$annotated_group_name}->{$self->ordering_key};
    
    for my $filename ( @{ $self->_sorted_file_names } ) {
        my $group_to_file_genes = $self->_groups_to_files->{$group}->{$filename};

        if ( defined($group_to_file_genes) && @{$group_to_file_genes} > 0 ) {
            my $filename_cpy = $filename;
            $filename_cpy =~ s!\.gff\.proteome\.faa!!;
            push( @taxon_names_array,  $filename_cpy );
            next;
        }
    }
    
    my $colour = $self->_block_colour($annotated_group_name);

    my $taxon_names = join(" ",@taxon_names_array);

    my $tab_file_entry = "FT   variation       $coordindates\n";
    $tab_file_entry   .= "FT                   /colour=$colour\n";
    $tab_file_entry   .= "FT                   /gene=$annotated_group_name\n";
    $tab_file_entry   .= "FT                   /taxa=\"$taxon_names\"\n";

    return $tab_file_entry;
}

sub _block_colour
{
   my ( $self, $annotated_group_name ) = @_;
   my $colour = 2; 
   return  $colour unless(defined($self->groups_to_contigs->{$annotated_group_name}->{accessory_label})  );

   $colour += $self->groups_to_contigs->{$annotated_group_name}->{accessory_label} % 6;
   return $colour;
}

sub _header_block
{
    my ( $self, $group ) = @_;
    my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};
    my $colour = 2; 
    
    return '' if(!(defined($self->groups_to_contigs->{$annotated_group_name}) &&  defined($self->groups_to_contigs->{$annotated_group_name}->{$self->ordering_key}) ));
    return '' if(defined($self->groups_to_contigs->{$annotated_group_name}->{comment}) && $self->groups_to_contigs->{$annotated_group_name}->{comment} ne '');
    my $coordindates = $self->groups_to_contigs->{$annotated_group_name}->{$self->ordering_key};
    
    my $tab_file_entry = "FT   variation       $coordindates\n";
    $tab_file_entry   .= "FT                   /gene=$annotated_group_name\n";
    $tab_file_entry   .= "FT                   /locus_tag=$annotated_group_name\n";
    $tab_file_entry   .= "FT                   /colour=$colour\n";

    return $tab_file_entry;
}

sub create_files {
    my ($self) = @_;

    for my $group ( @{ $self->annotate_groups_obj->_groups })
    {
       print { $self->_output_fh } $self->_block($group);
       print { $self->_output_header_fh } $self->_header_block($group);
    }
    close( $self->_output_fh );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
