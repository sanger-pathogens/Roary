package Bio::Roary::Output::EmblGroups;

# ABSTRACT: Create a tab/embl file with the features for drawing pretty pictures

=head1 SYNOPSIS

reate a tab/embl file with the features for drawing pretty pictures
   use Bio::Roary::Output::EmblGroups;
   
   my $obj = Bio::Roary::Output::EmblGroups->new(
     output_filename => 'group_statitics.csv',
     annotate_groups_obj => $annotate_groups_obj,
     analyse_groups_obj  => $analyse_groups_obj
   );
   $obj->create_file;

=cut

use Moose;
use POSIX;
use File::Basename;
use Bio::Roary::Exceptions;
use Bio::Roary::AnalyseGroups;
use Bio::Roary::AnnotateGroups;
with 'Bio::Roary::Output::EMBLHeaderCommon';

has 'annotate_groups_obj' => ( is => 'ro', isa => 'Bio::Roary::AnnotateGroups', required => 1 );
has 'analyse_groups_obj'  => ( is => 'ro', isa => 'Bio::Roary::AnalyseGroups',  required => 1 );
has 'output_filename'     => ( is => 'ro', isa => 'Str',                        default  => 'core_accessory.tab' );
has 'output_header_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_header_filename' );
has 'groups_to_contigs' => ( is => 'ro', isa => 'Maybe[HashRef]' );
has 'ordering_key' => ( is => 'ro', isa => 'Str', default => 'core_accessory_overall_order' );

has '_output_fh'           => ( is => 'ro', lazy => 1,          builder => '_build__output_fh' );
has '_output_header_fh'    => ( is => 'ro', lazy => 1,          builder => '_build__output_header_fh' );
has '_sorted_file_names'   => ( is => 'ro', isa  => 'ArrayRef', lazy    => 1, builder => '_build__sorted_file_names' );
has '_groups_to_files'     => ( is => 'ro', isa  => 'HashRef',  lazy    => 1, builder => '_build__groups_to_files' );
has 'heatmap_lookup_table' => ( is => 'ro', isa  => 'ArrayRef', lazy    => 1, builder => '_build_heatmap_lookup_table' );

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::Roary::Exceptions::CouldntWriteToFile->throw( error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _build__output_header_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_header_filename )
      or Bio::Roary::Exceptions::CouldntWriteToFile->throw( error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _build_output_header_filename {
    my ($self) = @_;
    my $base_name = $self->output_filename;
    $base_name =~ s/\.tab/.header.embl/i;
    return $base_name;
}

sub _build__sorted_file_names {
    my ($self) = @_;
    my @sorted_file_names = sort( @{ $self->analyse_groups_obj->fasta_files } );
    return \@sorted_file_names;
}

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

sub _block {
    my ( $self, $group ) = @_;
    my @taxon_names_array;
    my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};

    return ''
      if (
        !(
               defined( $self->groups_to_contigs->{$annotated_group_name} )
            && defined( $self->groups_to_contigs->{$annotated_group_name}->{ $self->ordering_key } )
        )
      );

    return ''
      if ( defined( $self->groups_to_contigs->{$annotated_group_name}->{comment} )
        && $self->groups_to_contigs->{$annotated_group_name}->{comment} ne '' );

    my $coordindates = $self->groups_to_contigs->{$annotated_group_name}->{ $self->ordering_key };

    for my $filename ( @{ $self->_sorted_file_names } ) {
        my $group_to_file_genes = $self->_groups_to_files->{$group}->{$filename};

        if ( defined($group_to_file_genes) && @{$group_to_file_genes} > 0 ) {
            my $filename_cpy = basename($filename);
            $filename_cpy =~ s!\.gff\.proteome\.faa!!;
            push( @taxon_names_array, $filename_cpy );
            next;
        }
    }

    my $colour = $self->_get_heat_map_colour( \@taxon_names_array, $self->annotate_groups_obj->_number_of_files );

    my $taxon_names = join( " ", @taxon_names_array );

    my $tab_file_entry = "FT   variation       $coordindates\n";
    $tab_file_entry .= "FT                   /colour=$colour\n";
    $tab_file_entry .= "FT                   /gene=$annotated_group_name\n";
    $tab_file_entry .= "FT                   /taxa=\"$taxon_names\"\n";

    return $tab_file_entry;
}

