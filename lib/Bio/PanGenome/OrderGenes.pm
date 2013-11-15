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
use Data::Dumper;

has 'gff_files'           => ( is => 'ro', isa => 'ArrayRef',  required => 1 );
has 'analyse_groups_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups',  required => 1 );
has 'group_order'         => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_group_order');
has 'group_graphs'        => ( is => 'ro', isa => 'Boost::Graph',  lazy => 1, builder => '_build_group_graphs');
has 'groups_to_contigs'        => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_groups_to_contigs');
has '_groups_to_file_contigs'  => ( is => 'ro', isa => 'ArrayRef',  lazy => 1, builder => '_build__groups_to_file_contigs');

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


sub _build__groups_to_file_contigs
{
  my ($self) = @_;
  my @groups_to_contigs;
  
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
      push(@groups_to_contigs,\@groups_on_contig);
    }
  }
      
  return \@groups_to_contigs;
  
}

sub _build_group_order
{
  my ($self) = @_;
  my %group_order;
  
  for my $groups_on_contig (@{$self->_groups_to_file_contigs})
  {
    for(my $i = 1; $i < @{$groups_on_contig}; $i++)
    {
      my $group_from = $groups_on_contig->[$i -1];
      my $group_to = $groups_on_contig->[$i];
      $group_order{$group_from}{$group_to}++;
      # TODO: remove because you only need half the matix
      $group_order{$group_to}{$group_from}++;
    }
    if(@{$groups_on_contig} == 1)
    {
       my $group_from = $groups_on_contig->[0];
       my $group_to = $groups_on_contig->[0];
       $group_order{$group_from}{$group_to}++;
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
      my $weight = 1.0/($self->group_order->{$current_group}->{$group_to} );
      $self->group_graphs->add_edge(node1=>$current_group, node2=>$group_to, weight=>$weight);
    }
  }

}


sub _build_groups_to_contigs
{
  my($self) = @_;
  $self->_add_groups_to_graph;

  my %groups_to_contigs;
  my $counter = 1;
  
  # connected_components seg faults if you dont run breadth_first_search first
  my @all_groups = keys %{$self->_groups};
  $self->group_graphs->breadth_first_search($all_groups[0]);
  my $groups_to_contigs = $self->group_graphs->connected_components;
  
  for my $groups_to_contig (@{ $groups_to_contigs})
  {
    my $contig_groups = $groups_to_contig;
    my $order_counter = 1;
    my $reordered_group = $self->_reorder_contig($contig_groups);
    
    for my $group_name (@{$reordered_group})
    {
      $groups_to_contigs{$group_name}{label} = $counter;
      $groups_to_contigs{$group_name}{comment} = '';
      $groups_to_contigs{$group_name}{order} = $order_counter;
      if(@{$contig_groups} <= 4)
      {
        $groups_to_contigs{$group_name}{comment} = 'Contamination';
      }
      $order_counter++;
    }
    $counter++;
  }

  return \%groups_to_contigs;
}


sub _reorder_contig
{
  my($self,$groups_to_contigs) = @_;

  my $longest_path ;  
  my %current_groups_to_contigs;
  
  for my $group (@{$groups_to_contigs})
  {
    $current_groups_to_contigs{$group}++;
  }
  
  my @elements = keys(%current_groups_to_contigs);
  my $starting_node  = $elements[rand @elements];
  
  for(my $i = 0; ($i < 1000 && $i < @elements) ; $i++)
  {
    my $ending_node    = $elements[rand @elements];
    my $current_path   = $self->group_graphs->dijkstra_shortest_path($starting_node, $ending_node);
    next if(! defined($current_path));

    if(!defined($longest_path))
    {
      $longest_path = $current_path;
    } 

    
    if(@{$current_path->{path}} > @{$longest_path->{path}})
    {
       $longest_path = $current_path;
    }
    print Dumper "$i ".@{$longest_path->{path}}."";
    
   }
   
   
   my @output_order;
   for my $group(@{$longest_path->{path}})
   {
     push( @output_order,$group);
   }
   for my $group (keys(%current_groups_to_contigs))
   {
      push( @output_order,$group);
   }
  return \@output_order;

}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
