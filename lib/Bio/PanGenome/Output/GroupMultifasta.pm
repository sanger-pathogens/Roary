package Bio::Roary::Output::GroupMultifasta;

# ABSTRACT:  Take in a group and create a multifasta file

=head1 SYNOPSIS

Take in a group and create a multifasta file
   use Bio::Roary::Output::GroupMultifasta;
   
   my $obj = Bio::Roary::Output::GroupMultifasta->new(
       group_name      => 'aaa',
       analyse_groups  => $analyse_groups,
       output_filename_base => 'abc'
     );
   $obj->create_file();

=cut

use Moose;
use Bio::SeqIO;
use Bio::Roary::Exceptions;
use Bio::Roary::AnalyseGroups;

has 'group_name'           => ( is => 'ro', isa => 'Str',                           required => 1 );
has 'analyse_groups'       => ( is => 'ro', isa => 'Bio::Roary::AnalyseGroups', required => 1 );
has 'output_filename_base' => ( is => 'ro', isa => 'Str',                           default  => 'output_groups' );
has '_genes'         => ( is => 'ro', isa  => 'ArrayRef', lazy    => 1, builder => '_build__genes' );
has '_output_seq_io' => ( is => 'ro', lazy => 1,          builder => '_build__output_seq_io' );

sub _build__output_seq_io {
    my ($self) = @_;
    my $output_name = $self->output_filename_base . '_' . $self->group_name;
    $output_name =~ s!\W!_!g;
    $output_name .= '.fa';
    return Bio::SeqIO->new( -file => ">" . $output_name, -format => 'Fasta' );
}

sub _build__genes {
    my ($self) = @_;
    return $self->analyse_groups->_groups_to_genes->{ $self->group_name };
}

sub _lookup_sequence {
    my ( $self, $gene, $filename ) = @_;
    return undef if(! defined($filename));
    my $fasta_obj = Bio::SeqIO->new( -file => $filename, -format => 'Fasta' );
    while ( my $seq = $fasta_obj->next_seq() ) {
        next unless ( $seq->display_id eq $gene );
        return $seq;
    }
    return undef;
}

sub create_file {
    my ($self) = @_;
    for my $gene ( @{ $self->_genes } ) {
        my $seq = $self->_lookup_sequence( $gene, $self->analyse_groups->_genes_to_file->{$gene} );
        next unless ( defined($seq) );
        $self->_output_seq_io->write_seq($seq);
    }

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

