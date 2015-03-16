package Bio::Roary::GeneNamesFromGFF;

# ABSTRACT: Parse a GFF and efficiently extract ID -> Gene Name

=head1 SYNOPSIS

Parse a GFF and efficiently extract ID -> Gene Name
   use Bio::Roary::GeneNamesFromGFF;
   
   my $obj = Bio::Roary::GeneNamesFromGFF->new(
     gff_file   => 'abc.gff'
   );
   $obj->ids_to_gene_name;

=cut

use Moose;

use Bio::Tools::GFF;
with 'Bio::Roary::ParseGFFAnnotationRole';

has 'ids_to_gene_name' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_ids_to_gene_name' );
has 'ids_to_product' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

# Parsing with the perl GFF module is exceptionally slow.
sub _build_ids_to_gene_name {
    my ($self) = @_;
    my %id_to_gene_name;
    
    open( my $fh, '-|', $self->_gff_fh_input_string ) or die "Couldnt open GFF file";
    while(<$fh>)
    {
      chomp;
      my $line = $_;   
      my $id_name;
      if($line =~/ID=["']?([^;"']+)["']?;?/i)
      {
        $id_name = $1;
        $id_name =~ s!"!!g;
      }
      else
      {
        next;
      }
      
      if($line =~/gene=["']?([^;"']+)["']?;?/i)
      {
          my $gene_name = $1;
          $gene_name =~ s!"!!g;
          next if ( $gene_name eq "" );
          $id_to_gene_name{$id_name} = $gene_name;
      }
      
      if($line =~/product=["']?([^;,"']+)[,"']?;?/i)
      {
              my $product = $1;
              $self->ids_to_product->{$id_name} = $product;
      }
      
    }
    close($fh);
    return \%id_to_gene_name;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
