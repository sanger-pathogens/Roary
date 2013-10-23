package Bio::PanGenome::ReorderSpreadsheet;

# ABSTRACT: Take in a tree file and a spreadsheet and output a spreadsheet with reordered columns

=head1 SYNOPSIS

Take in a tree file and a spreadsheet and output a spreadsheet with reordered columns
   use Bio::PanGenome::ReorderSpreadsheet;
   
   my $obj = Bio::PanGenome::ReorderSpreadsheet->new(
       tree_file        => $tree_file,
       spreadsheet   => 'groups.csv'
     );
   $obj->reorder_spreadsheet();

=cut

use Moose;
use Text::CSV;
use Bio::PanGenome::SampleOrder;
use Bio::PanGenome::GroupStatistics;

has 'tree_file'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'spreadsheet' => ( is => 'ro', isa => 'Str', required => 1 );
has 'tree_format' => ( is => 'ro', isa => 'Str', default  => 'newick' );
has 'output_filename'        => ( is => 'ro', isa  => 'Str',      default => 'reordered_groups_stats.csv' );

has '_sample_order'          => ( is => 'ro', isa  => 'ArrayRef', lazy    => 1, builder => '_build__sample_order' );
has '_input_spreadsheet_fh'  => ( is => 'ro', lazy => 1,          builder => '_build__input_spreadsheet_fh' );
has '_output_spreadsheet_fh' => ( is => 'ro', lazy => 1,          builder => '_build__output_spreadsheet_fh' );
has '_column_mappings'       => ( is => 'ro', isa  => 'ArrayRef', lazy    => 1, builder => '_build__column_mappings' );
has '_fixed_headers'         => ( is => 'ro', isa  => 'ArrayRef', lazy    => 1, builder => '_build__fixed_headers' );
has '_num_fixed_headers'     => ( is => 'ro', isa  => 'Int',      lazy    => 1, builder => '_build__num_fixed_headers' );
has '_csv_parser'            => ( is => 'ro', isa  => 'Text::CSV',lazy    => 1, builder => '_build__csv_parser' );
has '_csv_output'            => ( is => 'ro', isa  => 'Text::CSV',lazy    => 1, builder => '_build__csv_output' );

sub BUILD {
  my ($self) = @_;
  # read the headers first
  $self->_column_mappings;
}


sub reorder_spreadsheet {
    my ($self) = @_;

    # make sure the file handle is at the start
    seek($self->_input_spreadsheet_fh  ,0,0);
    while ( my $row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh ) ) 
    {
      $self->_csv_output->print($self->_output_spreadsheet_fh, $self->_remap_columns($row));
    }
    
    close($self->_output_spreadsheet_fh);
    close($self->_input_spreadsheet_fh);
    return 1;
}

sub _remap_columns
{
  my ($self, $row) = @_;
  
  my @output_row;
  for(my $output_index = 0; $output_index < @{$self->_column_mappings}; $output_index++)
  {
    my $input_index = $self->_column_mappings->[$output_index];
    push(@output_row, $row->[$input_index]);
  }
  return \@output_row;
}

sub _column_mappings_populate_fixed_headers
{
  my ($self, $column_mappings,$header_row) = @_;
  my $column_counter = 0;
  for($column_counter = 0; $column_counter < $self->_num_fixed_headers; $column_counter++)
  {
    push(@{$column_mappings}, $column_counter);
    shift(@{$header_row});
  }
  return $column_counter;
}

sub _build__column_mappings
{
  my ($self) = @_;
  my $header_row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh );
  
  my @column_mappings;
  my $column_counter = $self->_column_mappings_populate_fixed_headers(\@column_mappings, $header_row);

  # put the input column names into an array where the key is the name and the value is the order
  my %input_sample_order;
  for(my $i = 0; $i < @{$header_row}; $i++)
  {
    $input_sample_order{$header_row->[$i]} = $i + $column_counter;
  }
  
  # Go through the order of the samples from the tree and see if the headers exist
  for my $sample_name (@{$self->_sample_order})
  {
    if(defined($input_sample_order{$sample_name}))
    {
      push(@column_mappings, $input_sample_order{$sample_name});
      delete($input_sample_order{$sample_name});
    }
    $column_counter++;
  }
  
  # Add any columns not in the tree to the end
  for my $sample_name  (keys %input_sample_order)
  {
    push(@column_mappings, $input_sample_order{$sample_name});
    delete($input_sample_order{$sample_name});
    $column_counter++;
  }
  return \@column_mappings;
}

sub _build__num_fixed_headers
{
  my ($self) = @_;
  return @{$self->_fixed_headers};
}

sub _build__fixed_headers
{
  my ($self) = @_;
  my @fixed_headers = @{Bio::PanGenome::GroupStatistics->fixed_headers()};
  return \@fixed_headers;
}

sub _build__csv_parser
{
  my ($self) = @_;
  return Text::CSV->new( { binary => 1, always_quote => 1} );
}

sub _build__csv_output
{
  my ($self) = @_;
  return Text::CSV->new( { binary => 1, always_quote => 1, eol => "\r\n"} );
}

sub _build__input_spreadsheet_fh {
    my ($self) = @_;
    open( my $fh, $self->spreadsheet );
    return $fh;
}

sub _build__output_spreadsheet_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename );
    return $fh;
}

sub _build__sample_order {
    my ($self) = @_;
    my $obj = Bio::PanGenome::SampleOrder->new(
        tree_file   => $self->tree_file,
        tree_format => $self->tree_format
    );
    return $obj->ordered_samples();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

