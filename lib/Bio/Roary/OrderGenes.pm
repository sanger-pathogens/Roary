package Bio::Roary::OrderGenes;

# ABSTRACT: Take in GFF files and create a matrix of what genes are beside what other genes

=head1 SYNOPSIS

Take in the analyse groups and create a matrix of what genes are beside what other genes
   use Bio::Roary::OrderGenes;
   
   my $obj = Bio::Roary::OrderGenes->new(
     analyse_groups_obj => $analyse_groups_obj,
     gff_files => ['file1.gff','file2.gff']
   );
   $obj->groups_to_contigs;

=cut

use Moose;
use Bio::Roary::Exceptions;
use Bio::Roary::AnalyseGroups;
use Bio::Roary::ContigsToGeneIDsFromGFF;
use Graph;
use Graph::Writer::Dot;

has 'gff_files'           => ( is => 'ro', isa => 'ArrayRef',  required => 1 );
has 'analyse_groups_obj'  => ( is => 'ro', isa => 'Bio::Roary::AnalyseGroups',  required => 1 );

has 'core_definition'           => ( is => 'ro', isa => 'Num', default  => 1.0 );
has 'pan_graph_filename'        => ( is => 'ro', isa => 'Str',  default => 'core_accessory_graph.dot' );
has 'accessory_graph_filename'  => ( is => 'ro', isa => 'Str',  default => 'accessory_graph.dot' );

has 'group_order'         => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_group_order');
has 'group_graphs'        => ( is => 'ro', isa => 'Graph',  lazy => 1, builder => '_build_group_graphs');
has 'groups_to_contigs'        => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_groups_to_contigs');
has '_groups_to_file_contigs'  => ( is => 'ro', isa => 'ArrayRef',  lazy => 1, builder => '_build__groups_to_file_contigs');

has '_groups'             => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_groups');
has 'number_of_files'     => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build_number_of_files');
has '_groups_qc'          => ( is => 'ro', isa => 'HashRef', default => sub {{}});

has '_percentage_of_largest_weak_threshold'     => ( is => 'ro', isa => 'Num', default => 0.9);

sub _build_number_of_files
{
  my ($self) = @_;
  return @{$self->gff_files};
}

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
  my @overlapping_hypothetical_gene_ids;
  
  # Open each GFF file
  for my $filename (@{$self->gff_files})
  {
    my $contigs_to_ids_obj = Bio::Roary::ContigsToGeneIDsFromGFF->new(gff_file   => $filename);
    
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
        
        if($contigs_to_ids_obj->overlapping_hypothetical_protein_ids->{$gene_id})
        {
          $self->_groups_qc->{$group_name} = 'Hypothetical protein with no hits to refseq/uniprot/clusters/cdd/tigrfams/pfam overlapping another protein with hits';
        }
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
      #$group_order{$group_to}{$group_from}++;
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
  return Graph->new(undirected => 1);
}


sub _save_graph_to_file
{
	my($self, $graph, $output_filename) = @_;
    my $writer = Graph::Writer::Dot->new();
    $writer->write_graph($graph, $output_filename);
	return 1;
}

sub _add_groups_to_graph
{
  my($self) = @_;

  for my $current_group (keys %{$self->group_order()})
  {
    for my $group_to (keys %{$self->group_order->{$current_group}})
    {
      my $weight = 1.0/($self->group_order->{$current_group}->{$group_to} );
      $self->group_graphs->add_weighted_edge($current_group,$group_to, $weight);
    }
  }

}


sub _reorder_connected_components
{
   my($self, $graph_groups) = @_;
   my @ordered_graph_groups;
   my @paths_and_weights;
   
   for my $graph_group( @{$graph_groups})
   {
       my %groups;
       $groups{$_}++ for (@{$graph_group});
	   my $edge_sum = 0;
	   
       for my $current_group (keys %groups)
       {
           for my $group_to (keys %{$self->group_order->{$current_group}})
           {
			   next unless defined($groups{ $group_to });
			   $edge_sum += $self->group_order->{$current_group}->{$group_to};
		   }
       }
	   
       push(@paths_and_weights, { 
         path           => $graph_group,
         average_weight => $edge_sum
       });
	   
   }
   my @ordered_paths_and_weights =  sort { $a->{average_weight} <=> $b->{average_weight} } @paths_and_weights;
   @ordered_graph_groups = map { $_->{path}} @ordered_paths_and_weights;
   return \@ordered_graph_groups;
}

