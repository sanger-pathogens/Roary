undef $VERSION;
package Bio::Roary::CommandLine::ExtractProteomeFromGff;

# ABSTRACT: Take in GFF files and output the proteome

=head1 SYNOPSIS

Take in a GFF file and output the proteome

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary::ExtractProteomeFromGFF;
use File::Basename;
extends 'Bio::Roary::CommandLine::Common';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'gff_files'             => ( is => 'rw', isa => 'ArrayRef' );
has 'output_suffix'         => ( is => 'rw', isa => 'Str',  default => 'proteome.faa' );
has '_error_message'        => ( is => 'rw', isa => 'Str' );
has 'apply_unknowns_filter' => ( is => 'rw', isa => 'Bool', default => 1 );
has 'translation_table'     => ( is => 'rw', isa => 'Int',  default => 11 );
has 'verbose'               => ( is => 'rw', isa => 'Bool', default => 0 );
has 'output_directory'      => ( is => 'rw', isa => 'Str',  default => '.' );

sub BUILD {
    my ($self) = @_;

    my ( $gff_files, $output_suffix, $apply_unknowns_filter, $help, $translation_table, $verbose, $cmd_version, $output_directory  );

    GetOptionsFromArray(
        $self->args,
        'o|output_suffix=s'       => \$output_suffix,
        'f|apply_unknowns_filter=i' => \$apply_unknowns_filter,
        't|translation_table=i'   => \$translation_table,
		'v|verbose'               => \$verbose,
        'd|output_directory=s'    => \$output_directory,
		'w|version'               => \$cmd_version,
        'h|help'                  => \$help,
    );
	
    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }
	
	$self->help($help) if(defined($help));
	( !$self->help ) or die $self->usage_text;
	
    $self->version($cmd_version) if ( defined($cmd_version) );
    if ( $self->version ) {
        die($self->_version());
    }

    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide a GFF file");
    }

    $self->output_suffix($output_suffix)                 if ( defined($output_suffix) ) ;
    $self->apply_unknowns_filter($apply_unknowns_filter) if ( defined($apply_unknowns_filter) );
    $self->translation_table($translation_table)         if ( defined($translation_table) );
    $self->output_directory($output_directory)           if ( defined($output_directory) );

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

    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    for my $gff_file ( @{ $self->gff_files } ) {
        my ( $filename, $directories, $suffix ) = fileparse($gff_file);
        my $obj = Bio::Roary::ExtractProteomeFromGFF->new(
            gff_file              => $gff_file,
            output_filename       => $filename . '.' . $self->output_suffix,
            apply_unknowns_filter => $self->apply_unknowns_filter,
            translation_table     => $self->translation_table,
            output_directory      => $self->output_directory,
        );
        $obj->fasta_file();
    }

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: extract_proteome_from_gff [options] *.gff
Take in GFF files and create FASTA files of the protein sequences

Options: -o STR    output suffix [proteome.faa]
         -t INT    translation table [11]
         -f        filter sequences with missing data
         -v        verbose output to STDOUT
         -d STR    output directory
         -w        print version and exit
         -h        this help message

For further info see: http://sanger-pathogens.github.io/Roary/
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
