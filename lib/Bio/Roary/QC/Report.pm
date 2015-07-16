package Bio::Roary::QC::Report;

# ABSTRACT: generate a report based on kraken output

=head1 SYNOPSIS

=cut

use Moose;
use File::Temp;
use File::Path 'rmtree';
use Cwd;
use File::Basename;
with 'Bio::Roary::JobRunner::Role';

has 'input_files'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'kraken_exec'        => ( is => 'ro', isa => 'Str',      default => 'kraken' );
has 'kraken_report_exec' => ( is => 'ro', isa => 'Str',      default => 'kraken-report' );
has 'kraken_db'          => ( is => 'ro', isa => 'Str',      required => 1 );
has 'outfile'            => ( is => 'rw', isa => 'Str',      default => 'qc_report.csv' );
has '_kraken_data'       => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );
has '_header'            => ( is => 'rw', isa => 'Str',      lazy_build => 1 );
has 'kraken_memory'      => ( is => 'rw', isa => 'Int',      default => 2000 );

has '_tmp_directory_obj' => ( is => 'rw', lazy_build => 1 );
has '_tmp_directory'     => ( is => 'rw', lazy_build => 1, isa => 'Str', );


sub _nuc_fasta_filename
{
	my ($self, $gff) = @_;

	my $prefix = basename( $gff, ".gff" );
	my $outfile = $self->_tmp_directory . "/$prefix.fna";
    return  $outfile;
}

sub _extract_nuc_fasta_cmd {
	my ($self, $gff) = @_;
	my $outfile = $self->_nuc_fasta_filename($gff);
	my $cmd = "sed -n '/##FASTA/,//p' $gff | grep -v \'##FASTA\' > $outfile";

	return $cmd;
}

sub _extract_nuc_files_from_all_gffs
{
    my ($self) = @_;
    my @nuc_files;
    my @commands_to_run;
    for my $input_file(@{$self->input_files})
    {
        push(@nuc_files,$self->_nuc_fasta_filename($input_file));
        push(@commands_to_run,$self->_extract_nuc_fasta_cmd($input_file));
    }
	my $kraken_runner_obj = $self->_job_runner_class->new( 
		commands_to_run => \@commands_to_run, 
		memory_in_mb    => $self->kraken_memory,
        verbose         => $self->verbose,
        cpus            => $self->cpus
	);
    $kraken_runner_obj->run();
    return \@nuc_files;
}

sub _kraken_cmd {
	my ( $self, $a, $kraken_output ) = @_;

	my $kcmd = $self->kraken_exec . 
    " --fasta-input ".
	" --preload ".
	" --db " . $self->kraken_db . 
	" --output $kraken_output $a  > /dev/null 2>&1";
	return $kcmd;
}

sub _kraken_report_cmd {
	my ( $self, $k, $report_output ) = @_;

	my $krcmd = $self->kraken_report_exec .
	" --db " . $self->kraken_db .
	" $k > $report_output";
	return $krcmd;
}

sub _kraken_output_filename
{
    my ( $self, $assembly ) = @_;
	my $kraken_output = $assembly;
	$kraken_output =~ s/fna$/kraken/;
    return $kraken_output;
}

sub _run_kraken_on_nuc_files
{
    my ( $self, $nuc_files ) = @_;
    my @kraken_output_files;
    my @commands_to_run;
    for my $nuc_file(@{$nuc_files})
    {
        my $kraken_output = $self->_kraken_output_filename($nuc_file);
        push(@kraken_output_files, $kraken_output );
        push(@commands_to_run, $self->_kraken_cmd( $nuc_file, $kraken_output ));
    }
    
	my $kraken_runner_obj = $self->_job_runner_class->new( 
		commands_to_run => \@commands_to_run, 
		memory_in_mb    => $self->kraken_memory,
        verbose         => $self->verbose,
        cpus            => $self->cpus
	);
    $kraken_runner_obj->run();
    
    for my $filename(@{$nuc_files})
    {
        unlink($filename);
    }
    
    return \@kraken_output_files;
}

sub _kraken_report_output_filename
{
    my ( $self, $assembly ) = @_;
    return $assembly.".report";
}

sub _run_kraken_report_on_kraken_files
{
    my ( $self, $kraken_files ) = @_;
    
    my @kraken_report_output_files;
    my @commands_to_run;
    for my $nuc_file(@{$kraken_files})
    {
        my $kraken_output = $self->_kraken_report_output_filename($nuc_file);
        push(@kraken_report_output_files, $kraken_output );
        push(@commands_to_run, $self->_kraken_report_cmd( $nuc_file, $kraken_output ));
    }
    
	my $kraken_runner_obj = $self->_job_runner_class->new( 
		commands_to_run => \@commands_to_run, 
		memory_in_mb    => $self->kraken_memory,
        verbose         => $self->verbose,
        cpus            => $self->cpus
	);
    $kraken_runner_obj->run();
    for my $filename(@{$kraken_files})
    {
        unlink($filename);
    }
    return \@kraken_report_output_files;
}

sub _build__kraken_data {
	my $self = shift;
    my $nuc_files = $self->_extract_nuc_files_from_all_gffs();
    my $kraken_files = $self->_run_kraken_on_nuc_files($nuc_files);
    my $kraken_report_files = $self->_run_kraken_report_on_kraken_files( $kraken_files );
    
	return $self->_parse_kraken_reports($kraken_report_files);
}

sub _parse_kraken_reports
{
    my ( $self, $kraken_report_files ) = @_;
    
    my @report_rows;
    for my $kraken_report(@{$kraken_report_files})
    {
        push(@report_rows, $self->_parse_kraken_report($kraken_report));
    }
    
    for my $kraken_report(@{$kraken_report_files})
    {
        unlink($kraken_report);
    }   
    
    return \@report_rows;
}

sub _parse_kraken_report {
	my ( $self, $kraken_report ) = @_;

	# parse report
	open( my $report_fh, '<', $kraken_report );
    
    my $sample_name = $kraken_report;
    $sample_name =~ s/.report$//;
    $sample_name =~ s/.kraken$//;
    my($sample_base_name, $dirs, $suffix) = fileparse($sample_name);
    
	my ( $top_genus, $top_species );
	while ( <$report_fh> ){
		my @parts = split( "\t" );
		chomp @parts;

		$top_genus = $parts[5] if ( (! defined $top_genus) && $parts[3] eq 'G' );
		$top_species = $parts[5] if ( (! defined $top_species) && $parts[3] eq 'S' );

		last if (defined $top_genus && defined $top_species);
	}
    close($report_fh);

	$top_genus   ||= "not_found";
	$top_genus   =~ s/^\s+//g;
	$top_species ||= "not_found";
	$top_species =~ s/^\s+//g;

	return [ $sample_base_name, $top_genus, $top_species ];
}


sub _build__header {
	return join( ',', ( 'Sample', 'Genus', 'Species' ) );
}

sub _build__tmp_directory_obj {
	return File::Temp->newdir(DIR => getcwd, CLEANUP => 1 ); 
}

sub _build__tmp_directory {
	my $self = shift;
	return $self->_tmp_directory_obj->dirname();
}

sub report {
	my $self = shift;

	open( OUTFILE, '>', $self->outfile );
	print OUTFILE $self->_header . "\n";
	for my $line ( @{ $self->_kraken_data } ){
		print OUTFILE join( ',', @{ $line } ) . "\n";
	}
	close OUTFILE;
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
