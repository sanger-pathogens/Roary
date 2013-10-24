package Bio::PanGenome::Plot::GenePoolExpansionPlot;

# ABSTRACT: Take in a matrix of gene count expansion

=head1 SYNOPSIS

Take in a matrix of gene count expansion
   use Bio::PanGenome::Plot::GenePoolExpansionPlot;
   
   my $plot_obj = Bio::PanGenome::Plot::GenePoolExpansionPlot->new(
       gene_pool_expansion      => [[]],
       output_filename      => $output_filename
     );
   $plot_obj->create_plot();

=cut

use Moose;

use Chart::Clicker;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Renderer::Bar;
use Chart::Clicker::Renderer::CandleStick;
use Geometry::Primitive::Rectangle;
use Chart::Clicker::Data::Series::HighLow;
use Graphics::Color::RGB;

has 'output_filename'        => ( is => 'ro', isa => 'Str',      default  => 'gene_count.png' );
has 'gene_pool_expansion' => ( is => 'ro', isa => 'Bio::PanGenome::GenePoolExpansion', required => 1 );

has '_plot_height' => ( is => 'ro', isa => 'Int', default => 800 );
has '_plot_width'  => ( is => 'ro', isa => 'Int', default => 1000 );
has '_plot_title'  => ( is => 'ro', isa => 'Str', default => 'Number of new genes as more samples added' );

sub create_plot {

    my ($self) = @_;
    my $cc = Chart::Clicker->new( width => $self->_plot_width, height => $self->_plot_height );

    my $series1 = Chart::Clicker::Data::Series::HighLow->new(
        keys    => [@{$self->gene_pool_expansion->key_values }],
        highs   => [@{$self->gene_pool_expansion->high_values}],
        lows    => [@{$self->gene_pool_expansion->low_values }],
        opens   => [@{$self->gene_pool_expansion->mean_values}],
        values  => [@{$self->gene_pool_expansion->mean_values}]
        
    );

    $cc->title->text( $self->_plot_title );
    $cc->title->padding->bottom(5);

    my $ds = Chart::Clicker::Data::DataSet->new( series => [$series1] );
    $cc->add_to_datasets($ds);

    my $def = $cc->get_context('default');
    $def->range_axis->format('%d');
    $def->range_axis->baseline(0);
    $def->range_axis->label('Number of genes added');
    $def->range_axis->fudge_amount(.2);
    $def->domain_axis->format('%d');
    $def->domain_axis->label('Number of samples');
    $def->domain_axis->fudge_amount(.06);
    
    $def->renderer(Chart::Clicker::Renderer::CandleStick->new(bar_padding => 30));

    $cc->write_output( $self->output_filename );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

