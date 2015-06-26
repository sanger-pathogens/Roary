package Bio::Roary::AssemblyStatistics;

# ABSTRACT: Given a spreadsheet of gene presence and absense calculate some statistics

=head1 SYNOPSIS

Given a spreadsheet of gene presence and absense calculate some statistics

=cut

use Moose;
use Bio::Roary::ExtractCoreGenesFromSpreadsheet;
with 'Bio::Roary::SpreadsheetRole';

has 'output_filename'  => ( is => 'ro', isa => 'Str',  default  => 'assembly_statistics.csv' );
has 'job_runner'       => ( is => 'ro', isa => 'Str',  default  => 'Local' );
has 'cpus'             => ( is => 'ro', isa => 'Int',  default  => 1 );
has 'core_definition'  => ( is => 'ro', isa => 'Num',  default  => 0.99 );
has 'verbose'          => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'contigous_window' => ( is => 'ro', isa => 'Int',  default  => 10 );

has 'ordered_genes'         => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_ordered_genes' );
has '_genes_to_rows'        => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build__genes_to_rows' );
has 'all_sample_statistics' => ( is => 'ro', isa => 'HashRef',  lazy => 1, builder => '_build__all_sample_statistics' );

has 'sample_names_to_column_index' => ( is => 'rw', isa => 'Maybe[HashRef]' );

sub _build_ordered_genes {
    my ($self) = @_;
    return Bio::Roary::ExtractCoreGenesFromSpreadsheet->new( spreadsheet => $self->spreadsheet, core_definition => $self->core_definition )->ordered_core_genes();
}

sub _build__genes_to_rows {
    my ($self) = @_;

    my %genes_to_rows;
	seek($self->_input_spreadsheet_fh  ,0,0);
    my $header_row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh );
    $self->_populate_sample_names_to_column_index($header_row  );

    while ( my $row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh ) ) {
        $genes_to_rows{ $row->[0] } = $row;
    }

    return \%genes_to_rows;
}

sub _populate_sample_names_to_column_index {
    my ( $self, $row ) = @_;

    my %samples_to_index;
    for ( my $i = $self->_num_fixed_headers ; $i < @{$row} ; $i++ ) {
        next if ( ( !defined( $row->[$i] ) ) || $row->[$i] eq "" );
        $samples_to_index{ $row->[$i] } = $i;
    }
    $self->sample_names_to_column_index( \%samples_to_index );
}

sub _build__all_sample_statistics {
    my ($self) = @_;

	my %sample_stats;
    # For each sample - loop over genes in order - number of contiguous blocks - max size of contigous block - n50 - incorrect joins
	for my $sample_name (sort keys %{$self->sample_names_to_column_index})
	{
		$sample_stats{$sample_name} = $self->_sample_statistics($sample_name);		
	}
	return \%sample_stats;
}

sub _sample_statistics {
    my ( $self, $sample_name ) = @_;

    my $sample_column_index = $self->sample_names_to_column_index->{$sample_name};
    my @gene_ids;
    for my $gene_name ( @{ $self->ordered_genes } ) {
        my $sample_gene_id = $self->_genes_to_rows->{$gene_name}->[$sample_column_index];
        next unless ( defined($sample_gene_id) );

        if ( $sample_gene_id =~ /_([\d]+)$/ ) {
            my $gene_number = $1;
            push( @gene_ids, $gene_number );
        }
        else {
            next;
        }
    }
		
	return $self->_number_of_contiguous_blocks(\@gene_ids) ;
}

sub _number_of_contiguous_blocks {
    my ( $self, $gene_ids ) = @_;

    my $current_gene_id  = $gene_ids->[0];
    my $number_of_blocks = 1;
	my $largest_block_size = 0;
	my $block_size = 0;
    for my $gene_id ( @{$gene_ids} ) {
		$block_size++;
        if ( !( ( $current_gene_id + $self->contigous_window >= $gene_id ) && ( $current_gene_id - $self->contigous_window <= $gene_id ) ) )
        {
			if($block_size >= $largest_block_size)
			{
				$largest_block_size = $block_size;
				$block_size = 0;
			}
			$number_of_blocks++;
        }
		$current_gene_id  = $gene_id;
    }
	
	if($block_size > $largest_block_size)
	{
		$largest_block_size = $block_size;
		$block_size = 0;
	}
	return { num_blocks => $number_of_blocks, largest_block_size => $largest_block_size};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

