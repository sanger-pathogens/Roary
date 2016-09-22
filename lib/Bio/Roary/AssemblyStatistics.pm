package Bio::Roary::AssemblyStatistics;

# ABSTRACT: Given a spreadsheet of gene presence and absence calculate some statistics

=head1 SYNOPSIS

Given a spreadsheet of gene presence and absence calculate some statistics

=cut

use Moose;
use Bio::Roary::ExtractCoreGenesFromSpreadsheet;
use Log::Log4perl qw(:easy);
with 'Bio::Roary::SpreadsheetRole';

has 'output_filename'       => ( is => 'ro', isa => 'Str',      default => 'assembly_statistics.csv' );
has 'job_runner'            => ( is => 'ro', isa => 'Str',      default => 'Local' );
has 'cpus'                  => ( is => 'ro', isa => 'Int',      default => 1 );
has 'core_definition'       => ( is => 'rw', isa => 'Num',      default => 0.99 );
has '_cloud_percentage'     => ( is => 'rw', isa => 'Num',      default => 0.15 );
has '_shell_percentage'     => ( is => 'rw', isa => 'Num',      default => 0.95 );
has '_soft_core_percentage' => ( is => 'rw', isa => 'Num',      default => 0.99 );
has 'verbose'               => ( is => 'ro', isa => 'Bool',     default => 0 );
has 'contiguous_window'     => ( is => 'ro', isa => 'Int',      default => 10 );
has 'ordered_genes'         => ( is => 'ro', isa => 'ArrayRef', lazy    => 1, builder => '_build_ordered_genes' );
has '_genes_to_rows'        => ( is => 'ro', isa => 'HashRef',  lazy    => 1, builder => '_build__genes_to_rows' );
has 'all_sample_statistics' => ( is => 'ro', isa => 'HashRef',  lazy    => 1, builder => '_build_all_sample_statistics' );
has 'sample_names_to_column_index' => ( is => 'rw', isa => 'Maybe[HashRef]' );
has 'summary_output_filename'=> ( is => 'ro', isa => 'Str',      default => 'summary_statistics.txt' );
has 'logger'                 => ( is => 'ro', lazy => 1, builder => '_build_logger');
has 'gene_category_count'   => ( is => 'ro', isa => 'HashRef',  lazy    => 1, builder => '_build_gene_category_count' );

sub BUILD {
    my ($self) = @_;
    $self->_genes_to_rows;
	$self->gene_category_count;
}

sub _build_logger
{
    my ($self) = @_;
    Log::Log4perl->easy_init( $ERROR );
    my $logger = get_logger();
    return $logger;
}

