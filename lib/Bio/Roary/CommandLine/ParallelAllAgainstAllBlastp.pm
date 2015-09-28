undef $VERSION;
package Bio::Roary::CommandLine::ParallelAllAgainstAllBlastp;

# ABSTRACT: Take in a FASTA file of proteins and blast against itself

=head1 SYNOPSIS

Take in a FASTA file of proteins and blast against itself

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary::ParallelAllAgainstAllBlast;
use Bio::Roary::CombinedProteome;
use Bio::Roary::PrepareInputFiles;
extends 'Bio::Roary::CommandLine::Common';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'fasta_files'       => ( is => 'rw', isa => 'ArrayRef' );
has 'output_filename'   => ( is => 'rw', isa => 'Str', default => 'blast_results' );
has 'job_runner'        => ( is => 'rw', isa => 'Str', default => 'Local' );
has 'cpus'                        => ( is => 'rw', isa => 'Int',  default => 1 );
has 'makeblastdb_exec'  => ( is => 'rw', isa => 'Str', default => 'makeblastdb' );
has 'blastp_exec'       => ( is => 'rw', isa => 'Str', default => 'blastp' );
has 'verbose'           => ( is => 'rw', isa => 'Bool', default => 0 );

has '_error_message' => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $fasta_files, $output_filename, $job_runner, $makeblastdb_exec, $blastp_exec, $help, $cpus, $verbose, );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'           => \$output_filename,
        'j|job_runner=s'       => \$job_runner,
        'm|makeblastdb_exec=s' => \$makeblastdb_exec,
        'b|blastp_exec=s'      => \$blastp_exec,
        'p|processors=i'       => \$cpus,
		'v|verbose'            => \$verbose,
        'h|help'               => \$help,
    );
    
    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide a FASTA file");
    }

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }
    $self->help($help) if(defined($help));
    $self->output_filename($output_filename)   if ( defined($output_filename) );
    $self->makeblastdb_exec($makeblastdb_exec) if ( defined($makeblastdb_exec) );
    $self->blastp_exec($blastp_exec)           if ( defined($blastp_exec) );
    $self->job_runner($job_runner)             if ( defined($job_runner) );
    $self->cpus($cpus)                         if ( defined($cpus) );
    if ( $self->cpus > 1 ) {
        $self->job_runner('Parallel');
    }

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->_error_message("Error: Cant access file $filename");
            last;
        }
    }
    $self->fasta_files( $self->args );

}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }
    
    my $prepare_input_files = Bio::Roary::PrepareInputFiles->new(
      input_files   => $self->fasta_files,
    );
    
    my $output_combined_filename;
    if(@{$self->fasta_files} > 1)
    {
      $output_combined_filename = 'combined_files.fa';
	  $self->logger->info("Combining protein files");
      my $combine_fasta_files = Bio::Roary::CombinedProteome->new(
        proteome_files                 => $prepare_input_files->fasta_files,
        output_filename                => $output_combined_filename,
        maximum_percentage_of_unknowns => 5.0,
        apply_unknowns_filter          => 0
      );
      $combine_fasta_files->create_combined_proteome_file;
    }
    else
    {
      $output_combined_filename = $self->fasta_files->[0];
    }

    $self->logger->info("Beginning all against all blast");
    my $blast_obj = Bio::Roary::ParallelAllAgainstAllBlast->new(
        fasta_file       => $output_combined_filename,
        blast_results_file_name  => $self->output_filename,
        job_runner       => $self->job_runner,
        cpus             => $self->cpus,
        makeblastdb_exec => $self->makeblastdb_exec,
        blastp_exec      => $self->blastp_exec,
		logger           => $self->logger
    );
    $blast_obj->run();
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: parallel_all_against_all_blastp [options] file.faa
Take in a FASTA file of proteins and blast against itself

Options: -p INT    number of threads [1]
         -o STR    output filename for blast results [blast_results]
         -m STR    makeblastdb executable [makeblastdb]
         -b STR    blastp executable [blastp]
         -v        verbose output to STDOUT
         -h        this help message

For further info see: http://sanger-pathogens.github.io/Roary/
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
