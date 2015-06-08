package Bio::Roary::Output::OneGenePerGroupFasta;

# ABSTRACT:  Output a fasta file with one gene per group

=head1 SYNOPSIS

Output a fasta file with one gene per group
   use Bio::Roary::Output::OneGenePerGroupFasta;
   
   my $obj = Bio::Roary::Output::OneGenePerGroupFasta->new(
       analyse_groups  => $analyse_groups,
       output_filename => 'abc'
     );
   $obj->create_file();

=cut

use Moose;
use Bio::SeqIO;
use Bio::Roary::Exceptions;
use Bio::Roary::AnalyseGroups;

has 'analyse_groups'  => ( is => 'ro', isa  => 'Bio::Roary::AnalyseGroups', required => 1 );
has 'output_filename' => ( is => 'ro', isa  => 'Str',                           default  => 'pan_genome_reference.fa' );
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

sub _lookup_sequences {
    my ( $self, $genes, $filename ) = @_;
    my @sequences;
    
    my %gene_queue;
    for my $gene (@{$genes})
    {
      $gene_queue{$gene}++;
    }
    my $gene_params = join(' ', @{$genes});
    
    open(my $fh,  $filename);
    my $fasta_obj = Bio::SeqIO->new( -fh => $fh, -format => 'Fasta' );
    while ( my $seq = $fasta_obj->next_seq() ) {
        last unless(%gene_queue);
        for my $gene ( keys %gene_queue)
        {
          next unless ( $seq->display_id eq $gene );
          push(@sequences, $seq);
          delete($gene_queue{$gene});
        }
    }
    return \@sequences;
}

sub create_file {
    my ($self) = @_;

    my %filenames_to_genes;
    for my $group ( @{ $self->_groups } ) {
        my @sorted_genes = sort @{$self->analyse_groups->_groups_to_genes->{$group}};
        push(@{$filenames_to_genes{ $self->analyse_groups->_genes_to_file->{$sorted_genes[0]}}},$sorted_genes[0]);
    }
    
    for my $filename (keys %filenames_to_genes)
    {
        my $sequences = $self->_lookup_sequences( $filenames_to_genes{$filename}, $filename );
        next unless ( $sequences );
        for my $seq (@{ $sequences})
        {
        $self->_output_seq_io->write_seq($seq);
      }
    }

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