sub create_summary_output
{
	my ($self) = @_;
	open(my $fh, '>', $self->summary_output_filename) or Bio::Roary::Exceptions::CouldntWriteToFile->throw(error => "Couldnt write to ".$self->summary_output_filename);

    my $core_percentage      = $self->core_definition()*100;
	my $soft_core_percentage = $self->_soft_core_percentage*100;
	my $shell_percentage     = $self->_shell_percentage()*100;
	my $cloud_percentage     = $self->_cloud_percentage()*100;
	
	my $core_genes      = ($self->gene_category_count->{core} ? $self->gene_category_count->{core} : 0);
	my $soft_core_genes = ($self->gene_category_count->{soft_core} ? $self->gene_category_count->{soft_core} : 0);
	my $shell_genes     =($self->gene_category_count->{shell} ? $self->gene_category_count->{shell} : 0);
	my $cloud_genes     = ($self->gene_category_count->{cloud} ? $self->gene_category_count->{cloud} : 0);
	my $total_genes = $core_genes  + $soft_core_genes  + $shell_genes + $cloud_genes  ;
	
	$self->logger->warn("Very few core genes detected with the current settings. Try modifying the core definition ( -cd 90 ) and/or 
	the blast identity (-i 70) parameters.  Also try checking for contamination (-qc) and ensure you only have one species.") if($core_genes < 100);
	
	print {$fh} "Core genes\t($core_percentage".'% <= strains <= 100%)'."\t$core_genes\n";
	print {$fh} "Soft core genes\t(".$shell_percentage."% <= strains < ".$soft_core_percentage."%)\t$soft_core_genes\n";
	print {$fh} "Shell genes\t(".$cloud_percentage."% <= strains < ".$shell_percentage."%)\t$shell_genes\n";
	print {$fh} "Cloud genes\t(0% <= strains < ".$cloud_percentage."%)\t$cloud_genes\n";
	print {$fh} "Total genes\t(0% <= strains <= 100%)\t$total_genes\n";
	
	close($fh);
	return 1;
}

sub _build_gene_category_count {
    my ($self) = @_;
    my %gene_category_count;
	$self->_soft_core_percentage($self->core_definition);
	
    if ( $self->_soft_core_percentage <= $self->_shell_percentage ) {
        $self->_shell_percentage( $self->_soft_core_percentage - 0.01 );
    }

    my $number_of_samples = keys %{ $self->sample_names_to_column_index };
    for my $gene_name ( keys %{ $self->_genes_to_rows } ) {
        my $isolates_with_gene = 0;

        for ( my $i = $self->_num_fixed_headers ; $i < @{ $self->_genes_to_rows->{$gene_name} } ; $i++ ) {
            $isolates_with_gene++
              if ( defined( $self->_genes_to_rows->{$gene_name}->[$i] ) && $self->_genes_to_rows->{$gene_name}->[$i] ne "" );
        }

        if ( $isolates_with_gene < $self->_cloud_percentage() * $number_of_samples ) {
            $gene_category_count{cloud}++;
        }
        elsif ( $isolates_with_gene < $self->_shell_percentage() * $number_of_samples ) {
            $gene_category_count{shell}++;
        }
        elsif ( $isolates_with_gene < $self->_soft_core_percentage() * $number_of_samples ) {
            $gene_category_count{soft_core}++;
        }
        else {
            $gene_category_count{core}++;
        }
    }
    return \%gene_category_count;
}

sub _build_ordered_genes {
    my ($self) = @_;
    return Bio::Roary::ExtractCoreGenesFromSpreadsheet->new( spreadsheet => $self->spreadsheet, core_definition => $self->core_definition )
      ->ordered_core_genes();
}

sub _build__genes_to_rows {
    my ($self) = @_;

    my %genes_to_rows;
    seek( $self->_input_spreadsheet_fh, 0, 0 );
    my $header_row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh );
    $self->_populate_sample_names_to_column_index($header_row);

    while ( my $row = $self->_csv_parser->getline( $self->_input_spreadsheet_fh ) ) {
        next if ( !defined( $row->[0] ) || $row->[0] eq "" );
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

sub _build_all_sample_statistics {
    my ($self) = @_;

    my %sample_stats;

    # For each sample - loop over genes in order - number of contiguous blocks - max size of contiguous block - n50 - incorrect joins
    for my $sample_name ( sort keys %{ $self->sample_names_to_column_index } ) {
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

    return $self->_number_of_contiguous_blocks( \@gene_ids );
}

sub _number_of_contiguous_blocks {
    my ( $self, $gene_ids ) = @_;

    my $current_gene_id    = $gene_ids->[0];
    my $number_of_blocks   = 1;
    my $largest_block_size = 0;
    my $block_size         = 0;
    for my $gene_id ( @{$gene_ids} ) {
        if ( !( ( $current_gene_id + $self->contiguous_window >= $gene_id ) && ( $current_gene_id - $self->contiguous_window <= $gene_id ) )
          )
        {
            if ( $block_size >= $largest_block_size ) {
                $largest_block_size = $block_size;
                $block_size         = 0;
            }
            $number_of_blocks++;
        }
        $current_gene_id = $gene_id;
        $block_size++;
    }

    if ( $block_size > $largest_block_size ) {
        $largest_block_size = $block_size;
    }
    return { num_blocks => $number_of_blocks, largest_block_size => $largest_block_size };
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

