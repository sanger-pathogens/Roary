package Bio::PanGenome::OrderGenes;

# ABSTRACT: Take in GFF files and create a matrix of what genes are beside what other genes

=head1 SYNOPSIS

Take in the analyse groups and create a matrix of what genes are beside what other genes
   use Bio::PanGenome::OrderGenes;
   
   my $obj = Bio::PanGenome::OrderGenes->new(
     analyse_groups_obj => $analyse_groups_obj,
     gff_files => ['file1.gff','file2.gff']
   );
   $obj->groups_to_contigs;

=cut

use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::ContigsToGeneIDsFromGFF;
use Boost::Graph;

has 'gff_files'           => ( is => 'ro', isa => 'ArrayRef',  required => 1 );
has 'analyse_groups_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups',  required => 1 );
has 'group_order'         => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_group_order');
has 'group_graphs'        => ( is => 'ro', isa => 'Boost::Graph',  lazy => 1, builder => '_build_group_graphs');
has 'groups_to_contigs'        => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_groups_to_contigs');

has '_groups'             => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_groups');

sub _build_groups
{
  my ($self) = @_;
  my %groups;
  for my $group_name (@{$self->analyse_groups_obj->_groups})
  {
    $groups{$group_name}++;
  }
  return \%groups;
}

sub _build_group_order
{
  my ($self) = @_;
  my %group_order;
  
  # Open each GFF file
  for my $filename (@{$self->gff_files})
  {
    my $contigs_to_ids_obj = Bio::PanGenome::ContigsToGeneIDsFromGFF->new(gff_file   => $filename);
    
    # Loop over each contig in the GFF file
    for my $contig_name (keys %{$contigs_to_ids_obj->contig_to_ids})
    {
      my @groups_on_contig;
      # loop over each gene in each contig in the GFF file
      for my $gene_id (@{$contigs_to_ids_obj->contig_to_ids->{$contig_name}})
      {
        # convert to group name
        my $group_name = $self->analyse_groups_obj->_genes_to_groups->{$gene_id};
        next unless(defined($group_name));
        push(@groups_on_contig, $group_name);
      }
      
      for(my $i = 1; $i < @groups_on_contig; $i++)
      {
        my $group_from = $groups_on_contig[$i -1];
        my $group_to = $groups_on_contig[$i];
        $group_order{$group_from}{$group_to}++;
        # TODO: remove because you only need half the matix
        $group_order{$group_to}{$group_from}++;
      }
    }
  }

  return \%group_order;
}

sub _build_group_graphs
{
  my($self) = @_;
  return  Boost::Graph->new(directed=>0);
}


sub _add_groups_to_graph
{
  my($self) = @_;

  for my $current_group (keys %{$self->group_order()})
  {
    for my $group_to (keys %{$self->group_order->{$current_group}})
    {
      my $weight = 1.0/ ($self->group_order->{$current_group}->{$group_to}) ;
      $self->group_graphs->add_edge(node1=>$current_group, node2=>$group_to, weight=>$weight);
    }
  }

}


sub _get_connected_nodes
{
  my($self) = @_;
  
  my @all_groups = keys %{$self->_groups};
  my $search_group = $all_groups[0];
  
  my $connected_groups = $self->group_graphs->breadth_first_search($search_group);
  for my $group_name (@{$connected_groups })
  {
    delete($self->_groups->{$group_name});
  }
  if(defined($self->_groups->{$search_group}))
  {
    delete($self->_groups->{$search_group});
    push(@{$connected_groups},$search_group );
  }

  return  $connected_groups;
}

sub _build_groups_to_contigs
{
  my($self) = @_;
  $self->_add_groups_to_graph;

  my %groups_to_contigs;
  my $counter = 1;
  while((keys %{$self->_groups} ) > 0)
  {
    my $contig_groups = $self->_get_connected_nodes;
    for my $group_name (@{$contig_groups})
    {
      $groups_to_contigs{$group_name}{label} = $counter;
      $groups_to_contigs{$group_name}{comment} = '';
      if(@{$contig_groups} == 1)
      {
        $groups_to_contigs{$group_name}{comment} = 'Contamination';
      }
    }
    $counter++;
  }
  
  $self->group_graphs->connected_components;


  return \%groups_to_contigs;
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
