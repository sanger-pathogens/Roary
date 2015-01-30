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
has 'apply_unknowns_filter'       => ( is => 'rw', isa => 'Bool', default => 1 );
has 'cpus'                        => ( is => 'rw', isa => 'Int',  default => 1 );
has 'output_multifasta_files'     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'perc_identity'               => ( is => 'rw', isa => 'Num',  default => 98 );
has 'dont_delete_files'           => ( is => 'rw', isa => 'Bool', default => 0 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool', default => 0 );
has 'verbose_stats'               => ( is => 'rw', isa => 'Bool', default => 0 );
has 'translation_table'           => ( is => 'rw', isa => 'Int',  default => 11 );
has 'group_limit'                 => ( is => 'rw', isa => 'Num',  default => 50000 );

has '_error_message'    => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $fasta_files, $dont_create_rplots,$group_limit, $max_threads, $dont_delete_files, $perc_identity, $output_filename, $job_runner, $makeblastdb_exec,$mcxdeblast_exec,$mcl_exec, $blastp_exec, $apply_unknowns_filter, $cpus,$output_multifasta_files, $verbose_stats, $translation_table, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'                => \$output_filename,
        'j|job_runner=s'            => \$job_runner,
        'm|makeblastdb_exec=s'      => \$makeblastdb_exec,
        'b|blastp_exec=s'           => \$blastp_exec,
        'd|mcxdeblast_exec=s'       => \$mcxdeblast_exec,
        'c|mcl_exec=s'              => \$mcl_exec, 
        'p|processors=i'            => \$cpus,
        'apply_unknowns_filter=i'   => \$apply_unknowns_filter,
        'e|output_multifasta_files' => \$output_multifasta_files,
        'i|perc_identity=i'         => \$perc_identity,
        'dont_delete_files'         => \$dont_delete_files,
        'dont_create_rplots'        => \$dont_create_rplots,
        'verbose_stats'             => \$verbose_stats,
        't|translation_table=i'     => \$translation_table,
        'group_limit=i'             => \$group_limit,
        'h|help'                    => \$help,
    );
    
    $self->help($help) if(defined($help));
    if ( @{ $self->args } == 0 ) {
        $self->_error_message("Error: You need to provide a GFF file");
    }

    $self->output_filename($output_filename)   if ( defined($output_filename) );
    $self->job_runner($job_runner)             if ( defined($job_runner) );
    $self->makeblastdb_exec($makeblastdb_exec) if ( defined($makeblastdb_exec) );
    $self->blastp_exec($blastp_exec)           if ( defined($blastp_exec) );
    $self->mcxdeblast_exec($mcxdeblast_exec)   if ( defined($mcxdeblast_exec) );
    $self->mcl_exec($mcl_exec)                 if ( defined($mcl_exec) );
    $self->cpus($cpus)                         if ( defined($cpus) );
    $self->perc_identity($perc_identity)       if ( defined($perc_identity) );
    $self->apply_unknowns_filter($apply_unknowns_filter)     if ( defined($apply_unknowns_filter) );
    $self->output_multifasta_files($output_multifasta_files) if ( defined($output_multifasta_files) );
    $self->dont_delete_files($dont_delete_files)             if ( defined($dont_delete_files) );
    $self->dont_create_rplots($dont_create_rplots)           if (defined($dont_create_rplots) );
    $self->verbose_stats($verbose_stats)                     if ( defined $verbose_stats );
    $self->translation_table($translation_table)             if (defined($translation_table) );
    $self->group_limit($group_limit)                         if ( defined($group_limit) );

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
      apply_unknowns_filter => $self->apply_unknowns_filter,
      cpus                  => $self->cpus,
      translation_table     => $self->translation_table
    );
    
    my $pan_genome_obj = Bio::PanGenome->new(
        input_files             => $self->fasta_files,
        fasta_files             => $prepare_input_files->fasta_files,
        output_filename         => $self->output_filename,
        job_runner              => $self->job_runner,
        cpus                    => $self->cpus,
        makeblastdb_exec        => $self->makeblastdb_exec,
        blastp_exec             => $self->blastp_exec,
        output_multifasta_files => $self->output_multifasta_files,
        perc_identity           => $self->perc_identity,
        dont_delete_files       => $self->dont_delete_files,
        dont_create_rplots      => $self->dont_create_rplots,
        verbose_stats           => $self->verbose_stats,
        translation_table       => $self->translation_table
        group_limit             => $self->group_limit
      );
    $pan_genome_obj->run();
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: create_pan_genome [options]
    Take in GFF files and cluster the genes
    
    For more details see:
    http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Pan_Genome_Pipeline
    
    # Take in GFF files and cluster the genes
    nohup create_pan_genome example.gff & 
    
    # Provide an output filename
    create_pan_genome -o results *.gff
    
    # Create a multifasta file for each group of sequences (Warning: thousands of files created)
    create_pan_genome -e *.gff
    
    # Set the blastp percentage identity threshold (default 98%).
    create_pan_genome -i 99 *.gff
    
    # Dont delete the intermediate files
    create_pan_genome --dont_delete_files *.gff
    
    # Different translation table (default is 11 which is for Bacteria). Viruses/Vert = 1
    create_pan_genome --translation_table 1 *.gff 

    # Include full annotation and inference in group statistics
    create_pan_genome --verbose_stats *.gff
    
    # Run sequentially without LSF
    create_pan_genome -j Local *.gff
    
    # Run locally with GNU parallel and 4 processors
    create_pan_genome -j Parallel -p 4  *.gff

    # Increase the groups/clusters limit (default 50,000). If you need to change this your
    # probably trying to work data from more than one species (which this script wasnt designed for).
    create_pan_genome --group_limit 60000  *.gff

    # This help message
    create_pan_genome -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
