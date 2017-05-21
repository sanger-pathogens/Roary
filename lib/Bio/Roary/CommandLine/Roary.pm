undef $VERSION;

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
use Bio::Roary::ReformatInputGFFs;
use Bio::Roary::External::CheckTools;
use File::Which;
use File::Path qw(make_path);
use Cwd qw(abs_path getcwd);
use File::Temp;
extends 'Bio::Roary::CommandLine::Common';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'fasta_files' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'output_filename'         => ( is => 'rw', isa => 'Str',  default => 'clustered_proteins' );
has 'output_directory'        => ( is => 'rw', isa => 'Str',  default => '.' );
has '_original_directory'     => ( is => 'rw', isa => 'Str',  default => '.' );
has 'job_runner'              => ( is => 'rw', isa => 'Str',  default => 'Local' );
has 'makeblastdb_exec'        => ( is => 'rw', isa => 'Str',  default => 'makeblastdb' );
has 'blastp_exec'             => ( is => 'rw', isa => 'Str',  default => 'blastp' );
has 'mcxdeblast_exec'         => ( is => 'rw', isa => 'Str',  default => 'mcxdeblast' );
has 'mcl_exec'                => ( is => 'rw', isa => 'Str',  default => 'mcl' );
has 'apply_unknowns_filter'   => ( is => 'rw', isa => 'Bool', default => 1 );
has 'cpus'                    => ( is => 'rw', isa => 'Int',  default => 1 );
has 'output_multifasta_files' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'perc_identity'           => ( is => 'rw', isa => 'Num',  default => 95 );
has 'dont_delete_files'       => ( is => 'rw', isa => 'Bool', default => 0 );
has 'dont_create_rplots'      => ( is => 'rw', isa => 'Bool', default => 1 );
has 'dont_run_qc'             => ( is => 'rw', isa => 'Bool', default => 0 );
has 'dont_split_groups'       => ( is => 'rw', isa => 'Bool', default => 0 );
has 'verbose_stats'           => ( is => 'rw', isa => 'Bool', default => 0 );
has 'translation_table'       => ( is => 'rw', isa => 'Int',  default => 11 );
has 'mafft'                   => ( is => 'rw', isa => 'Bool', default => 0 );
has 'group_limit'             => ( is => 'rw', isa => 'Num',  default => 50000 );
has 'core_definition'         => ( is => 'rw', isa => 'Num',  default => 0.99 );
has 'verbose'                 => ( is => 'rw', isa => 'Bool', default => 0 );
has 'kraken_db' => ( is => 'rw', isa => 'Str',  default => '/lustre/scratch118/infgen/pathogen/pathpipe/kraken/minikraken_20140330/' );
has 'run_qc'    => ( is => 'rw', isa => 'Bool', default => 0 );
has '_working_directory' => ( is => 'rw', isa => 'File::Temp::Dir', lazy => 1, builder => '_build__working_directory' );

has 'inflation_value'             => ( is => 'rw', isa => 'Num',      default  => 1.5 );

sub _build__working_directory
{
	my ($self) = @_;
	return File::Temp->newdir( DIR => getcwd, CLEANUP => 1 );
}

