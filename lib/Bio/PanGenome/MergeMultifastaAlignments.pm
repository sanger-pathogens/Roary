package Bio::PanGenome::MergeMultifastaAlignments;

# ABSTRACT: Merge multifasta alignment files with equal numbers of sequences.

=head1 SYNOPSIS

Merge multifasta alignment files with equal numbers of sequences.So each sequence in each file gets concatenated together.  It is assumed the 
sequences are in the correct order.
   use Bio::PanGenome::MergeMultifastaAlignments;
   
   my $obj = Bio::PanGenome::MergeMultifastaAlignments->new(
     multifasta_files => [],
     output_filename  => 'output_merged.aln'
   );
   $obj->merge_files;

=cut

use Moose;
use Bio::SeqIO;

use Data::Dumper;

has 'multifasta_files'  => ( is => 'ro', isa => 'ArrayRef',   required => 1 );
has 'output_filename'   => ( is => 'ro', isa => 'Str',        default  => 'core_alignment.aln' );
has '_output_seqio_obj' => ( is => 'ro', isa => 'Bio::SeqIO', lazy     => 1, builder => '_build__output_seqio_obj' );
has '_input_seqio_objs' => ( is => 'ro', isa => 'ArrayRef',   lazy     => 1, builder => '_build__input_seqio_objs' );

# stream all the input files simulationously - thousands of open file handles which may be an issue but it
# substantially speeds up creating the output file
sub _build__input_seqio_objs {
    my ($self) = @_;
    my @seqio_objs;
    for my $filename ( @{ $self->multifasta_files } ) {
        push( @seqio_objs, $self->_input_seq_io_obj($filename) );
    }
    return \@seqio_objs;
}

sub _input_seq_io_obj {
    my ( $self, $filename ) = @_;
    return Bio::SeqIO->new( -file => $filename, -format => 'Fasta' );
}

sub _build__output_seqio_obj {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => ">" . $self->output_filename, -format => 'Fasta' );
}

sub merge_files {
    my ($self) = @_;

    my $reached_eof = 0;

    while ( $reached_eof == 0 ) {
        last unless ( scalar @{ $self->_input_seqio_objs} > 0 );
        my $merged_sequence = '';
        my $first_name;
        return 1 if(@{ $self->_input_seqio_objs } == 0);

        my @c_seqs;
        for my $input_seq_io ( @{ $self->_input_seqio_objs } ) {
            my $next_seq = $input_seq_io->next_seq;
            push( @c_seqs, $next_seq );
        }

        # check if any seqs need padding or whether to end the while loop
        my $fixed_seqs = $self->_check_seqs( \@c_seqs );
        last unless ( defined($fixed_seqs) );
        
        for my $current_sequence ( @{ $fixed_seqs } ){
            $merged_sequence .= $current_sequence->seq;
            if ( !defined($first_name) ) {
                $first_name = $current_sequence->display_id;
            }
        }

        if ( $reached_eof == 0 ) {
            my $merged_seq_obj = Bio::Seq->new(
                -display_id => $self->_strip_id_from_name($first_name),
                -seq        => $merged_sequence
            );
            $self->_output_seqio_obj->write_seq($merged_seq_obj);
        }
    }
    return 1;
}

sub _check_seqs {
    my ( $self, $seqs ) = @_;

    my ($seq_len, $seq_id);
    my $nothing_defined = 1;
    for my $s ( @{ $seqs } ){
        if ( defined $s ){
            $nothing_defined = 0;
            $seq_len = $s->length;
            $seq_id  = $s->display_id;
            last;
        }
    }

    return undef if ( $nothing_defined );

    # pad seqs if not all are undef
    my @padded;
    for my $s ( @{ $seqs } ){
        if ( defined $s ){
            push( @padded, $s );
        }
        else {
            my $bio_seq = Bio::Seq->new( 
                -seq => 'N' x $seq_len,
                -id  => $seq_id,
            );
            push( @padded, $bio_seq );
        }
    }

    return \@padded;
}

sub _strip_id_from_name {
    my ( $self, $name_with_id_at_end ) = @_;
    if ( $name_with_id_at_end =~ /(.+)_[\d]+/ ) {
        return $1;
    }
    else {
        return $name_with_id_at_end;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

