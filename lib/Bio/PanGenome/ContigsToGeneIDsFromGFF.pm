package Bio::PanGenome::ContigsToGeneIDsFromGFF;

# ABSTRACT: Parse a GFF and efficiently and extract ordered gene ids on each contig

=head1 SYNOPSIS

Parse a GFF and efficiently and extract ordered gene ids on each contig
   use Bio::PanGenome::ContigsToGeneIDsFromGFF;
   
   my $obj = Bio::PanGenome::ContigsToGeneIDsFromGFF->new(
     gff_file   => 'abc.gff'
   );
   $obj->contig_to_ids;

=cut

use Moose;
use Bio::Tools::GFF;
with 'Bio::PanGenome::ParseGFFAnnotationRole';

has 'contig_to_ids' => ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build_contig_to_ids');

has 'overlapping_hypothetical_protein_ids' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_overlapping_hypothetical_protein_ids');
has '_genes_annotation' => ( is => 'rw', isa => 'HashRef', default => sub{{}});

has '_min_nucleotide_overlap_percentage' => ( is => 'ro', isa => 'Int', default => 10);

# Manually parse the GFF file because the BioPerl module is too slow
sub _build_contig_to_ids
{
  my ($self) = @_;
  my %contigs_to_ids;
  my %genes_annotation;
  
  open( my $fh, '-|', $self->_gff_fh_input_string ) or die "Couldnt open GFF file";
  while(<$fh>)
  {
    chomp;
    my $line = $_;   
    my $id_name;
    if($line =~/ID=["']?([^;"']+)["']?;?/i)
    {
      $id_name= $1;
    }
    else
    {
      next;
    }
    
    my @annotation_elements = split(/\t/,$line);
    # Map gene IDs to the contig
    push(@{$contigs_to_ids{$annotation_elements[0]}}, $id_name);
    
    if($line =~/product=["']?([^;,"']+)[,"']?;?/i)
	
    {
      $genes_annotation{$id_name}{product} = $1;
      if($line =~ /UniProtKB/ || $line =~ /RefSeq/ || $line =~ /protein motif/)
      {
        $genes_annotation{$id_name}{database_annotation_exists} = 1;
      }
      
      $genes_annotation{$id_name}{contig}  = $annotation_elements[0];
      $genes_annotation{$id_name}{start}   = $annotation_elements[1];
      $genes_annotation{$id_name}{end}     = $annotation_elements[2];
    }

  }
  close($fh);
  
  $self->_genes_annotation(\%genes_annotation);
  return \%contigs_to_ids;
}

sub _build_overlapping_hypothetical_protein_ids
{
  my ($self) = @_;
  $self->contig_to_ids;
  
  my %overlapping_protein_ids;

  for my $id_name (keys %{$self->_genes_annotation})
  {
    next if($self->_genes_annotation->{$id_name}->{database_annotation_exists});
    next unless($self->_genes_annotation->{$id_name}->{product} =~ /hypothetical/i);
    
    my $start_coord = $self->_genes_annotation->{$id_name}->{start};
    my $end_coord   = $self->_genes_annotation->{$id_name}->{end}  ;
    
    # look for overlapping annotation which isnt a hypothetical protein
    for my $comparison_id_name (keys %{$self->_genes_annotation})
    {
      next if($self->_genes_annotation->{$id_name}->{contig} ne $self->_genes_annotation->{$comparison_id_name}->{contig});
      next if($id_name eq $comparison_id_name);
      next if($self->_genes_annotation->{$comparison_id_name}->{product} =~ /hypothetical/i);
      
      my $comparison_start_coord = $self->_genes_annotation->{$comparison_id_name}->{start};
      my $comparison_end_coord   = $self->_genes_annotation->{$comparison_id_name}->{end};

      if($comparison_start_coord < $end_coord  && $comparison_end_coord > $start_coord )
      {
        my $percent_overlap = $self->_percent_overlap($start_coord, $end_coord , $comparison_start_coord,$comparison_end_coord);
        if($percent_overlap >= $self->_min_nucleotide_overlap_percentage)
        {
          $overlapping_protein_ids{$id_name}++;
          last;
        }
      }
    }
  }
  return \%overlapping_protein_ids;
}

sub _percent_overlap
{
   my ($self, $start_coord, $end_coord , $comparison_start_coord,$comparison_end_coord) = @_;
   my $size_of_hypothetical_gene =  $end_coord - $start_coord;
   
   my $lower_bound = $start_coord;
   if($comparison_start_coord > $start_coord)
   {
     $lower_bound = $comparison_start_coord;
   }
   my $upper_bound = $end_coord;
   if($comparison_end_coord < $end_coord   )
   {
      $upper_bound = $comparison_end_coord;
   }
   return (($upper_bound-$lower_bound)*100) / $size_of_hypothetical_gene;
}


sub _build__awk_filter {
    my ($self) = @_;
    return
        'awk \'BEGIN {FS="\t"};{ if ($3 ~/'
      . $self->_tags_to_filter
      . '/) print $1"\t"$4"\t"$5"\t"$9;}\' ';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
