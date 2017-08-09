package Bio::Roary::UniqueGenesPerSample;

# ABSTRACT:  Take in the clustered file and produce a sorted file with the frequency of each samples unique genes

=head1 SYNOPSIS

Take in the clustered file and produce a sorted file with the frequency of each samples unique genes
   use Bio::Roary::UniqueGenesPerSample;
   
   my $obj = Bio::Roary::SequenceLengths->new(
     clustered_proteins   => 'clustered_proteins',
     output_filename   => 'output_filename',
   );
   $obj->write_unique_frequency;

=cut

use Moose;
use Bio::Roary::Exceptions;

has 'clustered_proteins' => ( is => 'rw', isa => 'Str', default => 'clustered_proteins' );
has 'output_filename'    => ( is => 'rw', isa => 'Str', default => 'unique_genes_per_sample.tsv' );

has '_output_fh' => ( is => 'ro', lazy => 1, builder => '_build__output_fh' );

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::Roary::Exceptions::CouldntWriteToFile->throw( error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

#group_17585: 14520_6#21_00645
sub _sample_to_gene_freq {
    my ($self) = @_;

    open( my $input_fh, $self->clustered_proteins )
      or Bio::Roary::Exceptions::FileNotFound->throw( error => "Couldnt read input file:" . $self->clustered_proteins );

    my %sample_to_gene_freq;
    while (<$input_fh>) {
        chomp;
        my $line = $_;
        next if ( length( $line ) < 6 );
        if ( $line =~ /^.+: ([^\s]+)$/ ) {
            my $gene_id = $1;
            if ( $gene_id =~ /^(.+)_[\d]+$/ ) {
                my $sample_name = $1;
                $sample_to_gene_freq{$sample_name}++;
            }
            else {
                # gene id may not be valid so ignore
                next;
            }
        }
        else {
            # its either an invalid line or theres more than 1 gene in the cluster
            next;
        }
    }

    return \%sample_to_gene_freq;
}

sub write_unique_frequency {
    my ($self) = @_;

    my %sample_to_gene_freq = %{$self->_sample_to_gene_freq};
	
    for my $sample ( sort { $sample_to_gene_freq{$b} <=> $sample_to_gene_freq{$a}  || $a cmp $b } keys %sample_to_gene_freq ) {
        print { $self->_output_fh } $sample . "\t" . $sample_to_gene_freq{$sample} . "\n";
    }
	close($self->_output_fh);
	return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
