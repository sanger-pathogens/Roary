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
has 'ids_to_gene_size' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

# Parsing with the perl GFF module is exceptionally slow.
sub _build_ids_to_gene_name {
    my ($self) = @_;
    my %id_to_gene_name;

    my $gffio = Bio::Tools::GFF->new( -file => $self->gff_file, -gff_version => 3 );
    while ( my $feature = $gffio->next_feature() ) {
        my $gene_id = $self->_get_feature_id($feature);
        next unless ($gene_id);

        if ( $feature->has_tag('gene') ) {
            my ( $gene_name, @junk ) = $feature->get_tag_values('gene');
            $gene_name =~ s!"!!g;
            if ( $gene_name ne "" ) {
                $id_to_gene_name{$gene_id} = $gene_name;
            }
        }
        elsif ( $feature->has_tag('Name') ) {
            my ( $gene_name, @junk ) = $feature->get_tag_values('Name');
            $gene_name =~ s!"!!g;
            if ( $gene_name ne "" ) {
                $id_to_gene_name{$gene_id} = $gene_name;
            }
        }
	
        if ( $feature->has_tag('product') ) {
            my ( $product, @junk ) = $feature->get_tag_values('product');
            $self->ids_to_product->{$gene_id} = $product;
        }
		$self->ids_to_gene_size->{$gene_id} = $feature->end - $feature->start;
    }

    return \%id_to_gene_name;
}

sub _get_feature_id {
    my ( $self, $feature ) = @_;
    my ( $gene_id, @junk );
    if ( $feature->has_tag('ID') ) {
        ( $gene_id, @junk ) = $feature->get_tag_values('ID');
    }
    elsif ( $feature->has_tag('locus_tag') ) {
        ( $gene_id, @junk ) = $feature->get_tag_values('locus_tag');
    }
    else {
        return undef;
    }
    $gene_id =~ s!["']!!g;
    return undef if ( $gene_id eq "" );
    return $gene_id;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
