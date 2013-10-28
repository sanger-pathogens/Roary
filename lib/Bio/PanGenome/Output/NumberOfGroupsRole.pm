package Bio::PanGenome::Output::NumberOfGroupsRole;

# ABSTRACT: A role with common functionality for outputting stats on the number of groups

=head1 SYNOPSIS

# ABSTRACT: A role with common functionality for outputting stats on the number of groups
   with 'Bio::PanGenome::Output::NumberOfGroupsRole';

=cut

use Moose::Role;
use List::Util qw(shuffle);

has 'group_statistics_obj'      => ( is => 'ro', isa => 'Bio::PanGenome::GroupStatistics',        required => 1 );
has 'number_of_iterations'      => ( is => 'ro', isa => 'Int', default => 100 );
has 'gene_pool_expansion'       => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_gene_pool_expansion' );
has 'output_filename'           => ( is => 'ro', isa => 'Str', default => 'number_of_new_genes.png' );
has 'output_raw_filename'       => ( is => 'ro', isa => 'Str', default => 'number_of_new_genes.tab' );

sub create_raw_output_file
{
  my($self) = @_;
  open(my $fh, '>', $self->output_raw_filename);
  for my $iterations (@{$self->gene_pool_expansion})
  {
    print {$fh} join("\t",@{$iterations});
    print {$fh} "\n";
  }
  close($fh);
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




1;
