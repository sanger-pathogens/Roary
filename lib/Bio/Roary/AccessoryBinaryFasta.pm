package Bio::Roary::AccessoryBinaryFasta;

# ABSTRACT: Output a FASTA file which represents the binary presence and absence of genes in the accessory genome

=head1 SYNOPSIS

Output a FASTA file which represents the binary presence and absence of genes in the accessory genome
   use Bio::Roary::AccessoryBinaryFasta;
   my $obj = Bio::Roary::AccessoryBinaryFasta->new(input_files => ['abc','efg'],
		groups_to_files => {'group_1' => ['abc'], group_2 => ['abc', 'efg']}
   );
   $obj->create_accessory_binary_fasta();
=cut

use Moose;
use POSIX;
use Bio::Roary::AnnotateGroups;
use Bio::Roary::AnalyseGroups;
use Bio::Roary::Exceptions;
use Bio::SeqIO;
use File::Basename;

has 'input_files'            => ( is => 'ro', isa => 'ArrayRef',                   required => 1 );
has 'annotate_groups_obj'    => ( is => 'ro', isa => 'Bio::Roary::AnnotateGroups', required => 1 );
has 'analyse_groups_obj'     => ( is => 'ro', isa => 'Bio::Roary::AnalyseGroups',  required => 1 );
has 'output_filename'        => ( is => 'ro', isa => 'Str',                        default  => 'accessory_binary_genes.fa' );
has 'lower_bound_percentage' => ( is => 'ro', isa => 'Int',                        default  => 5 );
has 'upper_bound_percentage' => ( is => 'ro', isa => 'Int',                        default  => 5 );
has 'max_accessory_to_include' => ( is => 'ro', isa => 'Int',                      default  => 4000 );
has 'groups_to_files'        => ( is => 'ro', isa => 'HashRef',                    lazy     => 1, builder => '_build__groups_to_files' );
has '_lower_bound_value'     => ( is => 'ro', isa => 'Int',                        lazy     => 1, builder => '_build__lower_bound_value' );
has '_upper_bound_value'     => ( is => 'ro', isa => 'Int',                        lazy     => 1, builder => '_build__upper_bound_value' );

sub _build__groups_to_files {
    my ($self) = @_;
    my %groups_to_files;
    for my $group ( @{ $self->annotate_groups_obj->_groups } ) {
        my $genes = $self->annotate_groups_obj->_groups_to_id_names->{$group};
        my %filenames;
        for my $gene_name ( @{$genes} ) {
            my $filename = $self->analyse_groups_obj->_genes_to_file->{$gene_name};
            push( @{ $filenames{$filename} }, $gene_name );
        }
        $groups_to_files{$group} = \%filenames;
    }

    return \%groups_to_files;
}

sub _build__lower_bound_value {
    my ($self) = @_;
    my $num_files = @{ $self->input_files };
    return ceil( $num_files * ( $self->lower_bound_percentage / 100 ) );
}

sub _build__upper_bound_value {
    my ($self) = @_;
    my $num_files = @{ $self->input_files };
    return $num_files - ceil( $num_files * ( $self->upper_bound_percentage / 100 ) );
}

sub create_accessory_binary_fasta {
    my ($self) = @_;
    my $out_seq_io = Bio::SeqIO->new( -file => ">" . $self->output_filename, -format => 'Fasta' );

    for my $full_filename ( @{ $self->input_files } ) {
        my($filename, $dirs, $suffix) = fileparse($full_filename);
        
        my $output_sequence = '';
        my $sample_name     = $filename;
        $sample_name =~ s!\.gff\.proteome\.faa!!;

		my $gene_count = 0;
        for my $group ( sort keys %{ $self->groups_to_files } ) {
			last if($gene_count > $self->max_accessory_to_include);

            my @files = keys %{ $self->groups_to_files->{$group} };

            next if ( @files <= $self->_lower_bound_value || @files > $self->_upper_bound_value );

            my $group_to_file_genes = $self->groups_to_files->{$group}->{$full_filename};
            if ( defined($group_to_file_genes) && @{$group_to_file_genes} > 0 ) {
                $output_sequence .= 'A';
            }
            else {
                $output_sequence .= 'C';
            }
			$gene_count++;
			
        }
		next if($output_sequence eq '');
        $out_seq_io->write_seq( Bio::Seq->new( -display_id => $sample_name, -seq => $output_sequence ) );
    }
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
