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
use File::Basename;

has 'gff_files'                => ( is => 'ro', isa => 'ArrayRef',                  required => 1 );
has 'analyse_groups_obj'       => ( is => 'ro', isa => 'Bio::Roary::AnalyseGroups', required => 1 );
has 'core_definition'          => ( is => 'ro', isa => 'Num',                       default  => 1.0 );
has 'pan_graph_filename'       => ( is => 'ro', isa => 'Str',                       default  => 'core_accessory_graph.dot' );
has 'accessory_graph_filename' => ( is => 'ro', isa => 'Str',                       default  => 'accessory_graph.dot' );
has 'sample_weights'           => ( is => 'ro', isa => 'Maybe[HashRef]' );
has 'samples_to_clusters'      => ( is => 'ro', isa => 'Maybe[HashRef]' );
has 'group_order' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_group_order' );
has 'groups_to_sample_names' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has 'group_graphs'            => ( is => 'ro', isa => 'Graph',   lazy => 1, builder => '_build_group_graphs' );
has 'groups_to_contigs'       => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_groups_to_contigs' );
has '_groups_to_file_contigs' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build__groups_to_file_contigs' );
has '_groups'                 => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_groups' );
has 'number_of_files'         => ( is => 'ro', isa => 'Int',     lazy => 1, builder => '_build_number_of_files' );
has '_groups_qc' => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has '_percentage_of_largest_weak_threshold' => ( is => 'ro', isa => 'Num', default => 0.9 );

sub _build_number_of_files {
    my ($self) = @_;
    return @{ $self->gff_files };
}

sub _build_groups {
    my ($self) = @_;
    my %groups;
    for my $group_name ( @{ $self->analyse_groups_obj->_groups } ) {
        $groups{$group_name}++;
    }
    return \%groups;
}

sub _build__groups_to_file_contigs {
    my ($self) = @_;

    my @overlapping_hypothetical_gene_ids;
    my %samples_to_groups_contigs;

    # Open each GFF file
    for my $filename ( @{ $self->gff_files } ) {
        my @groups_to_contigs;
        my $contigs_to_ids_obj = Bio::Roary::ContigsToGeneIDsFromGFF->new( gff_file => $filename );

        my ( $sample_name, $directories, $suffix ) = fileparse($filename);
        $sample_name =~ s/\.gff//gi;

        # Loop over each contig in the GFF file
        for my $contig_name ( keys %{ $contigs_to_ids_obj->contig_to_ids } ) {
            my @groups_on_contig;

            # loop over each gene in each contig in the GFF file
            for my $gene_id ( @{ $contigs_to_ids_obj->contig_to_ids->{$contig_name} } ) {

                # convert to group name
                my $group_name = $self->analyse_groups_obj->_genes_to_groups->{$gene_id};
                next unless ( defined($group_name) );

                if ( $contigs_to_ids_obj->overlapping_hypothetical_protein_ids->{$gene_id} ) {
                    $self->_groups_qc->{$group_name} =
'Hypothetical protein with no hits to refseq/uniprot/clusters/cdd/tigrfams/pfam overlapping another protein with hits';
                }
                push( @groups_on_contig, $group_name );
            }
            push( @groups_to_contigs, \@groups_on_contig );
        }
        $samples_to_groups_contigs{$sample_name} = \@groups_to_contigs;
    }

    return \%samples_to_groups_contigs;

}

sub _build_group_order {
    my ($self) = @_;
    my %group_order;

    my %groups_to_sample_names;
    for my $sample_name ( keys %{ $self->_groups_to_file_contigs } ) {
        my $groups_to_file_contigs = $self->_groups_to_file_contigs->{$sample_name};
        for my $groups_on_contig ( @{$groups_to_file_contigs} ) {
            for ( my $i = 1 ; $i < @{$groups_on_contig} ; $i++ ) {
                my $group_from = $groups_on_contig->[ $i - 1 ];
                my $group_to   = $groups_on_contig->[$i];

                if ( defined( $self->sample_weights ) && $self->sample_weights->{$sample_name} ) {
                    $group_order{$group_from}{$group_to} += $self->sample_weights->{$sample_name};
                    push( @{ $groups_to_sample_names{$group_from} }, $sample_name );
                }
                else {
                    $group_order{$group_from}{$group_to}++;
                }
            }
            if ( @{$groups_on_contig} == 1 ) {
                my $group_from = $groups_on_contig->[0];
                my $group_to   = $groups_on_contig->[0];
                if ( defined( $self->sample_weights ) && $self->sample_weights->{$sample_name} ) {
                    $group_order{$group_from}{$group_to} += $self->sample_weights->{$sample_name};
                    push( @{ $groups_to_sample_names{$group_from} }, $sample_name );
                }
                else {
                    $group_order{$group_from}{$group_to}++;
                }
            }
        }
    }

    $self->groups_to_sample_names( \%groups_to_sample_names );
    return \%group_order;
}

