package Bio::Roary::MergeMultifastaAlignments;

# ABSTRACT: Merge multifasta alignment files with equal numbers of sequences.

=head1 SYNOPSIS

Merge multifasta alignment files with equal numbers of sequences.So each sequence in each file gets concatenated together.  It is assumed the 
sequences are in the correct order.
   use Bio::Roary::MergeMultifastaAlignments;
   
   my $obj = Bio::Roary::MergeMultifastaAlignments->new(
     multifasta_files => [],
     output_filename  => 'output_merged.aln'
   );
   $obj->merge_files;

=cut

use Moose;
use Bio::SeqIO;
use Bio::Roary::Output::CoreGeneAlignmentCoordinatesEMBL;

has 'multifasta_files'       => ( is => 'ro', isa => 'ArrayRef',   required => 1 );
has 'sample_names'           => ( is => 'ro', isa => 'ArrayRef',   required => 1 );
has 'sample_names_to_genes'  => ( is => 'rw', isa => 'HashRef',    required => 1 );
has 'output_filename'        => ( is => 'ro', isa => 'Str',        default  => 'core_alignment.aln' );
has 'output_header_filename' => ( is => 'ro', isa => 'Str',        default  => 'core_alignment_header.embl' );
has '_output_seqio_obj'      => ( is => 'ro', isa => 'Bio::SeqIO', lazy     => 1, builder => '_build__output_seqio_obj' );
has '_gene_lengths'          => ( is => 'rw', isa => 'HashRef',    lazy     => 1, builder => '_build__gene_lengths' );
has '_gene_to_sequence' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has '_sorted_multifasta_files' => ( is => 'rw', isa => 'ArrayRef', lazy => 1, builder => '_build__sorted_multifasta_files' );

sub BUILD {
    my ($self) = @_;
    $self->_gene_lengths;
}

sub _input_seq_io_obj {
    my ( $self, $filename ) = @_;
    return Bio::SeqIO->new( -file => $filename, -format => 'Fasta' );
}

sub _build__output_seqio_obj {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => ">" . $self->output_filename, -format => 'Fasta' );
}

sub _build__gene_lengths {
    my ($self) = @_;
    my %gene_lengths;
    for my $filename ( @{ $self->_sorted_multifasta_files } ) {
        my $seq_io = $self->_input_seq_io_obj($filename);
        next unless ( defined($seq_io) );
        while ( my $seq_record = $seq_io->next_seq ) {

            # Save all of the gene sequences to memory, massive speedup but a bit naughty.
            $self->_gene_to_sequence->{$filename}->{ $seq_record->display_id } = $seq_record->seq;
            $gene_lengths{$filename} = $seq_record->length() if ( !defined( $gene_lengths{$filename} ) );
        }
    }

    return \%gene_lengths;
}

sub _build__sorted_multifasta_files {
    my ($self) = @_;
    my @sorted_gene_files = sort @{ $self->multifasta_files };
    return \@sorted_gene_files;
}

sub _sequence_for_sample_from_gene_file {
    my ( $self, $sample_name, $gene_file ) = @_;

    # loop over this to get the geneIDs
    for my $gene_id ( keys %{ $self->_gene_to_sequence->{$gene_file} } ) {
        if ( defined( $self->sample_names_to_genes->{$sample_name}->{$gene_id} ) ) {
            return $self->_gene_to_sequence->{$gene_file}->{$gene_id};
        }
    }
    return $self->_padded_string_for_gene_file($gene_file);
}

sub _padded_string_for_gene_file {
    my ( $self, $gene_file ) = @_;
    return '' unless ( defined( $self->_gene_lengths->{$gene_file} ) );
    return 'N' x ( $self->_gene_lengths->{$gene_file} );
}

sub _create_merged_sequence_for_sample {
    my ( $self, $sample_name ) = @_;
    my $merged_sequence = '';
    for my $gene_file ( @{ $self->_sorted_multifasta_files } ) {
        $merged_sequence .= $self->_sequence_for_sample_from_gene_file( $sample_name, $gene_file );
    }
    return $merged_sequence;
}

sub merge_files {
    my ($self) = @_;

    for my $sample_name ( @{ $self->sample_names } ) {
        my $sequence = $self->_create_merged_sequence_for_sample($sample_name);
        my $seq_io = Bio::Seq->new( -display_id => $sample_name, -seq => $sequence );
        $self->_output_seqio_obj->write_seq($seq_io);
    }

    # Create a header file which gives the coordinates of each gene in the multifasta
    Bio::Roary::Output::CoreGeneAlignmentCoordinatesEMBL->new(
        multifasta_files => $self->_sorted_multifasta_files,
        gene_lengths     => $self->_gene_lengths,
        output_filename  => $self->output_header_filename
    )->create_file();

    return 1;
}

no Moose;
	__PACKAGE__->meta->make_immutable;

1;