sub _build_groups_to_contigs
{
  my($self) = @_;
  $self->_add_groups_to_graph;

  my %groups_to_contigs;
  my $counter = 1;
  my $overall_counter = 1 ;
  my $counter_filtered = 1;
  
  # Accessory
  my $accessory_graph = $self->_create_accessory_graph;
  my @group_graphs = $accessory_graph->connected_components();
  my $reordered_graphs = $self->_reorder_connected_components(\@group_graphs);
  
  $self->_save_graph_to_file($accessory_graph,$self->accessory_graph_filename);
  
  for my $contig_groups (@{$reordered_graphs})
  {
    my $order_counter = 1;
  
    for my $group_name (@{$contig_groups})
    {
      $groups_to_contigs{$group_name}{accessory_label} = $counter;
      $groups_to_contigs{$group_name}{accessory_order} = $order_counter;
      $groups_to_contigs{$group_name}{'accessory_overall_order'} = $overall_counter;
      $order_counter++;
      $overall_counter++;
    }
    $counter++;
  }

  # Core + accessory
  my @group_graphs_all = $self->group_graphs->connected_components();
  my $reordered_graphs_all = $self->_reorder_connected_components(\@group_graphs_all);
  $self->_save_graph_to_file($self->group_graphs,$self->pan_graph_filename);
  
  $overall_counter = 1;
  $counter = 1;
  $counter_filtered = 1;
  for my $contig_groups (@{$reordered_graphs_all})
  {
    my $order_counter = 1;
  
    for my $group_name (@{$contig_groups})
    {
      $groups_to_contigs{$group_name}{label} = $counter;
      $groups_to_contigs{$group_name}{comment} = '';
      $groups_to_contigs{$group_name}{order} = $order_counter;
      $groups_to_contigs{$group_name}{'core_accessory_overall_order'} = $overall_counter;
      
      if(@{$contig_groups} <= 2)
      {
        $groups_to_contigs{$group_name}{comment} = 'Investigate';
      }
      elsif($self->_groups_qc->{$group_name})
      {
        $groups_to_contigs{$group_name}{comment} = $self->_groups_qc->{$group_name};
      }
      else
      {
        $groups_to_contigs{$group_name}{'core_accessory_overall_order_filtered'} = $counter_filtered;
        $counter_filtered++;
      }
      $order_counter++;
      $overall_counter++;
    }
    $counter++;
  }
  
  $counter_filtered = 1;
  for my $contig_groups (@{$reordered_graphs})
  {    
    for my $group_name (@{$contig_groups})
    {
        if( (!defined($groups_to_contigs{$group_name}{comment}))  ||  (defined($groups_to_contigs{$group_name}{comment}) && $groups_to_contigs{$group_name}{comment} eq '') )
        {
          $groups_to_contigs{$group_name}{'accessory_overall_order_filtered'} = $counter_filtered;
          $counter_filtered++;
        }
    }
  }
  

  return \%groups_to_contigs;
}

sub _create_accessory_graph
{
  my($self) = @_;
  my $graph = Graph->new(undirected => 1);
  
  my %core_groups;
  my %inbound_sum;
  for my $current_group (keys %{$self->group_order()})
  {
	my $outbound_links_sum = 0;
    for my $group_to (keys %{$self->group_order->{$current_group}})
    {
		$outbound_links_sum += $self->group_order->{$current_group}->{$group_to};
		$inbound_sum{$group_to} += $self->group_order->{$current_group}->{$group_to};
    }
	
    if($outbound_links_sum >= ($self->number_of_files * $self->core_definition) )
    {
  	  $core_groups{$current_group} = $outbound_links_sum;
    }
  }
  
  for my $current_group (keys %inbound_sum)
  {
	  if($inbound_sum{$current_group} >= ($self->number_of_files * $self->core_definition))
	  {
	  	$core_groups{$current_group} = $inbound_sum{$current_group};
	  }
  }
  

  for my $current_group (keys %{$self->group_order()})
  {
    next if(defined($core_groups{$current_group}));
    for my $group_to (keys %{$self->group_order->{$current_group}})
    {
		if(defined($core_groups{$group_to}))
		{
			$graph->add_vertex($current_group);
		}
		else
		{
	        my $weight = 1.0/($self->group_order->{$current_group}->{$group_to} );
	        $graph->add_weighted_edge($current_group,$group_to, $weight);
		}
    }
  }
  #$self->_remove_weak_edges_from_graph($graph);
  return $graph;
}

sub _remove_weak_edges_from_graph
{
  my($self, $graph) = @_;
  
  for my $current_group (keys %{$self->group_order()})
  {
    next unless($graph->has_vertex($current_group));
    
    my $largest = 0;
    for my $group_to (keys %{$self->group_order->{$current_group}})
    {
      if($largest < $self->group_order->{$current_group}->{$group_to})
      {
        $largest = $self->group_order->{$current_group}->{$group_to};
      }
    }
    my $threshold_link = int($largest*$self->_percentage_of_largest_weak_threshold);
    next if($threshold_link  <= 1);
    
    for my $group_to (keys %{$self->group_order->{$current_group}})
    {
      if($self->group_order->{$current_group}->{$group_to} < $threshold_link  && $graph->has_edge($current_group,$group_to))
      {
        $graph->delete_edge($current_group, $group_to);
      }
    }
  }
  
}




no Moose;
__PACKAGE__->meta->make_immutable;

1;