sub _build_group_graphs {
    my ($self) = @_;
    return Graph->new( undirected => 1 );
}

sub _save_graph_to_file {
    my ( $self, $graph, $output_filename ) = @_;
    my $writer = Graph::Writer::Dot->new();
    $writer->write_graph( $graph, $output_filename );
    return 1;
}

sub _add_groups_to_graph {
    my ($self) = @_;

    for my $current_group ( keys %{ $self->group_order() } ) {
        for my $group_to ( keys %{ $self->group_order->{$current_group} } ) {
            my $weight = 1.0 / ( $self->group_order->{$current_group}->{$group_to} );
            $self->group_graphs->add_weighted_edge( $current_group, $group_to, $weight );
        }
    }

}

sub _reorder_connected_components {
    my ( $self, $graph_groups ) = @_;
    my @ordered_graph_groups;
    my @paths_and_weights;

    for my $graph_group ( @{$graph_groups} ) {
        my %groups;
        $groups{$_}++ for ( @{$graph_group} );
        my $edge_sum = 0;

        for my $current_group ( keys %groups ) {
            for my $group_to ( keys %{ $self->group_order->{$current_group} } ) {
                next unless defined( $groups{$group_to} );
                $edge_sum += $self->group_order->{$current_group}->{$group_to};
            }
        }

        my %samples_in_graph;
        for my $current_group ( keys %groups ) {
            my $sample_names = $self->groups_to_sample_names->{$current_group};
            if ( defined($sample_names) ) {
                for my $sample_name ( @{$sample_names} ) {
                    $samples_in_graph{$sample_name}++;
                }
            }
        }
        my @sample_names = sort keys %samples_in_graph;

        if ( @{$graph_group} == 1 ) {

            push(
                @paths_and_weights,
                {
                    path           => $graph_group,
                    average_weight => $edge_sum,
                    sample_names   => \@sample_names
                }
            );
        }
        else {
            my $graph = Graph->new( undirected => 1 );
            for my $current_group ( keys %groups ) {
                for my $group_to ( keys %{ $self->group_order->{$current_group} } ) {
                    if ( $groups{$group_to} ) {
                        my $weight = 1 / $self->group_order->{$current_group}->{$group_to};
                        $graph->add_weighted_edge( $current_group, $group_to, $weight );
                    }
                }
            }
            my $minimum_spanning_tree = $graph->minimum_spanning_tree;
            my $dfs_obj               = Graph::Traversal::DFS->new($minimum_spanning_tree);
            my @reordered_dfs_groups  = $dfs_obj->dfs;
            push(
                @paths_and_weights,
                {
                    path           => \@reordered_dfs_groups,
                    average_weight => $edge_sum,
                    sample_names   => \@sample_names
                }
            );
        }

    }

    return $self->_order_by_samples_and_weights( \@paths_and_weights );
}

sub _order_by_samples_and_weights {
    my ( $self, $paths_and_weights ) = @_;

    my @ordered_graph_groups;
    if ( !defined( $self->samples_to_clusters ) ) {
        my @ordered_paths_and_weights = sort { $a->{average_weight} <=> $b->{average_weight} } @{$paths_and_weights};
        @ordered_graph_groups = map { $_->{path} } @ordered_paths_and_weights;
        return \@ordered_graph_groups;
    }

    # Find the largest cluster in each graph and regroup
    my %largest_cluster_to_paths_and_weights;
    for my $graph_details ( @{$paths_and_weights} ) {
        my %cluster_count;
        for my $sample_name ( @{ $graph_details->{sample_names} } ) {
            if ( defined( $self->samples_to_clusters->{$sample_name} ) ) {
                $cluster_count{ $self->samples_to_clusters->{$sample_name} }++;
            }
        }
        my $largest_cluster = ( sort { $cluster_count{$b} <=> $cluster_count{$a} || $a cmp $b} keys %cluster_count )[0];
        if ( !defined($largest_cluster) ) {
            my @ordered_paths_and_weights = sort { $b->{average_weight} <=> $a->{average_weight} } @{$paths_and_weights};
            @ordered_graph_groups = map { $_->{path} } @ordered_paths_and_weights;
            return \@ordered_graph_groups;
        }

        push( @{ $largest_cluster_to_paths_and_weights{$largest_cluster}{graph_details} }, $graph_details );
        $largest_cluster_to_paths_and_weights{$largest_cluster}{largest_cluster_size} += $cluster_count{$largest_cluster};
    }

    # go through each cluster group and order by weight
    my @clustered_ordered_graph_groups;
    for my $cluster_name (
        sort {
            $largest_cluster_to_paths_and_weights{$b}->{largest_cluster_size}
              <=> $largest_cluster_to_paths_and_weights{$a}->{largest_cluster_size}
        } keys %largest_cluster_to_paths_and_weights
      )
    {
		
        my @ordered_paths_and_weights =
          sort { $b->{average_weight} <=> $a->{average_weight} } @{ $largest_cluster_to_paths_and_weights{$cluster_name}->{graph_details} };
        @ordered_graph_groups = map { $_->{path} } @ordered_paths_and_weights;

        for my $graph_group (@ordered_graph_groups) {
            push( @clustered_ordered_graph_groups, $graph_group );
        }
    }
    return \@clustered_ordered_graph_groups;
}

