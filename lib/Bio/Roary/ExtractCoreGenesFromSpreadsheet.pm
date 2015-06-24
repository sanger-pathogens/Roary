package Bio::Roary::ExtractCoreGenesFromSpreadsheet;

# ABSTRACT: Take in a spreadsheet produced by the pipeline and identify the core genes.

=head1 SYNOPSIS

Take in a spreadsheet produced by the pipeline and identify the core genes.
   use Bio::Roary::ExtractCoreGenesFromSpreadsheet;
   
   my $obj = Bio::Roary::ExtractCoreGenesFromSpreadsheet->new(
       spreadsheet        => 'group_statistics.csv',
     );
   $obj->ordered_core_genes();

=cut

use Moose;
use Text::CSV;
use Bio::Roary::GroupStatistics;
use POSIX;

has 'spreadsheet'            => ( is => 'ro', isa  => 'Str',      required => 1 );
has '_csv_parser'            => ( is => 'ro', isa  => 'Text::CSV',lazy     => 1, builder => '_build__csv_parser' );
has '_input_spreadsheet_fh'  => ( is => 'ro', lazy => 1,          builder  => '_build__input_spreadsheet_fh' );
has 'ordered_core_genes'     => ( is => 'ro', isa  => 'ArrayRef', lazy     => 1, builder  => '_build_ordered_core_genes' );
has 'core_definition'        => ( is => 'ro', isa => 'Num', default => 1 );
has 'sample_names'           => ( is => 'rw', isa => 'ArrayRef', default => sub {[]} );
has 'sample_names_to_genes'  => ( is => 'rw', isa => 'HashRef',  default => sub {{}} );

has '_number_of_isolates'                 => ( is => 'rw', isa  => 'Int');
has '_gene_column'                        => ( is => 'rw', isa  => 'Int');
has '_num_isolates_column'                => ( is => 'rw', isa  => 'Int');
has '_avg_sequences_per_isolate_column'   => ( is => 'rw', isa  => 'Int');
has '_genome_fragement_column'            => ( is => 'rw', isa  => 'Int');
has '_order_within_fragement_column'      => ( is => 'rw', isa  => 'Int');
has '_min_no_isolates_for_core'           => ( is => 'rw', isa  => 'Num', lazy => 1, builder => '_build__min_no_isolates_for_core' );

sub _build__min_no_isolates_for_core {
  my ($self) = @_;
  my $threshold =  $self->_number_of_isolates * $self->core_definition;

  return $threshold;
}

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
  my $number_of_isolates = @{$header_row} - @{Bio::Roary::GroupStatistics->fixed_headers};
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
	'QC'                           => 10,
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
  
  # Get the sample_names
  my @sample_names;
  for(my $i = $self->_length_of_fixed_headers(); $i < @{$header_row}; $i++)
  {
	  push(@sample_names,$header_row->[$i]);
  }
  $self->sample_names(\@sample_names);
}

sub _length_of_fixed_headers
{
	my ($self) = @_;
    return @{Bio::Roary::GroupStatistics->fixed_headers()};
}

sub _populate_sample_to_gene_lookup_with_row
{
	 my ($self, $row) = @_;
	 
	 for(my $i = $self->_length_of_fixed_headers(); $i < @{$row}; $i++ )
	 {
		 if(defined($row->[$i]) && $row->[$i] ne "" )
		 {
		 	my $sample_name = $self->sample_names->[$i - $self->_length_of_fixed_headers()];
			
			$self->sample_names_to_genes->{$sample_name}->{$row->[$i]} = 1;
		 }
	 }
	 return 1;
}


sub _ordered_core_genes
{
  my ($self) = @_;
  my %ordered_genes;
  while ( my $row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh ) ) 
  {
    next if(@{$row} < 12); # no genes in group
    next if(!defined($row->[$self->_gene_column]) || $row->[$self->_gene_column] eq '' ); # no gene name
    next if(!defined($row->[$self->_avg_sequences_per_isolate_column]) || $row->[$self->_avg_sequences_per_isolate_column] eq '' ); # no average
    next if(!defined($row->[$self->_genome_fragement_column]) || $row->[$self->_genome_fragement_column] eq '' ); # fragment not defined
    
    # next if($self->_number_of_isolates != $row->[$self->_num_isolates_column]); # if gene is not in all isolates
    next if ( $row->[$self->_num_isolates_column] < $self->_min_no_isolates_for_core );
    next if($row->[$self->_avg_sequences_per_isolate_column] != 1);
    $ordered_genes{$row->[$self->_genome_fragement_column]}{$row->[$self->_order_within_fragement_column]} = $row->[$self->_gene_column];
	$self->_populate_sample_to_gene_lookup_with_row($row);
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