sub BUILD {
    my ($self) = @_;

    my (
        $fasta_files,           $verbose,           $create_rplots,           $group_limit,   $dont_run_qc,
        $max_threads,           $dont_delete_files, $dont_split_groups,       $perc_identity, $output_filename,
        $job_runner,            $makeblastdb_exec,  $mcxdeblast_exec,         $mcl_exec,      $blastp_exec,
        $apply_unknowns_filter, $cpus,              $output_multifasta_files, $verbose_stats, $translation_table,
        $run_qc,                $core_definition,   $help,                    $kraken_db,     $cmd_version,
        $mafft,                 $output_directory,  $check_dependancies, $inflation_value,
    );

    GetOptionsFromArray(
        $self->args,
        'o|output=s'                => \$output_filename,
        'f|output_directory=s'      => \$output_directory,
        'j|job_runner=s'            => \$job_runner,
        'm|makeblastdb_exec=s'      => \$makeblastdb_exec,
        'b|blastp_exec=s'           => \$blastp_exec,
        'd|mcxdeblast_exec=s'       => \$mcxdeblast_exec,
        'c|mcl_exec=s'              => \$mcl_exec,
        'p|processors=i'            => \$cpus,
        'u|apply_unknowns_filter=i' => \$apply_unknowns_filter,
        'e|output_multifasta_files' => \$output_multifasta_files,
        'i|perc_identity=i'         => \$perc_identity,
        'z|dont_delete_files'       => \$dont_delete_files,
        's|dont_split_groups'       => \$dont_split_groups,
        'r|create_rplots'           => \$create_rplots,
        'y|verbose_stats'           => \$verbose_stats,
        't|translation_table=i'     => \$translation_table,
        'g|group_limit=i'           => \$group_limit,
        'qc|run_qc'                 => \$run_qc,
        'x|dont_run_qc'             => \$dont_run_qc,
        'cd|core_definition=f'      => \$core_definition,
        'v|verbose'                 => \$verbose,
        'n|mafft'                   => \$mafft,
        'k|kraken_db=s'             => \$kraken_db,
        'w|version'                 => \$cmd_version,
        'a|check_dependancies'      => \$check_dependancies,
	'iv|inflation_value=f'      => \$inflation_value,
        'h|help'                    => \$help,
    );

    $self->version($cmd_version) if ( defined($cmd_version) );
    if ( $self->version ) {
		print $self->_version() ;
        return;
    }

    print "\nPlease cite Roary if you use any of the results it produces:
    Andrew J. Page, Carla A. Cummins, Martin Hunt, Vanessa K. Wong, Sandra Reuter, Matthew T. G. Holden, Maria Fookes, Daniel Falush, Jacqueline A. Keane, Julian Parkhill,
	\"Roary: Rapid large-scale prokaryote pan genome analysis\", Bioinformatics, 2015 Nov 15;31(22):3691-3693
    doi: http://doi.org/10.1093/bioinformatics/btv421
	Pubmed: 26198102\n\n";

    $self->help($help) if ( defined($help) );
    if( $self->help ) 
	{
		print $self->usage_text;
		return;
	}

    if ($check_dependancies) {
        my $check_tools = Bio::Roary::External::CheckTools->new();
        $check_tools->check_all_tools;
        $self->logger->error( "Roary version " . $self->_version() );
    }

    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }

    if ( @{ $self->args } < 2 ) {
        $self->logger->error("Error: You need to provide at least 2 files to build a pan genome");
        die $self->usage_text;
    }
    $self->output_filename($output_filename)   if ( defined($output_filename) );
    $self->job_runner($job_runner)             if ( defined($job_runner) );
    $self->makeblastdb_exec($makeblastdb_exec) if ( defined($makeblastdb_exec) );
    $self->blastp_exec($blastp_exec)           if ( defined($blastp_exec) );
    $self->mcxdeblast_exec($mcxdeblast_exec)   if ( defined($mcxdeblast_exec) );
    $self->mcl_exec($mcl_exec)                 if ( defined($mcl_exec) );
    $self->cpus($cpus)                         if ( defined($cpus) );
    $self->inflation_value($inflation_value)   if ( defined($inflation_value));

    if ( defined($perc_identity) ) {
        $self->perc_identity($perc_identity);
        if ( $perc_identity < 50 ) {
            $self->logger->error(
"The percentage identity is too low. Either somethings wrong with your data, like contamination, or your doing something that the software isnt designed to support."
            );
        }
    }

    $self->mafft($mafft) if ( defined($mafft) );
    $self->apply_unknowns_filter($apply_unknowns_filter)
      if ( defined($apply_unknowns_filter) );

    if ( defined($output_multifasta_files) ) {
        if ( which('prank') ) {
            $self->output_multifasta_files($output_multifasta_files);
        }
        else {

            if ( which('mafft') ) {
                $self->output_multifasta_files($output_multifasta_files);
                $self->mafft(1);
                $self->logger->warn("PRANK not found in your PATH so using MAFFT instead to generate multiFASTA alignments.");
            }
            else {
                $self->logger->warn("PRANK (or MAFFT) not found in your PATH so cannot generate multiFASTA alignments, skipping for now.");
            }
        }
    }
    $self->dont_delete_files($dont_delete_files) if ( defined($dont_delete_files) );
    $self->dont_split_groups($dont_split_groups) if ( defined($dont_split_groups) );
    $self->dont_create_rplots(0)                 if ( defined($create_rplots) );
    $self->verbose_stats($verbose_stats)         if ( defined $verbose_stats );
    $self->translation_table($translation_table) if ( defined($translation_table) );
    $self->group_limit($group_limit)             if ( defined($group_limit) );
    $self->kraken_db($kraken_db)                 if ( defined($kraken_db) );
    $self->output_directory($output_directory)   if ( defined($output_directory) );

    if ( defined $verbose_stats && defined($output_multifasta_files) ) {
        $self->verbose_stats(0);
        $self->logger->warn("The verbose stats spreadsheet is not compatible with the core gene alignement so disabling verbose_stats");
    }

    if ( defined($run_qc) ) {
        if ( which('kraken') && which('kraken-report') ) {
            $self->run_qc($run_qc);
        }
        else {
            $self->logger->warn("kraken or kraken-report not found in your PATH so cannot run QC, skipping for now.");
        }
    }

    if ( $self->cpus > 1 ) {
        $self->job_runner('Parallel');
    }

    $self->core_definition( $core_definition / 100 ) if ( defined($core_definition) );

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->logger->error("Error: Cant access file $filename");
            die $self->usage_text;
        }
        push( @{ $self->fasta_files }, abs_path($filename) );
    }

    $self->_working_directory( File::Temp->newdir( DIR => getcwd, CLEANUP => 0 ) ) if ( $self->dont_delete_files );
}

