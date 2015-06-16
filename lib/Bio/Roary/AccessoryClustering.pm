package Bio::Roary::AccessoryClustering;

# ABSTRACT: Take an a clusters file from CD-hit and the fasta file and output a fasta file without full clusters

=head1 SYNOPSIS

Take an a clusters file from CD-hit and the fasta file and output a fasta file without full clusters
   use Bio::Roary::FilterFullClusters;
   
   my $obj = Bio::Roary::FilterFullClusters->new(
       clusters_filename        => $cluster_file,
       fasta_file           => $fasta_file,
       number_of_input_files => 10,
       output_file => 'filtered_file'
     );
   $obj->filter_full_clusters_from_fasta();

=cut

use Moose;
use Bio::Roary::External::Cdhit;
use List::MoreUtils qw(uniq);
with 'Bio::Roary::ClustersRole';

has 'input_file'              => ( is => 'ro', isa => 'Str',     required => 1 );
has 'identity'                => ( is => 'ro', isa => 'Num',     default  => 0.95 );
has '_output_cd_hit_filename' => ( is => 'ro', isa => 'Str',     default  => '_accessory_clusters' );
has 'clusters_to_samples'     => ( is => 'ro', isa => 'HashRef', lazy     => 1, builder => '_build_clusters_to_samples' );
has 'samples_to_clusters'     => ( is => 'ro', isa => 'HashRef', lazy     => 1, builder => '_build_samples_to_clusters' );
has 'samples_weight'          => ( is => 'ro', isa => 'HashRef', lazy     => 1, builder => '_build_samples_weight' );
has 'clusters_filename'       => ( is => 'ro', isa => 'Str',     lazy     => 1, builder => '_build_clusters_filename' );
has 'clusters'                => ( is => 'ro', isa => 'HashRef', lazy     => 1, builder => '_build__clusters' );

sub _build_samples_weight {
    my ($self) = @_;
    my %samples_weight;
    for my $cluster_name ( keys %{ $self->clusters_to_samples } ) {
        my $cluster_size = @{ $self->clusters_to_samples->{$cluster_name} };
        for my $sample_name ( @{ $self->clusters_to_samples->{$cluster_name} } ) {
            $samples_weight{$sample_name} = 1 / $cluster_size;
        }
    }
    return \%samples_weight;
}

sub _build_samples_to_clusters {
    my ($self) = @_;
    my %samples_to_clusters;
    for my $cluster_name ( keys %{ $self->clusters_to_samples } ) {
        for my $sample_name ( @{ $self->clusters_to_samples->{$cluster_name} } ) {
            $samples_to_clusters{$sample_name} = $cluster_name;
        }
    }
    return \%samples_to_clusters;
}

sub _build_clusters_filename {
    my ($self) = @_;
    return $self->_output_cd_hit_filename . '.clstr';
}

sub _build_clusters_to_samples {
    my ($self) = @_;

    my $cdhit_obj = Bio::Roary::External::Cdhit->new(
        input_file                   => $self->input_file,
        output_base                  => $self->_output_cd_hit_filename,
        _length_difference_cutoff    => 1,
        _sequence_identity_threshold => $self->identity,
    );
    $cdhit_obj->run();
    my $clusterd_genes = $self->_clustered_genes;

    for my $cluster_name ( keys %{$clusterd_genes} ) {
        my $found = 0;
        for my $gene_name ( @{ $clusterd_genes->{$cluster_name} } ) {
            if ( $gene_name eq $cluster_name ) {
                $found = 1;
                last;
            }
        }

        if ( $found == 0 ) {
            push( @{ $clusterd_genes->{$cluster_name} }, $cluster_name );
        }
    }

    return $clusterd_genes;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

