#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Roary::AccessoryClustering');
}

my $identity_to_num_clusters = {
    '1'    => [ 10, 10 ],
    '0.99' => [ 4,  5 ],
    '0.95' => [ 2,  4 ],
    '0.90' => [ 1,  1 ],
};

for my $percentage_identity ( keys %{$identity_to_num_clusters} ) {
    ok(
        my $obj = Bio::Roary::AccessoryClustering->new(
            input_file => 't/data/input_accessory_binary.fa',
            identity   => $percentage_identity
        ),
        "initialise object with identity of $percentage_identity"
    );
    ok( my @clusters = keys %{ $obj->clusters_to_samples }, "build the clusters for $percentage_identity" );
    ok( $obj->sample_weights,      "build samples weights for $percentage_identity" );
    ok( $obj->samples_to_clusters, "build samples to clusters for $percentage_identity" );

    my $min_cluster_size = $identity_to_num_clusters->{$percentage_identity}->[0];
    my $max_cluster_size = $identity_to_num_clusters->{$percentage_identity}->[1];
    ok(
        ( @clusters >= $min_cluster_size && @clusters <= $max_cluster_size ? 1 : 0 ),
        "check number of clusters as expected, allowing for some variation for $percentage_identity"
    );
}

my $obj = Bio::Roary::AccessoryClustering->new(
    input_file => 't/data/input_accessory_binary.fa',
    identity   => 0.9
);
is_deeply(
    $obj->samples_to_clusters,
    {
        'seq6'  => 'seq1',
        'seq3'  => 'seq1',
        'seq7'  => 'seq1',
        'seq9'  => 'seq1',
        'seq10' => 'seq1',
        'seq2'  => 'seq1',
        'seq8'  => 'seq1',
        'seq1'  => 'seq1',
        'seq4'  => 'seq1',
        'seq5'  => 'seq1'
    },
    'samples to clusters'
);
my @sample_weights = values %{ $obj->sample_weights };
is_deeply( \@sample_weights, [ 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 ], 'sample weights' );

$obj = Bio::Roary::AccessoryClustering->new(
    input_file => 't/data/input_accessory_binary.fa',
    identity   => 1
);

is_deeply(
    $obj->samples_to_clusters,
    {
        'seq6'  => 'seq6',
        'seq3'  => 'seq3',
        'seq7'  => 'seq7',
        'seq9'  => 'seq9',
        'seq10' => 'seq10',
        'seq2'  => 'seq2',
        'seq8'  => 'seq8',
        'seq1'  => 'seq1',
        'seq4'  => 'seq4',
        'seq5'  => 'seq5'
    },
    'samples to clusters'
);
@sample_weights = values %{ $obj->sample_weights };
is_deeply( \@sample_weights, [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ], 'sample weights' );



$obj = Bio::Roary::AccessoryClustering->new(
    input_file => 't/data/large_accessory_binary_genes.fa'
);

ok( my @clusters = keys %{ $obj->clusters_to_samples }, "build the clusters for large_accessory_binary_genes.fa" );
ok( $obj->sample_weights,      "build samples weights for large_accessory_binary_genes.fa" );
ok( $obj->samples_to_clusters, "build samples to clusters for large_accessory_binary_genes.fa" );

ok(
    ( @clusters >= 6 && @clusters <= 14 ? 1 : 0 ),
    "check number of clusters as expected, allowing for some variation for large_accessory_binary_genes.fa"
);

unlink('_accessory_clusters');
unlink('_accessory_clusters.clstr');
done_testing();
