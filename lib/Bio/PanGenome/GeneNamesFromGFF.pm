package Bio::PanGenome::GeneNamesFromGFF;

# ABSTRACT: Parse a GFF and efficiently extract ID -> Gene Name

=head1 SYNOPSIS

Parse a GFF and efficiently extract ID -> Gene Name
   use Bio::PanGenome::GeneNamesFromGFF;
   
   my $obj = Bio::PanGenome::GeneNamesFromGFF->new(
     gff_file   => 'abc.gff'
   );
   $obj->ids_to_gene_name;

=cut

use Moose;
use Bio::Tools::GFF;

has 'gff_file' => ( is => 'ro', isa => 'Str', required => 1 );

has '_tags_to_filter' => ( is => 'ro', isa => 'Str',             default => 'CDS' );
has '_tags_to_ignore' => ( is => 'ro', isa => 'Str',             default => 'rRNA|tRNA|ncRNA|tmRNA' );
has '_gff_parser'     => ( is => 'ro', isa => 'Bio::Tools::GFF', lazy    => 1, builder => '_build__gff_parser' );
has '_awk_filter'     => ( is => 'ro', isa => 'Str',             lazy    => 1, builder => '_build__awk_filter' );
has '_remove_sequence_filter' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__remove_sequence_filter' );

has 'ids_to_gene_name' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_ids_to_gene_name' );
has 'ids_to_product' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

sub _build_ids_to_gene_name {
    my ($self) = @_;
    my %id_to_gene_name;

    while ( my $raw_feature = $self->_gff_parser->next_feature() ) {
        last unless defined($raw_feature);    # No more features
        next if !( $raw_feature->primary_tag eq 'CDS' );
        my @junk;
        
        my $id_name;
        if($raw_feature->has_tag('ID'))
        {
          ( $id_name, @junk ) = $raw_feature->get_tag_values('ID');
        }
        else
        {
          next;
        }
        

        if ( $raw_feature->has_tag('gene') ) {
            my $gene_name;
            ( $gene_name, @junk ) = $raw_feature->get_tag_values('gene');
            $gene_name =~ s!"!!g;
            next if ( $gene_name eq "" );
            $id_to_gene_name{$id_name} = $gene_name;
        }

        if ( $raw_feature->has_tag('product') ) {
            if ( $raw_feature->has_tag('product') ) {
                my( $product, @junk ) = $raw_feature->get_tag_values('product');
                $self->ids_to_product->{$id_name} = $product;
            }
        }
    }
    $self->_gff_parser->close();
    return \%id_to_gene_name;
}

# Bio::Tools::GFF->ignore_sequence(1) doesnt work with our data, triggers an infinite loop
sub _build__gff_parser {
    my ($self) = @_;
    open( my $fh, '-|', $self->_gff_fh_input_string ) or die "Couldnt open GFF file";
    my $gff_parser = Bio::Tools::GFF->new( -fh => $fh, gff_version => 3 );
    return $gff_parser;
}

sub _gff_fh_input_string {
    my ($self) = @_;
    return $self->_awk_filter . " " . $self->gff_file . " | " . $self->_remove_sequence_filter;
}

sub _build__awk_filter {
    my ($self) = @_;
    return
        'awk \'BEGIN {FS="\t"};{ if ($3 ~/'
      . $self->_tags_to_filter
      . '/) print $0;else if ($3 ~/'
      . $self->_tags_to_ignore
      . '/) ; else print $0;}\' ';
}

# Cut out the FASTA sequence at the bottom of the file
sub _build__remove_sequence_filter {
    my ($self) = @_;
    return 'sed -n \'/##gff-version 3/,/##FASTA/p\' | grep -v \'##FASTA\'';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
