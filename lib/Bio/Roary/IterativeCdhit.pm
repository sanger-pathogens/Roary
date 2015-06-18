package Bio::Roary::IterativeCdhit;

# ABSTRACT:  Run CDhit iteratively with reducing thresholds, removing full clusters each time

=head1 SYNOPSIS

Run CDhit iteratively with reducing thresholds, removing full clusters each time
   use Bio::Roary::IterativeCdhit;
   
   my $obj = Bio::Roary::IterativeCdhit->new(
     output_cd_hit_filename   => 'output_cd_hit_filename.fa',
     output_combined_filename => 'output_combined_filename.fa',
     number_of_input_files     => 5,
     output_filtered_clustered_fasta= > 'output_filtered_clustered_fasta.fa',
   );
   $obj->run;

=cut

use Moose;
use Bio::SeqIO;
use Bio::Roary::Exceptions;
use Bio::Roary::External::Cdhit;
use Bio::Roary::FilterFullClusters;
use File::Copy;
use Log::Log4perl qw(:easy);
# CD hit is run locally

has 'output_cd_hit_filename'          => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_combined_filename'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'number_of_input_files'           => ( is => 'ro', isa => 'Int', required => 1 );
has 'output_filtered_clustered_fasta' => ( is => 'ro', isa => 'Str', required => 1 );

has 'lower_bound_percentage'          => ( is => 'ro', isa => 'Num', default => 0.98 );
has 'upper_bound_percentage'          => ( is => 'ro', isa => 'Num', default => 0.99 );
has 'step_size_percentage'            => ( is => 'ro', isa => 'Num', default => 0.005 );
has 'cpus'                            => ( is => 'ro', isa => 'Int', default => 1 );
has 'logger'                          => ( is => 'ro', lazy => 1, builder => '_build_logger');

sub _build_logger
{
    my ($self) = @_;
    Log::Log4perl->easy_init(level => $ERROR);
    my $logger = get_logger();
    return $logger;
}


sub run {
    my ($self) = @_;

    $self->filter_complete_clusters(
        $self->output_cd_hit_filename,
        1,
        $self->output_combined_filename,
        $self->number_of_input_files,
        $self->output_filtered_clustered_fasta, 1
    );

    for ( my $percent_match = $self->upper_bound_percentage ; $percent_match >= $self->lower_bound_percentage ; $percent_match -= $self->step_size_percentage ) {
        $self->filter_complete_clusters(
            $self->output_cd_hit_filename,
            $percent_match,
            $self->output_combined_filename,
            $self->number_of_input_files,
            $self->output_filtered_clustered_fasta, 0
        );
    }

    my $cdhit_obj = Bio::Roary::External::Cdhit->new(
        input_file                   => $self->output_combined_filename,
        output_base                  => $self->output_cd_hit_filename,
        _length_difference_cutoff    => $self->lower_bound_percentage,
        _sequence_identity_threshold => $self->lower_bound_percentage,
        cpus                         => $self->cpus,
		logger                       => $self->logger
    );
    $cdhit_obj->run();
    return $cdhit_obj->clusters_filename;
}

sub filter_complete_clusters {
    my ( $self, $output_cd_hit_filename, $percentage_match, $output_combined_filename, $number_of_input_files,
        $output_filtered_clustered_fasta,
        $greater_than_or_equal )
      = @_;
    my $cdhit_obj = Bio::Roary::External::Cdhit->new(
        input_file                   => $output_combined_filename,
        output_base                  => $output_cd_hit_filename,
        _length_difference_cutoff    => $percentage_match,
        _sequence_identity_threshold => $percentage_match,
        cpus                         => $self->cpus,
    );
    $cdhit_obj->run();

    my $filter_clusters = Bio::Roary::FilterFullClusters->new(
        clusters_filename       => $cdhit_obj->clusters_filename,
        fasta_file              => $output_cd_hit_filename,
        number_of_input_files   => $number_of_input_files,
        output_file             => $output_filtered_clustered_fasta,
        _greater_than_or_equal  => $greater_than_or_equal,
        cdhit_input_fasta_file  => $output_combined_filename,
        cdhit_output_fasta_file => $output_combined_filename . '.filtered',
        output_groups_file      => $output_combined_filename . '.groups'
    );

    $filter_clusters->filter_complete_cluster_from_original_fasta();
    move( $filter_clusters->cdhit_output_fasta_file, $output_combined_filename );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
