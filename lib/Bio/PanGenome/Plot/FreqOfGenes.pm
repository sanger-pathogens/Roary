package Bio::PanGenome::Plot::FreqOfGenes;

# ABSTRACT: Take in an array of frequencies of groups and output a plot

=head1 SYNOPSIS

Take in an array of frequencies of groups and output a plot
   use Bio::PanGenome::Plot::FreqOfGenes;
   
   my $plot_groups_obj = Bio::PanGenome::Plot::FreqOfGenes->new(
       freq_groups_per_genome      => $freq_groups_per_genome,
       output_filename  => $output_filename
     );
   $plot_groups_obj->create_plot();

=cut

use Moose;

use Chart::Clicker;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Renderer::Bar;
use Geometry::Primitive::Rectangle;
use Graphics::Color::RGB;

has 'output_filename'        => ( is => 'ro', isa => 'Str',      default  => 'freq_of_genes.png' );
has 'freq_groups_per_genome' => ( is => 'ro', isa => 'ArrayRef', required => 1 );

has '_plot_height' => ( is => 'ro', isa => 'Int', default => 800 );
has '_plot_width'  => ( is => 'ro', isa => 'Int', default => 1000 );
has '_plot_title'  => ( is => 'ro', isa => 'Str', default => '% of genomes containing genes ordered by percentage' );

sub create_plot {

    my ($self) = @_;
    my $cc = Chart::Clicker->new( width => $self->_plot_width, height => $self->_plot_height );

    my @group_numbers;
    my @group_values;
    my $count = 0;
    for my $group ( @{ $self->freq_groups_per_genome } ) {
        $count++;
        push( @group_numbers, "$count" );
        push( @group_values,  "$group" );
    }

    my $series1 = Chart::Clicker::Data::Series->new(
        keys   => \@group_numbers,
        values => \@group_values,
    );

    $cc->title->text( $self->_plot_title );
    $cc->title->padding->bottom(5);

    my $ds = Chart::Clicker::Data::DataSet->new( series => [$series1] );
    $cc->add_to_datasets($ds);

    my $def = $cc->get_context('default');
    my $area = Chart::Clicker::Renderer::Bar->new( opacity => .6 );
    $area->brush->width(3);
    $def->renderer($area);
    $def->range_axis->format('%d');
    $def->range_axis->baseline(0);
    $def->range_axis->label('%');
    $def->domain_axis->format('%d');
    $def->domain_axis->fudge_amount(.3);
    $def->domain_axis->label('Number of genes');
    $def->range_axis->fudge_amount(.1);

    $cc->write_output( $self->output_filename );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

