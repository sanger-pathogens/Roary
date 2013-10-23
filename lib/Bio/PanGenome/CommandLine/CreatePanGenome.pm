package Bio::PanGenome::CommandLine::CreatePanGenome;

# ABSTRACT: Take in FASTA files of proteins and cluster them

=head1 SYNOPSIS

Take in FASTA files of proteins and cluster them

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome;
use Bio::PanGenome::PrepareInputFiles;


has 'args'              => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'       => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'              => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'fasta_files'       => ( is => 'rw', isa => 'ArrayRef' );
has 'output_filename'   => ( is => 'rw', isa => 'Str', default => 'clustered_proteins' );
has 'job_runner'        => ( is => 'rw', isa => 'Str', default => 'LSF' );
has 'makeblastdb_exec'  => ( is => 'rw', isa => 'Str', default => 'makeblastdb' );
has 'blastp_exec'       => ( is => 'rw', isa => 'Str', default => 'blastp' );
has 'mcxdeblast_exec'   => ( is => 'rw', isa => 'Str', default => 'mcxdeblast' );
has 'mcl_exec'          => ( is => 'rw', isa => 'Str', default => 'mcl' );
has 'apply_unknowns_filter' => ( is => 'rw', isa => 'Bool', default => 1 );
has 'cpus'              => ( is => 'rw', isa => 'Int', default => 1 );
has 'output_multifasta_files'     => ( is => 'rw', isa => 'Bool',     default  => 0 );

has '_error_message'    => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $fasta_files, $output_filename, $job_runner, $makeblastdb_exec,$mcxdeblast_exec,$mcl_exec, $blastp_exec, $apply_unknowns_filter, $cpus,$output_multifasta_files, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'           => \$output_filename,
        'j|job_runner=s'       => \$job_runner,
        'm|makeblastdb_exec=s' => \$makeblastdb_exec,
        'b|blastp_exec=s'      => \$blastp_exec,
        'd|mcxdeblast_exec=s'    => \$mcxdeblast_exec,
        'c|mcl_exec=s'           => \$mcl_exec, 
        'p|processors=i'       => \$cpus,
        'apply_unknowns_filter=i' => \$apply_unknowns_filter,
        'e|output_multifasta_files' => \$output_multifasta_files,
        'h|help'               => \$help,
    );
    
    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide a FASTA file");
    }

    $self->output_filename($output_filename)   if ( defined($output_filename) );
    $self->job_runner($job_runner)             if ( defined($job_runner) );
    $self->makeblastdb_exec($makeblastdb_exec) if ( defined($makeblastdb_exec) );
    $self->blastp_exec($blastp_exec)           if ( defined($blastp_exec) );
    $self->mcxdeblast_exec($mcxdeblast_exec)   if ( defined($mcxdeblast_exec) );
    $self->mcl_exec($mcl_exec)                 if ( defined($mcl_exec) );
    $self->cpus($cpus)                         if ( defined($cpus) );
    $self->apply_unknowns_filter($apply_unknowns_filter)     if ( defined($apply_unknowns_filter) );
    $self->output_multifasta_files($output_multifasta_files) if ( defined($output_multifasta_files) );

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
    
    my $prepare_input_files = Bio::PanGenome::PrepareInputFiles->new(
      input_files           => $self->fasta_files,
      job_runner            => $self->job_runner,
      apply_unknowns_filter => $self->apply_unknowns_filter
    );
    
    my $pan_genome_obj = Bio::PanGenome->new(
        input_files      => $self->fasta_files,
        fasta_files      => $prepare_input_files->fasta_files,
        output_filename  => $self->output_filename,
        job_runner       => $self->job_runner,
        makeblastdb_exec => $self->makeblastdb_exec,
        blastp_exec      => $self->blastp_exec,
        output_multifasta_files => $self->output_multifasta_files
      );
    $pan_genome_obj->run();
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: create_pan_genome [options]
    Take in GFF files and cluster the genes
    
    # Take in GFF files and cluster the genes
    create_pan_genome example.gff
    
    # Provide an output filename
    create_pan_genome -o results *.gff
    
    # Create a multifasta file for each group of sequences (Warning: thousands of files created)
    create_pan_genome -e *.gff

    # This help message
    create_pan_genome -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
