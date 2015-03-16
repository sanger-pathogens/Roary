package Bio::Roary::LookupGeneFiles;

# ABSTRACT: Take in an ordering of genes and a directory and return an ordered list of file locations

=head1 SYNOPSIS

Take in an ordering of genes and a directory and return an ordered list of file locations
   use Bio::Roary::LookupGeneFiles;
   
   my $obj = Bio::Roary::LookupGeneFiles->new(
       multifasta_directory        => 'pan_genome_sequences',
       ordered_genes           => ['gene5','gene2','gene3'],

     );
   $obj->ordered_gene_files();

=cut

use Moose;

has 'multifasta_directory' => ( is => 'ro', isa => 'Str', default => 'pan_genome_sequences' );
has 'ordered_genes'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );

has 'ordered_gene_files' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_ordered_gene_files' );


sub _build_ordered_gene_files
{
  my ($self) = @_;
  my @gene_files;
  for my $gene (@{$self->ordered_genes})
  {
    $gene =~ s!\W!_!gi;
    my $filename = $gene.'.fa.aln';
    my $gene_filepath = join('/',($self->multifasta_directory, $filename));
    
    if(! -e $gene_filepath)
    {
      print "Core gene file missing: ". $gene_filepath."\n";
    }
    else
    {
      push(@gene_files, $gene_filepath);
    }
  }
  return \@gene_files;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

