package Bio::PanGenome::CommandLine::ExtractProteomeFromGff;

# ABSTRACT: Take in GFF files and output the proteome

=head1 SYNOPSIS

Take in a GFF file and output the proteome

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::ExtractProteomeFromGFF;
use File::Basename;
extends 'Bio::PanGenome::CommandLine::Common';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'gff_files'             => ( is => 'rw', isa => 'ArrayRef' );
has 'output_suffix'         => ( is => 'rw', isa => 'Str', default => 'proteome.faa' );
has '_error_message'        => ( is => 'rw', isa => 'Str' );
has 'apply_unknowns_filter' => ( is => 'rw', isa => 'Bool', default => 1 );
has 'translation_table'           => ( is => 'rw', isa => 'Int',  default => 11 );

sub BUILD {
    my ($self) = @_;

    my ( $gff_files, $output_suffix, $apply_unknowns_filter, $help, $translation_table );

    GetOptionsFromArray(
        $self->args,
        'o|output_suffix=s'       => \$output_suffix,
        'apply_unknowns_filter=i' => \$apply_unknowns_filter,
        't|translation_table=i'   => \$translation_table,
        'h|help'                  => \$help,
    );

    $self->help($help) if(defined($help));
    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide a GFF file");
    }

    if ( defined($output_suffix) ) {
        $self->output_suffix($output_suffix);
    }

    $self->apply_unknowns_filter($apply_unknowns_filter) if ( defined($apply_unknowns_filter) );
    $self->translation_table($translation_table)         if (defined($translation_table) );

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->_error_message("Error: Cant access file $filename");
            last;
        }
    }
    $self->gff_files( $self->args );

}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    for my $gff_file ( @{ $self->gff_files } ) {
        my ( $filename, $directories, $suffix ) = fileparse($gff_file);
        my $obj = Bio::PanGenome::ExtractProteomeFromGFF->new(
            gff_file              => $gff_file,
            output_filename       => $filename . '.' . $self->output_suffix,
            apply_unknowns_filter => $self->apply_unknowns_filter,
            translation_table     => $self->translation_table
        );
        $obj->fasta_file();
    }

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: extract_proteome_from_gff [options]
    Take in GFF files and create Fasta files of the protein sequences
    
    extract_proteome_from_gff *.gff
    
    # specify an output suffix
    extract_proteome_from_gff -o output_suffix.faa  *.gff
    
    # specify an output suffix
    extract_proteome_from_gff --translation_table 1  *.gff
    
    # This help message
    extract_proteome_from_gff -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
