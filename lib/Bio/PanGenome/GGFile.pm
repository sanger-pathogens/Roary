package Bio::PanGenome::GGFile;

# ABSTRACT: Create a GG file for input into orthomcl

=head1 SYNOPSIS

Create a GG file for input into orthomcl
   use Bio::PanGenome::GGFile;
   
   my $obj = Bio::PanGenome::GGFile->new(
     fasta_file   => 'abc.fa',
     output_filename   => 'example.all.gg',
   );
   $obj->create_gg_file;

=cut

use Moose;
use File::Basename;
use Bio::SeqIO;
use Bio::PanGenome::Exceptions;

has 'fasta_file'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_filename' => ( is => 'ro', isa => 'Str', lazy     => 1, builder => '_build_output_filename' );
has '_output_suffix'  => ( is => 'ro', isa => 'Str', default  => 'all.gg' );

sub _build_output_filename {
    my ($self) = @_;
    return join( '.', ( $self->_input_filename_with_extension, $self->_output_suffix ) );
}

sub _input_filename_without_extension {
    my ($self) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->fasta_file, qr/\.[^.]*/ );
    return $filename;
}

sub _input_filename_with_extension {
    my ($self) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->fasta_file );
    return $filename . $suffix;
}

sub _sequence_ids {
    my ($self) = @_;
    my @sequence_ids;

    my $fasta_obj = Bio::SeqIO->new( -file => $self->fasta_file, -format => 'Fasta' );
    while ( my $seq = $fasta_obj->next_seq() ) {
        push( @sequence_ids, $seq->display_id() );
    }
    return \@sequence_ids;
}

sub create_gg_file {
    my ($self) = @_;

    open( my $fh, ">", $self->output_filename )
      or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw(
        error => "Couldnt write to file: " . $self->output_filename );
    print $fh $self->_input_filename_without_extension . ": ";
    print $fh join( ' ', ( @{ $self->_sequence_ids } ) ) . "\n";
    close($fh);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
