package Bio::Roary::SortFasta;

# ABSTRACT: sort a fasta file by name

=head1 SYNOPSIS

sort a fasta file by name
   use Bio::Roary::SortFasta;
   
   my $obj = Bio::Roary::SortFasta->new(
     input_filename   => 'infasta.fa',
   );
   $obj->sort_fasta->replace_input_with_output_file;

=cut

use Moose;
use File::Copy;
use Bio::SeqIO;

has 'input_filename'         => ( is => 'ro', isa => 'Str',  required => 1 );
has 'output_filename'        => ( is => 'ro', isa => 'Str',  lazy     => 1, builder => '_build_output_filename' );
has 'make_multiple_of_three' => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'remove_nnn_from_end'    => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'variation_detected'     => ( is => 'rw', isa => 'Bool', default  => 0 );


has '_input_seqio'  => ( is => 'ro', isa => 'Bio::SeqIO', lazy => 1, builder => '_build__input_seqio' );
has '_output_seqio' => ( is => 'ro', isa => 'Bio::SeqIO', lazy => 1, builder => '_build__output_seqio' );

sub _build_output_filename {
    my ($self) = @_;
    return $self->input_filename . ".sorted.fa";
}

sub _build__input_seqio {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => $self->input_filename, -format => 'Fasta' );
}

sub _build__output_seqio {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => ">" . $self->output_filename, -format => 'Fasta' );
}

sub _add_padding_to_make_sequence_length_multiple_of_three {
    my ( $self, $input_seq ) = @_;

    my $seq_length = $input_seq->length();
    if ( $seq_length % 3 == 1 ) {
        $input_seq->seq( $input_seq->seq() . "NN" );
    }
    elsif ( $seq_length % 3 == 2 ) {
        $input_seq->seq( $input_seq->seq() . "N" );
    }

    return $input_seq;
}

sub _remove_nnn_from_all_sequences {
    my ( $self, $input_sequences ) = @_;

    for my $sequence_name ( sort keys %{$input_sequences} ) {
        my $sequence = $input_sequences->{$sequence_name}->seq();
        $sequence =~ s/NNN$//i;
        $input_sequences->{$sequence_name}->seq($sequence);
    }
    return $input_sequences;
}

sub sort_fasta {
    my ($self) = @_;

    my %input_sequences;

    my $nnn_at_end_of_all_sequences = 1;
	my $sequence;
	my $variation_detected = 0;
    while ( my $input_seq = $self->_input_seqio->next_seq() ) {
		$sequence = $input_seq->seq if(!defined($sequence));
        $self->_add_padding_to_make_sequence_length_multiple_of_three($input_seq) if ( $self->make_multiple_of_three );

        $nnn_at_end_of_all_sequences = 0 if ( $nnn_at_end_of_all_sequences == 1 && !( $input_seq->seq() =~ /NNN$/i ) );

        $input_sequences{ $input_seq->display_id } = $input_seq;
		if($sequence ne $input_seq->seq)
		{
			$self->variation_detected(1);
		}
    }

    $self->_remove_nnn_from_all_sequences( \%input_sequences ) if ( $self->remove_nnn_from_end && $nnn_at_end_of_all_sequences );

    for my $sequence_name ( sort keys %input_sequences ) {
        $self->_output_seqio->write_seq( $input_sequences{$sequence_name} );
    }
    return $self;
}

sub replace_input_with_output_file {
    my ($self) = @_;
    move( $self->output_filename, $self->input_filename );
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
