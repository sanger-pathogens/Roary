package Bio::Roary::SampleOrder;

# ABSTRACT: Take in a tree file and return an ordering of the samples

=head1 SYNOPSIS

Take in a tree file and return an ordering of the samples. Defaults to depth first search
   use Bio::Roary::SampleOrder;
   
   my $obj = Bio::Roary::SampleOrder->new(
       tree_file        => $tree_file,
     );
   $obj->ordered_samples();

=cut

use Moose;
use Bio::TreeIO;

has 'tree_file'       => ( is => 'ro', isa => 'Str',      required => 1 );
has 'tree_format'     => ( is => 'ro', isa => 'Str',      default  => 'newick' );
has 'ordered_samples' => ( is => 'ro', isa => 'ArrayRef', lazy     => 1, builder => '_build_ordered_samples' );

# 'b|breadth' first order or 'd|depth' first order
has 'search_strategy' => ( is => 'ro', isa => 'Str', default =>  'depth' );
has 'sortby' => (is => 'ro', isa => 'Maybe[Str]');


sub _build_ordered_samples {
    my ($self) = @_;
    my $input = Bio::TreeIO->new(
        -file   => $self->tree_file,
        -format => $self->tree_format
    );
    my $tree = $input->next_tree;
    my @taxa;
    for my $leaf_node ( $tree->get_nodes($self->search_strategy,$self->sortby) ) {
      if($leaf_node->is_Leaf)
      {
        push( @taxa, $leaf_node->id );
      }
    }
    return \@taxa;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