sub _build_groups_to_contigs {
    my ($self) = @_;
    $self->_add_groups_to_graph;

    my %groups_to_contigs;
    my $counter          = 1;
    my $overall_counter  = 1;
    my $counter_filtered = 1;

    # Accessory
    my $accessory_graph  = $self->_create_accessory_graph;
    my @group_graphs     = $accessory_graph->connected_components();
    my $reordered_graphs = $self->_reorder_connected_components( \@group_graphs );

    $self->_save_graph_to_file( $accessory_graph, $self->accessory_graph_filename );

    for my $contig_groups ( @{$reordered_graphs} ) {
        my $order_counter = 1;

        for my $group_name ( @{$contig_groups} ) {
            $groups_to_contigs{$group_name}{accessory_label}           = $counter;
            $groups_to_contigs{$group_name}{accessory_order}           = $order_counter;
            $groups_to_contigs{$group_name}{'accessory_overall_order'} = $overall_counter;
            $order_counter++;
            $overall_counter++;
        }
        $counter++;
    }

    # Core + accessory
    my @group_graphs_all     = $self->group_graphs->connected_components();
    my $reordered_graphs_all = $self->_reorder_connected_components( \@group_graphs_all );
    $self->_save_graph_to_file( $self->group_graphs, $self->pan_graph_filename );

    $overall_counter  = 1;
    $counter          = 1;
    $counter_filtered = 1;
    for my $contig_groups ( @{$reordered_graphs_all} ) {
        my $order_counter = 1;

        for my $group_name ( @{$contig_groups} ) {
            $groups_to_contigs{$group_name}{label}                          = $counter;
            $groups_to_contigs{$group_name}{comment}                        = '';
            $groups_to_contigs{$group_name}{order}                          = $order_counter;
            $groups_to_contigs{$group_name}{'core_accessory_overall_order'} = $overall_counter;

            if ( @{$contig_groups} <= 2 ) {
                $groups_to_contigs{$group_name}{comment} = 'Investigate';
            }
            elsif ( $self->_groups_qc->{$group_name} ) {
                $groups_to_contigs{$group_name}{comment} = $self->_groups_qc->{$group_name};
            }
            else {
                $groups_to_contigs{$group_name}{'core_accessory_overall_order_filtered'} = $counter_filtered;
                $counter_filtered++;
            }
            $order_counter++;
            $overall_counter++;
        }
        $counter++;
    }

    $counter_filtered = 1;
    for my $contig_groups ( @{$reordered_graphs} ) {
        for my $group_name ( @{$contig_groups} ) {
            if (   ( !defined( $groups_to_contigs{$group_name}{comment} ) )
                || ( defined( $groups_to_contigs{$group_name}{comment} ) && $groups_to_contigs{$group_name}{comment} eq '' ) )
            {
                $groups_to_contigs{$group_name}{'accessory_overall_order_filtered'} = $counter_filtered;
                $counter_filtered++;
            }
        }
    }

    return \%groups_to_contigs;
}

sub _create_accessory_graph {
    my ($self) = @_;
    my $graph = Graph->new( undirected => 1 );

    my %core_groups;
    my %group_freq;

    for my $sample_name ( keys %{ $self->_groups_to_file_contigs } ) {
        my $groups_to_file_contigs = $self->_groups_to_file_contigs->{$sample_name};

        for my $groups_on_contig ( @{$groups_to_file_contigs} ) {
            for my $current_group ( @{$groups_on_contig} ) {
                $group_freq{$current_group}++;
            }
        }
    }

    for my $current_group ( keys %{ $self->group_order() } ) {
        next if ( $group_freq{$current_group} >= ( $self->number_of_files * $self->core_definition ) );
		
        for my $group_to ( keys %{ $self->group_order->{$current_group} } ) {
            if ( $group_freq{$group_to} >= ( $self->number_of_files * $self->core_definition ) ) {
                $graph->add_vertex($current_group);
            }
            else {
                my $weight = 1.0 / ( $self->group_order->{$current_group}->{$group_to} );
                $graph->add_weighted_edge( $current_group, $group_to, $weight );
            }
        }
    }

    return $graph;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
