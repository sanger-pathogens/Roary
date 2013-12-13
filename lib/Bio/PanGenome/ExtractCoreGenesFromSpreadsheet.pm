package Bio::PanGenome::ExtractCoreGenesFromSpreadsheet;

# ABSTRACT: Take in a spreadsheet produced by the pipeline and identify the core genes.

=head1 SYNOPSIS

Take in a spreadsheet produced by the pipeline and identify the core genes.
   use Bio::PanGenome::ExtractCoreGenesFromSpreadsheet;
   
   my $obj = Bio::PanGenome::ExtractCoreGenesFromSpreadsheet->new(
       spreadsheet        => 'group_statistics.csv',
     );
   $obj->ordered_core_genes();

=cut

use Moose;
use Text::CSV;
use Bio::PanGenome::GroupStatistics;

has 'spreadsheet'            => ( is => 'ro', isa  => 'Str',      required => 1 );

has '_csv_parser'            => ( is => 'ro', isa  => 'Text::CSV',lazy     => 1, builder => '_build__csv_parser' );
has '_input_spreadsheet_fh'  => ( is => 'ro', lazy => 1,          builder  => '_build__input_spreadsheet_fh' );
has 'ordered_core_genes'     => ( is => 'ro', isa  => 'ArrayRef', lazy     => 1, builder  => '_build_ordered_core_genes' );

has '_number_of_isolates'                 => ( is => 'rw', isa  => 'Int');
has '_gene_column'                        => ( is => 'rw', isa  => 'Int');
has '_num_isolates_column'                => ( is => 'rw', isa  => 'Int');
has '_avg_sequences_per_isolate_column'   => ( is => 'rw', isa  => 'Int');
has '_genome_fragement_column'            => ( is => 'rw', isa  => 'Int');
has '_order_within_fragement_column'      => ( is => 'rw', isa  => 'Int');

sub _build__csv_parser
{
  my ($self) = @_;
  return Text::CSV->new( { binary => 1, always_quote => 1} );
}

sub _build__input_spreadsheet_fh {
    my ($self) = @_;
    open( my $fh, $self->spreadsheet );
    return $fh;
}

sub _update_number_of_isolates
{
  my ($self, $header_row) = @_;
  my $number_of_isolates = @{$header_row} - @{Bio::PanGenome::GroupStatistics->fixed_headers};
  $self->_number_of_isolates($number_of_isolates);
}

sub _setup_column_mappings
{
  my ($self, $header_row) = @_;
  # current ordering
  my %columns_of_interest_mappings = (
    'Gene'                         => 0,
    'No. isolates'                 => 3,
    'Avg sequences per isolate'    => 5,
    'Genome Fragment'              => 6,
    'Order within Fragment'        => 7,
    );
  
  # Dynamically overwrite the default ordering
  for(my $i = 0; $i < @{$header_row}; $i++)
  {
    for my $col_name (%columns_of_interest_mappings)
    {
      if($header_row->[$i] eq $col_name)
      {
        $columns_of_interest_mappings{$col_name} = $i;
        last;
      }
    }
  }
  $self->_gene_column($columns_of_interest_mappings{'Gene'});
  $self->_num_isolates_column($columns_of_interest_mappings{'No. isolates'});
  $self->_avg_sequences_per_isolate_column($columns_of_interest_mappings{'Avg sequences per isolate'});
  $self->_genome_fragement_column($columns_of_interest_mappings{'Genome Fragment'});
  $self->_order_within_fragement_column($columns_of_interest_mappings{'Order within Fragment'});
  $self->_update_number_of_isolates($header_row);
}

sub _ordered_core_genes
{
  my ($self) = @_;
  my %ordered_genes;
  while ( my $row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh ) ) 
  {
    next if(@{$row} < 12);
    next if(!defined($row->[$self->_gene_column]) || $row->[$self->_gene_column] eq '' );
    next if(!defined($row->[$self->_avg_sequences_per_isolate_column]) || $row->[$self->_avg_sequences_per_isolate_column] eq '' );
    next if(!defined($row->[$self->_genome_fragement_column]) || $row->[$self->_genome_fragement_column] eq '' );
    
    next if($self->_number_of_isolates != $row->[$self->_num_isolates_column]);
    next if($row->[$self->_avg_sequences_per_isolate_column] != 1);
    $ordered_genes{$row->[$self->_genome_fragement_column]}{$row->[$self->_order_within_fragement_column]} = $row->[$self->_gene_column];
  }
  
  my @ordered_core_genes ;
  for my $fragment_key(sort {$a <=> $b } keys %ordered_genes)
  {
    for my $order_within_fragement(sort {$a <=> $b } keys %{$ordered_genes{$fragment_key}})
    {
      push(@ordered_core_genes,$ordered_genes{$fragment_key}{$order_within_fragement});
    }
  }
  return \@ordered_core_genes;
}

sub _build_ordered_core_genes
{
  my ($self) = @_;
  my $header_row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh );
  $self->_setup_column_mappings($header_row);

  return $self->_ordered_core_genes();
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
