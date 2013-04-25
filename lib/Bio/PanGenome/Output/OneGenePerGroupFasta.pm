package Bio::PanGenome::Output::OneGenePerGroupFasta;

# ABSTRACT:  Output a fasta file with one gene per group

=head1 SYNOPSIS

Output a fasta file with one gene per group
   use Bio::PanGenome::Output::OneGenePerGroupFasta;
   
   my $obj = Bio::PanGenome::Output::OneGenePerGroupFasta->new(
       analyse_groups  => $analyse_groups,
       output_filename => 'abc'
     );
   $obj->create_file();

=cut

use Moose;
use Bio::SeqIO;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;

has 'analyse_groups'  => ( is => 'ro', isa  => 'Bio::PanGenome::AnalyseGroups', required => 1 );
has 'output_filename' => ( is => 'ro', isa  => 'Str',                           default  => 'pan_genome.fa' );
has '_output_seq_io'  => ( is => 'ro', lazy => 1,                               builder  => '_build__output_seq_io' );
has '_groups' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__groups' );

sub _build__output_seq_io {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => ">" . $self->output_filename, -format => 'Fasta' );
}

sub _build__groups {
    my ($self) = @_;
    my @groups = keys %{ $self->analyse_groups->_groups_to_genes };
    return \@groups;
}

sub _lookup_sequence {
    my ( $self, $gene, $filename ) = @_;

    my $fasta_obj = Bio::SeqIO->new( -file => $filename, -format => 'Fasta' );
    while ( my $seq = $fasta_obj->next_seq() ) {
        next unless ( $seq->display_id eq $gene );
        return $seq;
    }
    return undef;
}

sub create_file {
    my ($self) = @_;

    for my $group ( @{ $self->_groups } ) {
        my $gene = $self->analyse_groups->_groups_to_genes->{$group}->[0];
        my $seq = $self->_lookup_sequence( $gene, $self->analyse_groups->_genes_to_file->{$gene} );
        next unless ( defined($seq) );
        $self->_output_seq_io->write_seq($seq);
    }

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

