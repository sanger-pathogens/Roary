package Bio::PanGenome::GenePoolExpansion;

# ABSTRACT: take in an array of files and output a matrix with number of new genes found when you add each file

=head1 SYNOPSIS

take in an array of files and output a matrix with number of new genes found when you add each file
   use Bio::PanGenome::GenePoolExpansion;
   
   my $obj = Bio::PanGenome::GenePoolExpansion->new(
     group_statistics_obj => $group_statistics
   );

   $obj->gene_pool_expansion();
=cut

use Moose;
use List::Util qw(shuffle min max );
use Statistics::Basic qw(:all);
use Bio::PanGenome::Plot::GenePoolExpansionPlot;

has 'group_statistics_obj'      => ( is => 'ro', isa => 'Bio::PanGenome::GroupStatistics',        required => 1 );
has 'number_of_iterations'      => ( is => 'ro', isa => 'Int', default => 10 );
has 'gene_pool_expansion'       => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_gene_pool_expansion' );
has 'output_filename'       => ( is => 'ro', isa => 'Str', default => 'gene_count.png' );

has '_mean_objects'       => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__mean_objects' );

sub create_plot
{
  my($self) = @_;
  my $plot_obj = Bio::PanGenome::Plot::GenePoolExpansionPlot->new(
      gene_pool_expansion  => $self,
      output_filename      => $self->output_filename
    );
  $plot_obj->create_plot();
}

sub _shuffle_input_files
{
  my($self) = @_;
  my @shuffled_input_files = shuffle(@{$self->group_statistics_obj->_sorted_file_names});
  return \@shuffled_input_files;
}


sub _build_gene_pool_expansion
{
  my($self) = @_;
  
  my @all_iteration_results;
  for(my $i=0; $i < $self->number_of_iterations; $i++)
  {
    for(my $gene_count = 0; $gene_count <  @{$self->_single_iteration_gene_expansion}; $gene_count++)
    {
      push(@{$all_iteration_results[$gene_count]}, $self->_single_iteration_gene_expansion->[$gene_count]);
    }
  }
  return \@all_iteration_results;
}


sub high_values
{
  my($self) = @_;
  my @high_values;

  for my $iteration_values ( @{$self->gene_pool_expansion} )
  {
    push(@high_values, max(@{$iteration_values}));
  }
  
  return \@high_values;
}

sub low_values
{
  my($self) = @_;
  my @low_values;
  
  for my $iteration_values ( @{$self->gene_pool_expansion} )
  {
    push(@low_values, min(@{$iteration_values}));
  }
  
  return \@low_values;
}


sub _build__mean_objects
{
  my($self) = @_;
  
  my @values;
  for my $iteration_values ( @{$self->gene_pool_expansion} )
  {
    my $mean_obj   = mean(@{$iteration_values});
    push(@values, $mean_obj );
  }
  
  return \@values;
}

sub high_std_dev_values
{
  my($self) = @_;
  
  my @values;
  for my $mean_obj ( @{$self->_mean_objects} )
  {
    my $stddev_obj = stddev($mean_obj->query_vector );
    push(@values,  $mean_obj->query + $stddev_obj->query );
  }
  
  return \@values;
}

sub low_std_dev_values
{
  my($self) = @_;
  
  my @values;
  for my $mean_obj ( @{$self->_mean_objects} )
  {
    my $stddev_obj = stddev($mean_obj->query_vector );
    push(@values, $mean_obj->query - $stddev_obj->query);
  }
  
  return \@values;
}

sub key_values
{
  my($self) = @_;
  my @key_values;

  for(my $i = 0; $i<  @{$self->gene_pool_expansion} ; $i++)
  {
    push(@key_values, ($i+1));
  }
  
  return \@key_values;
}


sub _single_iteration_gene_expansion
{
  my($self) = @_;
  my %existing_groups;
  my @genes_added_per_file;
  my $shuffled_input_files = $self->_shuffle_input_files();
  for my $input_file (@{$shuffled_input_files})
  {
    my $new_group_counter = 0;
    my $existing_group_counter = 0;
    my $new_groups = $self->group_statistics_obj->_files_to_groups->{$input_file};
    
    for my $group (@{ $new_groups })
    {
      if(defined($existing_groups{$group}))
      {
        $existing_group_counter++;
      }
      else
      {
        $new_group_counter++;
      }
      $existing_groups{$group}++;
    }
    push(@genes_added_per_file,$new_group_counter);
  }
  return \@genes_added_per_file;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
