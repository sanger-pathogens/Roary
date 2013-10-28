package Bio::PanGenome::Plot::NumberNewGroups;

# ABSTRACT: Take in a matrix of gene count expansion

=head1 SYNOPSIS

Take in a matrix of gene count expansion
   use Bio::PanGenome::Plot::NumberNewGroups;
   
   my $plot_obj = Bio::PanGenome::Plot::NumberNewGroups->new(
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

has 'output_filename' => ( is => 'ro', isa => 'Str',      default  => 'gene_count.png' );
has 'input_keys'      => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'input_highs'     => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'input_lows'      => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'input_opens'     => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'input_values'    => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has '_plot_height'    => ( is => 'ro', isa => 'Int',      default  => 800 );
has '_plot_width'     => ( is => 'ro', isa => 'Int',      default  => 1000 );
has '_plot_title'     => ( is => 'ro', isa => 'Str',      default  => 'Number of new genes as more samples added' );

sub create_plot {

    my ($self) = @_;
    my $cc = Chart::Clicker->new( width => $self->_plot_width, height => $self->_plot_height );

    my $series1 = Chart::Clicker::Data::Series::HighLow->new(
        {
            keys   => $self->input_values,
            highs  => $self->input_highs,
            lows   => $self->input_lows,
            opens  => $self->input_opens,
            values => $self->input_values,
        }
    );

    $cc->title->text( $self->_plot_title );
    $cc->title->padding->bottom(5);

    my $ds = Chart::Clicker::Data::DataSet->new( series => [$series1] );
    $cc->add_to_datasets($ds);

    my $def = $cc->get_context('default');
    $def->range_axis->baseline(0);
    $def->range_axis->label('Genes');
    $def->range_axis->fudge_amount(.2);
    $def->domain_axis->label('Number of samples');
    $def->domain_axis->fudge_amount(.06);

    #$def->domain_axis->tick_values($self->gene_pool_expansion->key_values);

    $def->renderer( Chart::Clicker::Renderer::CandleStick->new( bar_padding => 10 ) );

    $cc->write_output( $self->output_filename );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

