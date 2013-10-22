package Bio::PanGenome::SampleOrder;

# ABSTRACT: Take in a tree file and return an ordering of the samples

=head1 SYNOPSIS

Take in a tree file and return an ordering of the samples
   use Bio::PanGenome::SampleOrder;
   
   my $obj = Bio::PanGenome::SampleOrder->new(
       tree_file        => $tree_file,
     );
   $obj->ordered_samples();

=cut

use Moose;
use Bio::TreeIO;

has 'tree_file'       => ( is => 'ro', isa => 'Str',      required => 1 );
has 'tree_format'     => ( is => 'ro', isa => 'Str',      default  => 'newick' );
has 'ordered_samples' => ( is => 'ro', isa => 'ArrayRef', lazy     => 1, builder => '_build_ordered_samples' );

sub _build_ordered_samples {
    my ($self) = @_;
    my $input = Bio::TreeIO->new(
        -file   => $self->tree_file,
        -format => $self->tree_format
    );
    my $tree = $input->next_tree;
    my @taxa;
    for my $leaf_node ( $tree->get_leaf_nodes ) {
        push( @taxa, $leaf_node->id );
    }
    return \@taxa;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

