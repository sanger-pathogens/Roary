package Bio::PanGenome::OrderGenes;

# ABSTRACT: Take in GFF files and create a matrix of what genes are beside what other genes

=head1 SYNOPSIS

Take in the analyse groups and create a matrix of what genes are beside what other genes
   use Bio::PanGenome::OrderGenes;
   
   my $obj = Bio::PanGenome::OrderGenes->new(
     analyse_groups_obj => $analyse_groups_obj,
     gff_files => ['file1.gff','file2.gff']
   );
   $obj->create_matrix;

=cut

use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::ContigsToGeneIDsFromGFF;

has 'gff_files'           => ( is => 'ro', isa => 'ArrayRef',  required => 1 );
has 'analyse_groups_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups',  required => 1 );
has 'group_order'         => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build_group_order');

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

sub create_matrix
{
  my ($self) = @_;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