sub _setup_output_directory {
    my ($self) = @_;
    return if ( $self->output_directory eq '.' || $self->output_directory eq '' );

    if ( -e $self->output_directory || -d $self->output_directory ) {
        $self->logger->warn("Output directory name exists already so adding a timestamp to the end");
        $self->output_directory( $self->output_directory() . '_' . time() );
        if ( -e $self->output_directory || -d $self->output_directory ) {
            die("Output directory name with time stamp exist so giving up");
        }
    }
    make_path( $self->output_directory, { error => \my $err } );
    if (@$err) {
        for my $diag (@$err) {
            my ( $file, $message ) = %$diag;
            die("Error creating output directory $message");
        }
    }
    $self->logger->info( "Output directory created: " . $self->output_directory );

    $self->_original_directory( getcwd() );
    chdir( $self->output_directory );
    return $self;
}

sub run {
    my ($self) = @_;
	
	return if($self->version || $self->help);

    $self->_setup_output_directory;

    $self->logger->info("Fixing input GFF files");
    my $reformat_input_files = Bio::Roary::ReformatInputGFFs->new( gff_files => $self->fasta_files, logger => $self->logger );
    $reformat_input_files->fix_duplicate_gene_ids();
    if ( @{ $reformat_input_files->fixed_gff_files } == 0 ) {
        die(
"All input files have been excluded from analysis. Please check you have valid GFF files, with annotation and a FASTA sequence at the end. Better still, reannotate your FASTA file with PROKKA."
        );
    }
    $self->fasta_files( $reformat_input_files->fixed_gff_files );

    $self->logger->info("Extracting proteins from GFF files");
    my $prepare_input_files = Bio::Roary::PrepareInputFiles->new(
        input_files           => $self->fasta_files,
        job_runner            => $self->job_runner,
        apply_unknowns_filter => $self->apply_unknowns_filter,
        cpus                  => $self->cpus,
        translation_table     => $self->translation_table,
        verbose               => $self->verbose,
        working_directory     => $self->_working_directory,

    );

    if ( $self->run_qc ) {
        $self->logger->info("Running Kraken on each input assembly");
        my $qc_input_files = Bio::Roary::QC::Report->new(
            input_files => $self->fasta_files,
            job_runner  => $self->job_runner,
            cpus        => $self->cpus,
            verbose     => $self->verbose,
            kraken_db   => $self->kraken_db
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
        verbose                 => $self->verbose,
        mafft                   => $self->mafft,
	inflation_value         => $self->inflation_value,
    );
    $pan_genome_obj->run();

    chdir( $self->_original_directory );
}

sub _version {
    my ($self) = @_;
    if ( defined($Bio::Roary::CommandLine::Roary::VERSION) ) {
        return $Bio::Roary::CommandLine::Roary::VERSION . "\n";
    }
    else {
        return "x.y.z\n";
    }
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage:   roary [options] *.gff

Options: -p INT    number of threads [1]
         -o STR    clusters output filename [clustered_proteins]
         -f STR    output directory [.]
         -e        create a multiFASTA alignment of core genes using PRANK
         -n        fast core gene alignment with MAFFT, use with -e
         -i        minimum percentage identity for blastp [95]
         -cd FLOAT percentage of isolates a gene must be in to be core [99]
         -qc       generate QC report with Kraken
         -k STR    path to Kraken database for QC, use with -qc
         -a        check dependancies and print versions
         -b STR    blastp executable [blastp]
         -c STR    mcl executable [mcl]
         -d STR    mcxdeblast executable [mcxdeblast]
         -g INT    maximum number of clusters [50000]
         -m STR    makeblastdb executable [makeblastdb]
         -r        create R plots, requires R and ggplot2
         -s        dont split paralogs
         -t INT    translation table [11]
         -z        dont delete intermediate files
         -v        verbose output to STDOUT
         -w        print version and exit
         -y        add gene inference information to spreadsheet, doesnt work with -e
	 -iv STR   Change the MCL inflation value [1.5]
         -h        this help message

Example: Quickly generate a core gene alignment using 8 threads
         roary -e --mafft -p 8 *.gff

For further info see: http://sanger-pathogens.github.io/Roary/
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
