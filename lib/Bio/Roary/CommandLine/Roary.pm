package Bio::Roary::CommandLine::Roary;

# ABSTRACT: Take in FASTA files of proteins and cluster them

=head1 SYNOPSIS

Take in FASTA files of proteins and cluster them

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary;
use Bio::Roary::PrepareInputFiles;
use Bio::Roary::QC::Report;
use File::Which; 
extends 'Bio::Roary::CommandLine::Common';

has 'args'              => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'       => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'              => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'fasta_files'       => ( is => 'rw', isa => 'ArrayRef' );
has 'output_filename'   => ( is => 'rw', isa => 'Str', default => 'clustered_proteins' );
has 'job_runner'        => ( is => 'rw', isa => 'Str', default => 'Local' );
has 'makeblastdb_exec'  => ( is => 'rw', isa => 'Str', default => 'makeblastdb' );
has 'blastp_exec'       => ( is => 'rw', isa => 'Str', default => 'blastp' );
has 'mcxdeblast_exec'   => ( is => 'rw', isa => 'Str', default => 'mcxdeblast' );
has 'mcl_exec'          => ( is => 'rw', isa => 'Str', default => 'mcl' );
has 'apply_unknowns_filter'       => ( is => 'rw', isa => 'Bool', default => 1 );
has 'cpus'                        => ( is => 'rw', isa => 'Int',  default => 1 );
has 'output_multifasta_files'     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'perc_identity'               => ( is => 'rw', isa => 'Num',  default => 98 );
has 'dont_delete_files'           => ( is => 'rw', isa => 'Bool', default => 0 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool', default => 1 );
has 'dont_run_qc'                 => ( is => 'rw', isa => 'Bool', default => 0 );
has 'dont_split_groups'           => ( is => 'rw', isa => 'Bool', default => 0 );
has 'verbose_stats'               => ( is => 'rw', isa => 'Bool', default => 0 );
has 'translation_table'           => ( is => 'rw', isa => 'Int',  default => 11 );
has 'group_limit'                 => ( is => 'rw', isa => 'Num',  default => 50000 );
has 'core_definition'             => ( is => 'rw', isa => 'Num',  default => 1 );
has 'verbose'                     => ( is => 'rw', isa => 'Bool', default => 0 );

has '_error_message'    => ( is => 'rw', isa => 'Str' );
has 'run_qc'            => ( is => 'rw', isa => 'Bool', default => 0 );

sub BUILD {
    my ($self) = @_;

    my ( $fasta_files,$verbose, $create_rplots,$group_limit, $dont_run_qc, $max_threads, $dont_delete_files, $dont_split_groups, $perc_identity, $output_filename, $job_runner, $makeblastdb_exec,$mcxdeblast_exec,$mcl_exec, $blastp_exec, $apply_unknowns_filter, $cpus,$output_multifasta_files, $verbose_stats, $translation_table, $run_qc, $core_definition, $help );

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
        'dont_split_groups'         => \$dont_split_groups,
        'create_rplots'             => \$create_rplots,
        'verbose_stats'             => \$verbose_stats,
        't|translation_table=i'     => \$translation_table,
        'group_limit=i'             => \$group_limit,
        'qc|run_qc'                 => \$run_qc,
		'dont_run_qc'               => \$dont_run_qc,
        'cd|core_definition=i'      => \$core_definition,
		'v|verbose'                 => \$verbose,
        'h|help'                    => \$help,
    );
    

    print "\nPlease cite Roary if you use any of the results it produces:
    \"Roary: Rapid large-scale prokaryote pan genome analysis\",
    Andrew J. Page, Carla A. Cummins, Martin Hunt, Vanessa K. Wong, Sandra Reuter, Matthew T. G. Holden, Maria Fookes, Jacqueline A. Keane, Julian Parkhill,
    bioRxiv doi: http://dx.doi.org/10.1101/019315\n\n";
    
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
    if ( defined($output_multifasta_files) )
	{
		if(which('revtrans.py'))
		{
		  $self->output_multifasta_files($output_multifasta_files) ;
	    }
	    else
		{
			print "WARNING: revtrans.py not found in your PATH so cannot generate multiFASTA alignments, skipping for now.\n";
		}
	}
    $self->dont_delete_files($dont_delete_files)             if ( defined($dont_delete_files) );
    $self->dont_split_groups($dont_split_groups)             if ( defined($dont_split_groups) );
    $self->dont_create_rplots(0)                             if ( defined($create_rplots) );
    $self->verbose_stats($verbose_stats)                     if ( defined $verbose_stats );
    $self->translation_table($translation_table)             if ( defined($translation_table) );
    $self->group_limit($group_limit)                         if ( defined($group_limit) );
	$self->verbose($verbose)                                 if ( defined($verbose) );
    
	if ( defined( $run_qc ) )
	{
		if(which('kraken') && which('kraken-report'))
		{
		    $self->run_qc($run_qc) ;
	    }
		else
		{
			print "WARNING: kraken or kraken-report not found in your PATH so cannot run QC, skipping for now.\n";
		}
	}
	
	if($self->cpus > 1)
	{
		$self->job_runner('Parallel');
	}
	
    $self->core_definition( $core_definition/100 ) if ( defined($core_definition) );

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
    
	print "Extracting proteins from GFF files\n" if($self->verbose);
    my $prepare_input_files = Bio::Roary::PrepareInputFiles->new(
      input_files           => $self->fasta_files,
      job_runner            => $self->job_runner,
      apply_unknowns_filter => $self->apply_unknowns_filter,
      cpus                  => $self->cpus,
      translation_table     => $self->translation_table,
	  verbose               => $self->verbose
    );

    if( $self->run_qc ){
		print "Running Kraken on each input assembly\n" if($self->verbose);
        my $qc_input_files = Bio::Roary::QC::Report->new(
            input_files => $self->fasta_files,
            job_runner  => $self->job_runner,
			cpus        => $self->cpus,
			verbose     => $self->verbose
        );
        $qc_input_files->report;
    }

    my $pan_genome_obj = Bio::Roary->new(
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
        dont_split_groups       => $self->dont_split_groups,
        verbose_stats           => $self->verbose_stats,
        translation_table       => $self->translation_table,
        group_limit             => $self->group_limit,
        core_definition         => $self->core_definition,
		verbose                 => $self->verbose
      );
    $pan_genome_obj->run();
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: roary [options]
    Take in GFF files and cluster the genes
    
    # Take in GFF files and cluster the genes
    roary example.gff
	
    # Run with 4 processors
    roary -p 4  *.gff
    
    # Provide an output filename
    roary -o results *.gff
    
    # Create a MultiFASTA alignment of core genes, so that you can build a phylogenetic tree
	# Requires RevTrans.py to be installed
    roary -e *.gff
	
    # Create multifasta alignement of each gene (Warning: Thousands of files are created)
    roary -e --dont_delete_files *.gff
	
    # Create a MultiFASTA alignment of core genes where core is defined as being in at least 98% of isolates
    roary -e --core_definition 98 *.gff
	
    # Set the blastp percentage identity threshold (default 98%).
    roary -i 95 *.gff
    
    # Different translation table (default is 11 for Bacteria). Viruses/Vert = 1
    roary --translation_table 1 *.gff 

    # Verbose output to STDOUT so that you know whats happening as it goes along
    roary -v *.gff

    # Include full annotation and inference in group statistics
    roary --verbose_stats *.gff

    # Increase the groups/clusters limit (default 50,000). If you need to change this your
    # probably trying to work data from more than one species, and you should check the results of the qc option.
    roary --group_limit 60000  *.gff

    # Generate QC report detailing top genus and species for each assembly
	# Requires Kraken to be installed
    roary -qc *.gff

    # This help message
    roary -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
