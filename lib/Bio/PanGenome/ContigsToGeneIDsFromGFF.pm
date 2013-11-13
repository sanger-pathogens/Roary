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

# Manually parse the GFF file because the BioPerl module is too slow
sub _build_contig_to_ids
{
  my ($self) = @_;
  my %contigs_to_ids;
  
  open( my $fh, '-|', $self->_gff_fh_input_string ) or die "Couldnt open GFF file";
  while(<$fh>)
  {
    chomp;
    my $line = $_;   
    my $id_name;
    if($line =~/ID=([^;]+);/)
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
  }
  close($fh);
  return \%contigs_to_ids;
}

sub _build__awk_filter {
    my ($self) = @_;
    return
        'awk \'BEGIN {FS="\t"};{ if ($3 ~/'
      . $self->_tags_to_filter
      . '/) print $1"\t"$9;}\' ';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
