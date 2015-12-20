undef $VERSION;
package Bio::Roary::CommandLine::AssemblyStatistics;

# ABSTRACT: Given a spreadsheet of gene presence and absence calculate some statistics

=head1 SYNOPSIS

Given a spreadsheet of gene presence and absence calculate some statistics

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary::AssemblyStatistics;
extends 'Bio::Roary::CommandLine::Common';

has 'args'            => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'     => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'            => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'spreadsheet'     => ( is => 'rw', isa => 'Str',      default  => 'gene_presence_absence.csv' );
has 'job_runner'      => ( is => 'rw', isa => 'Str',      default  => 'Local' );
has 'cpus'            => ( is => 'rw', isa => 'Int',      default  => 1 );
has 'output_filename' => ( is => 'rw', isa => 'Str',      default  => 'assembly_statistics.csv' );
has 'version'         => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'core_definition' => ( is => 'rw', isa => 'Num',      default  => 0.99 );
has 'verbose'         => ( is => 'rw', isa => 'Bool',     default  => 0 );


sub BUILD {
    my ($self) = @_;

    my (
        $spreadsheet,
		$job_runner,       
		$cpus,
		$output_filename,
		$version,
		$core_definition,
		$verbose,
		$help
    );

    GetOptionsFromArray(
        $self->args,
        'o|output_filename=s'       => \$output_filename,
        'j|job_runner=s'            => \$job_runner,
        'p|processors=i'            => \$cpus,
        'cd|core_definition=f'      => \$core_definition,
        'v|verbose'                 => \$verbose,
		'w|version'                 => \$version,
        'h|help'                    => \$help,
    );

	$self->version($version)                   if ( defined($version) );
    if ( $self->version ) {
        die($self->_version());
    }

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }

    $self->help($help) if ( defined($help) );
	( !$self->help ) or die $self->usage_text;
    if(@{$self->args} == 0)
    {
        $self->logger->error("Error: You need to provide a gene_presence_absence.csv spreadsheet");
        die $self->usage_text;
    }
	$self->output_filename($output_filename)   if ( defined($output_filename) );
    $self->job_runner($job_runner)             if ( defined($job_runner) );
    $self->cpus($cpus)                         if ( defined($cpus) );

    if ( $self->cpus > 1 ) {
        $self->job_runner('Parallel');
    }

    $self->core_definition( $core_definition / 100 ) if ( defined($core_definition) );

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->logger->error("Error: Cant access file $filename");
            die $self->usage_text;
        }
    }
    $self->spreadsheet( $self->args->[0] );

}

sub _version
{
	my ($self) = @_;
	if(defined($Bio::Roary::CommandLine::AssemblyStatistics::VERSION))
	{
	   return $Bio::Roary::CommandLine::AssemblyStatistics::VERSION ."\n";
    }
	else
	{
	   return "x.y.z\n";
	}
}

sub run {
    my ($self) = @_;

    my $obj = Bio::Roary::AssemblyStatistics->new( spreadsheet => $self->spreadsheet, logger => $self->logger );
	$obj->create_summary_output;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: pan_genome_assembly_statistics [options] gene_presence_absence.csv
Take in a gene presence and absence spreadsheet and output some statistics
  
Options: -p INT    number of threads [1]	
         -o STR    output filename [assembly_statistics.csv]
         -cd FLOAT percentage of isolates a gene must be in to be core [99]
         -v        verbose output to STDOUT
         -w        print version and exit
         -h        this help message
		 
Example: Run with defaults
         pan_genome_assembly_statistics gene_presence_absence.csv

For further information see: http://sanger-pathogens.github.io/Roary/
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
