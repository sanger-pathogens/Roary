package Bio::Roary::Output::NumberOfGroups;

# ABSTRACT: Create raw output files of group counts for turning into plots

=head1 SYNOPSIS

# ABSTRACT: Create raw output files of group counts for turning into plots
use Bio::Roary::Output::NumberOfGroups;

my $obj = Bio::Roary::Output::NumberOfGroups->new(
    group_statistics_obj => $group_stats
  );
$obj->create_files();

=cut

use Moose;
use List::Util qw(shuffle);
use Bio::Roary::AnnotateGroups;
use Bio::Roary::GroupStatistics;

has 'group_statistics_obj' => ( is => 'ro', isa => 'Bio::Roary::GroupStatistics', required => 1 );
has 'number_of_iterations' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build_number_of_iterations' );
has 'groups_to_contigs'    => ( is => 'ro', isa => 'Maybe[HashRef]' );
has 'annotate_groups_obj'  => ( is => 'ro', isa => 'Bio::Roary::AnnotateGroups', required => 1 );

has 'output_raw_filename_conserved_genes' => ( is => 'ro', isa => 'Str', default => 'number_of_conserved_genes.Rtab' );
has 'output_raw_filename_unique_genes'    => ( is => 'ro', isa => 'Str', default => 'number_of_unique_genes.Rtab' );
has 'output_raw_filename_total_genes' => ( is => 'ro', isa => 'Str', default => 'number_of_genes_in_pan_genome.Rtab' );
has 'output_raw_filename_new_genes'   => ( is => 'ro', isa => 'Str', default => 'number_of_new_genes.Rtab' );
has '_conserved_genes' => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has '_unique_genes' => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has '_total_genes'  => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has '_new_genes'    => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

sub _build_number_of_iterations {
    my ($self)               = @_;
    my $number_of_iterations = 100;
    my $number_of_files      = @{ $self->group_statistics_obj->_sorted_file_names };
    if ( $number_of_files > $number_of_iterations ) {
        $number_of_iterations = $number_of_files;
    }
    return $number_of_iterations;
}

sub create_output_files {
    my ($self) = @_;

    for ( my $i = 0 ; $i < $self->number_of_iterations ; $i++ ) {
        $self->_single_iteration_gene_expansion;
    }

    $self->_create_raw_output_file( $self->output_raw_filename_conserved_genes, $self->_conserved_genes );
    $self->_create_raw_output_file( $self->output_raw_filename_unique_genes,    $self->_unique_genes );
    $self->_create_raw_output_file( $self->output_raw_filename_total_genes,     $self->_total_genes );
    $self->_create_raw_output_file( $self->output_raw_filename_new_genes,       $self->_new_genes );
    return 1;
}

sub _create_raw_output_file {
    my ( $self, $filename, $output_data ) = @_;
    open( my $fh, '>', $filename );
    for my $iterations ( @{$output_data} ) {
        print {$fh} join( "\t", @{$iterations} );
        print {$fh} "\n";
    }
    close($fh);
}

sub _shuffle_input_files {
    my ($self) = @_;
    my @shuffled_input_files = shuffle( @{ $self->group_statistics_obj->_sorted_file_names } );
    return \@shuffled_input_files;
}

sub _single_iteration_gene_expansion {
    my ($self) = @_;
    my %existing_groups;
    my @conserved_genes_added_per_file;
    my @unique_genes_added_per_file;
    my @total_genes_added_per_file;
    my @new_genes_added_per_file;

    my $shuffled_input_files = $self->_shuffle_input_files();

    my $files_counter = 1;
    for my $input_file ( @{$shuffled_input_files} ) {
        my $unique_groups_counter    = 0;
        my $total_groups_counter     = 0;
        my $new_group_counter        = 0;
        my $conserved_groups_counter = 0;
        my $new_groups               = $self->group_statistics_obj->_files_to_groups->{$input_file};

        for my $group ( @{$new_groups} ) {
          my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};
          next if(defined($self->groups_to_contigs) && defined($self->groups_to_contigs->{$annotated_group_name}) && defined($self->groups_to_contigs->{$annotated_group_name}->{comment}) && $self->groups_to_contigs->{$annotated_group_name}->{comment} ne '' );
          
            if ( !defined( $existing_groups{$group} ) ) {
                $new_group_counter++;
            }
            $existing_groups{$group}++;
        }

        for my $group ( keys %existing_groups ) {
            if ( $existing_groups{$group} == $files_counter ) {
                $conserved_groups_counter++;
            }

            if ( $existing_groups{$group} == 1 ) {
                $unique_groups_counter++;
            }
            $total_groups_counter++;
        }

        push( @conserved_genes_added_per_file, $conserved_groups_counter );
        push( @unique_genes_added_per_file,    $unique_groups_counter );
        push( @total_genes_added_per_file,     $total_groups_counter );
        push( @new_genes_added_per_file,       $new_group_counter );
        $files_counter++;
    }
    push( @{ $self->_conserved_genes }, \@conserved_genes_added_per_file );
    push( @{ $self->_unique_genes },    \@unique_genes_added_per_file );
    push( @{ $self->_total_genes },     \@total_genes_added_per_file );
    push( @{ $self->_new_genes },       \@new_genes_added_per_file );

    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

