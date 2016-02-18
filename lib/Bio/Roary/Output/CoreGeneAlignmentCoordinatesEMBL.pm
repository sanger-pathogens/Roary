package Bio::Roary::Output::CoreGeneAlignmentCoordinatesEMBL;

# ABSTRACT: Create an embl file for the header with locations of where genes are in the multifasta alignment of core genes

=head1 SYNOPSIS

Create an embl file for the header with locations of where genes are in the multifasta alignment of core genes
   use Bio::Roary::Output::CoreGeneAlignmentCoordinatesEMBL;
   
   my $obj = Bio::Roary::Output::CoreGeneAlignmentCoordinatesEMBL->new(
        output_filename => 'core_alignment_header.embl',
        multifasta_files => [
            't/data/multifasta_files/1.aln', 't/data/multifasta_files/outof_order.aln',
            't/data/multifasta_files/2.aln', 't/data/multifasta_files/3.aln'
        ],
        gene_lengths => {
            't/data/multifasta_files/1.aln'           => 1,
            't/data/multifasta_files/outof_order.aln' => 10,
            't/data/multifasta_files/2.aln'           => 100,
            't/data/multifasta_files/3.aln'           => 1000
        },
   );
   $obj->create_file;

=cut

use Moose;
use Bio::Roary::Exceptions;
use File::Basename;
with 'Bio::Roary::Output::EMBLHeaderCommon';

has 'output_filename'     => ( is => 'ro', isa => 'Str',      default  => 'core_alignment_header.embl' );
has 'multifasta_files'    => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'gene_lengths'        => ( is => 'ro', isa => 'HashRef',  required => 1 );
has '_current_coordinate' => ( is => 'rw', isa => 'Int',      default  => 1 );
has '_output_fh'          => ( is => 'ro', lazy => 1,         builder => '_build__output_fh' );

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::Roary::Exceptions::CouldntWriteToFile->throw( error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _gene_name_from_filename {
    my ( $self, $filename ) = @_;
    my $gene_name = basename($filename);
		$gene_name =~ s!\.aln!!;
    $gene_name =~ s!\.fa!!;
		return $gene_name;
}

sub _header_block {
    my ( $self, $gene_filename ) = @_;
    my $gene_name       = $self->_gene_name_from_filename($gene_filename);
    my $gene_length     = $self->gene_lengths->{$gene_filename};
    my $end_coordinate  = $self->_current_coordinate + $gene_length - 1;
    my $annotation_type = $self->_annotation_type($gene_name);

    my $tab_file_entry = join( '', ( 'FT', $annotation_type, $self->_current_coordinate, '..', $end_coordinate, "\n" ) );
    $tab_file_entry .= "FT                   /label=$gene_name\n";
    $tab_file_entry .= "FT                   /locus_tag=$gene_name\n";

    $self->_current_coordinate( $end_coordinate + 1 );
    return $tab_file_entry;
}

sub create_file {
    my ($self) = @_;
    print { $self->_output_fh } $self->_header_top;
    for my $filename ( @{ $self->multifasta_files } ) {
        print { $self->_output_fh } $self->_header_block($filename);
    }
    print { $self->_output_fh } $self->_header_bottom;
    close( $self->_output_fh );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
