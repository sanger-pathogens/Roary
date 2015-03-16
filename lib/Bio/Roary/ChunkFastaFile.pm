package Bio::Roary::ChunkFastaFile;

# ABSTRACT: Take in a FASTA file and chunk it up into smaller pieces.

=head1 SYNOPSIS

Take in a FASTA file and chunk it up into smaller pieces.
   use Bio::Roary::ChunkFastaFile;
   
   my $obj = Bio::Roary::ChunkFastaFile->new(
     fasta_file   => 'abc.fa',
   );
   $obj->sequence_file_names;

=cut

use Moose;
use Bio::SeqIO;
use Bio::Roary::Exceptions;
use Cwd;
use File::Temp;

has 'fasta_file'          => ( is => 'ro', isa => 'Str',      required => 1 );
has 'target_chunk_size'   => ( is => 'ro', isa => 'Int',      default  => 200000 );
has 'sequence_file_names' => ( is => 'ro', isa => 'ArrayRef', lazy     => 1, builder => '_build_sequence_file_names' );
has '_working_directory' =>
  ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_working_directory_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__working_directory_name' );
has '_input_seqio' => ( is => 'ro', isa => 'Bio::SeqIO', lazy => 1, builder => '_build__input_seqio' );

sub _build__working_directory_name {
    my ($self) = @_;
    return $self->_working_directory->dirname();
}

sub _build__input_seqio {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => $self->fasta_file, -format => 'Fasta' );
}

sub _create_next_chunk_file_name {
    my ( $self, $chunk_number ) = @_;
    return join( '/', ( $self->_working_directory_name, $chunk_number . '.seq' ) );
}

sub _create_next_chunk_seqio {
    my ( $self, $chunk_number ) = @_;
    return Bio::SeqIO->new( -file => ">".$self->_create_next_chunk_file_name($chunk_number), -format => 'Fasta' );
}

sub _build_sequence_file_names {
    my ($self) = @_;
    my @sequence_file_names;
    my $chunk_number         = 0;
    my $current_chunk_length = 0;
    my $current_chunk_seqio  = $self->_create_next_chunk_seqio($chunk_number);
    push( @sequence_file_names, $self->_create_next_chunk_file_name($chunk_number) );

    while ( my $input_seq = $self->_input_seqio->next_seq() ) {
        if ( $current_chunk_length > $self->target_chunk_size ) {

            # next chunk
            $chunk_number++;
            $current_chunk_length = 0;
            $current_chunk_seqio  = $self->_create_next_chunk_seqio($chunk_number);
            push( @sequence_file_names, $self->_create_next_chunk_file_name($chunk_number) );
        }
        $current_chunk_seqio->write_seq($input_seq);
        $current_chunk_length += $input_seq->length();
    }
    return \@sequence_file_names;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
