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

has 'multifasta_files'  => ( is => 'ro', isa => 'ArrayRef',   required => 1 );
has 'output_filename'   => ( is => 'ro', isa => 'Str',        default  => 'core_alignment.aln' );
has '_output_seqio_obj' => ( is => 'ro', isa => 'Bio::SeqIO', lazy     => 1, builder => '_build__output_seqio_obj' );
has '_input_seqio_objs' => ( is => 'ro', isa => 'ArrayRef',   lazy     => 1, builder => '_build__input_seqio_objs' );

has '_gene_lengths'     => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );

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

sub _build__gene_lengths {
    return [];
}

# handles missing data, so long as the genes are in the same order in 
# all files and first file has no missing genes
sub merge_files {
    my ($self) = @_;

    my $reached_eof = 0;
    my %seq_hold = ();
    while ( $reached_eof == 0 ) {
        last unless ( scalar @{ $self->_input_seqio_objs} > 0 );
        # read sequence objects from SeqIO objects
        # if a gene occurs out of sequence, place in a holding area until
        # correct place comes around

        my $first_name = '';
        my @c_seqs;
        my $c = 0;
        for my $input_seq_io ( @{ $self->_input_seqio_objs } ) {
            my $next_seq;

            # check if anything is held for this gene
            if ( defined $seq_hold{$first_name}->{$c} ){
                $next_seq = $seq_hold{$first_name}->{$c}; # pull from hold
                delete $seq_hold{$first_name}->{$c};
            }
            else {
                $next_seq = $input_seq_io->next_seq;
                $self->_gene_lengths->[$c] = $next_seq->length unless ( defined $self->_gene_lengths->[$c] );
            }

            my $gene_prefix = '';
            if ( defined $next_seq ){
                $gene_prefix = $self->_strip_id_from_name( $next_seq->display_id );
                $first_name = $gene_prefix if ( $first_name eq '' );
            }

            if ( $gene_prefix ne $first_name ){
                # place in hold
                $seq_hold{$gene_prefix}->{$c} = $next_seq;
                push( @c_seqs, undef );
            }
            else {
                push( @c_seqs, $next_seq );
            }
            $c++;
        }

        # check if any seqs need padding or whether to end the while loop
        my $fixed_seqs = $self->_check_seqs_and_pad( \@c_seqs );
        last unless ( defined($fixed_seqs) );
        
        # concatenate sequences
        my $merged_sequence = '';
        for my $current_sequence ( @{ $fixed_seqs } ){
            $merged_sequence .= $current_sequence->seq;
            
        }

        # write to file
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

sub _check_seqs_and_pad {
    my ( $self, $seqs ) = @_;

    my ($seq_len, $seq_id);
    my $nothing_defined = 1;
    for my $s ( @{ $seqs } ){
        if ( defined $s ){
            $nothing_defined = 0;
            $seq_id  = $s->display_id;
            last;
        }
    }

    return undef if ( $nothing_defined );

    # pad seqs if not all are undef
    my @padded;
    my $c = 0;
    for my $s ( @{ $seqs } ){
        if ( defined $s ){
            push( @padded, $s );
        }
        else {
            $seq_len = $self->_gene_lengths->[$c];
            my $bio_seq = Bio::Seq->new( 
                -seq => 'N' x $seq_len,
                -id  => $seq_id,
            );
            push( @padded, $bio_seq );
        }
        $c++;
    }

    return \@padded;
}

sub _strip_id_from_name {
    my ( $self, $name_with_id_at_end ) = @_;
    if ( $name_with_id_at_end =~ /(.+)_[\d]+$/ ) {
        return $1;
    }
    else {
        return $name_with_id_at_end;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