sub _get_heat_map_colour {
    my ( $self, $taxon_names, $number_of_files ) = @_;
    return $self->heatmap_lookup_table->[0] if ( @{$taxon_names} == 1 );
    my $number_of_colours = @{ $self->heatmap_lookup_table };
    return $self->heatmap_lookup_table->[ $number_of_colours - 1 ] if ( @{$taxon_names} == $number_of_files );

    my $block_size   = $number_of_files / @{ $self->heatmap_lookup_table };
    my $colour_index = ceil( @{$taxon_names} / $block_size ) - 1;
    return $self->heatmap_lookup_table->[$colour_index];
}

sub _build_heatmap_lookup_table {
    my ($self) = @_;
    return [
        4,     # blue (RGB values: 0 0 255)
        5,     # cyan (RGB values: 0 255 255)
        9,     # light sky blue (RGB values: 135 206 250)
        8,     # pale green (RGB values: 152 251 152)
        3,     # green (RGB values: 0 255 0)
        7,     # yellow (RGB values: 255 255 0)
        10,    # orange (RGB values: 255 165 0)
        16,    # light red (RGB values: 255 127 127)
        15,    # mid red: (RGB values: 255 63 63)
        2,     # red (RGB values: 255 0 0)
    ];
}

sub _block_colour {
    my ( $self, $accessory_label ) = @_;
    my $colour = 2;
    return $colour unless ( defined($accessory_label) );

    $colour += $accessory_label % 6;
    return $colour;
}

sub _header_block {
    my ( $self, $group ) = @_;
    my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};
    my $colour               = 1;

    return ''
      if (
        !(
               defined( $self->groups_to_contigs->{$annotated_group_name} )
            && defined( $self->groups_to_contigs->{$annotated_group_name}->{ $self->ordering_key } )
        )
      );
    return ''
      if ( defined( $self->groups_to_contigs->{$annotated_group_name}->{comment} )
        && $self->groups_to_contigs->{$annotated_group_name}->{comment} ne '' );
    my $coordindates    = $self->groups_to_contigs->{$annotated_group_name}->{ $self->ordering_key };
    my $annotation_type = $self->_annotation_type($annotated_group_name);

    $colour = $self->_block_colour( $self->groups_to_contigs->{$annotated_group_name}->{accessory_label} );

    my $tab_file_entry = "FT$annotation_type$coordindates\n";
    $tab_file_entry .= "FT                   /label=$annotated_group_name\n";
    $tab_file_entry .= "FT                   /locus_tag=$annotated_group_name\n";
    $tab_file_entry .= "FT                   /colour=$colour\n";

    return $tab_file_entry;
}

sub _fragment_blocks {
    my ( $self, $fh ) = @_;
    my %fragment_numbers;
    for my $group ( @{ $self->annotate_groups_obj->_groups } ) {
        my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};

        next unless ( defined( $self->groups_to_contigs->{$annotated_group_name}->{accessory_label} ) );
        next unless ( defined( $self->groups_to_contigs->{$annotated_group_name}->{ $self->ordering_key } ) );
        next if ( $self->groups_to_contigs->{$annotated_group_name}->{ $self->ordering_key } eq '' );
        push(
            @{ $fragment_numbers{ $self->groups_to_contigs->{$annotated_group_name}->{accessory_label} } },
            $self->groups_to_contigs->{$annotated_group_name}->{ $self->ordering_key }
        );
    }

    for my $accessory_label ( keys %fragment_numbers ) {
        next unless ( defined( $fragment_numbers{$accessory_label} ) );
        my @sorted_fragment = sort { $a <=> $b } @{ $fragment_numbers{$accessory_label} };
        my $tab_file_entry = '';
        if ( @sorted_fragment > 1 ) {
            my $min = $sorted_fragment[0];
            my $max = $sorted_fragment[-1];

            next if ( !defined($min) || !defined($max) || $min eq '' || $max eq '' );
            $tab_file_entry = "FT   feature         $min" . '..' . "$max\n";
        }
        elsif ( @sorted_fragment == 1 ) {
            my $min = $sorted_fragment[0];
            next if ( !defined($min) || $min eq '' );
            $tab_file_entry = "FT   feature         $min\n";
        }
        else {
            next;
        }
        $tab_file_entry .= "FT                   /colour=" . $self->_block_colour($accessory_label) . "\n";

        print {$fh} $tab_file_entry;
    }

}

sub create_files {
    my ($self) = @_;

    print { $self->_output_header_fh } $self->_header_top();
    for my $group ( @{ $self->annotate_groups_obj->_groups } ) {
        print { $self->_output_fh } $self->_block($group);
        print { $self->_output_header_fh } $self->_header_block($group);
    }
    $self->_fragment_blocks( $self->_output_header_fh );
    print { $self->_output_header_fh } $self->_header_bottom();
    close( $self->_output_header_fh );
    close( $self->_output_fh );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
