package Bio::Roary::ReformatInputGFFs;

# ABSTRACT: Take in gff files and add suffix where a gene id is seen twice

=head1 SYNOPSIS

Take in gff files and add suffix where a gene id is seen twice
   use Bio::Roary::ReformatInputGFFs;
   
   my $obj = Bio::Roary::PrepareInputFiles->new(
     gff_files   => ['abc.gff','ddd.faa'],
   );
   $obj->fix_duplicate_gene_ids;
   $obj->fixed_gff_files;

=cut

use Moose;
use Bio::Roary::Exceptions;
use Cwd;
use File::Copy;
use Log::Log4perl qw(:easy);
use Bio::Tools::GFF;
use File::Path qw(make_path);
use File::Basename;
use Digest::MD5::File qw(file_md5_hex);

has 'gff_files'        => ( is => 'ro', isa  => 'ArrayRef', required => 1 );
has 'logger'           => ( is => 'ro', lazy => 1,          builder  => '_build_logger' );
has '_tags_to_filter'  => ( is => 'ro', isa  => 'Str',      default  => 'CDS' );
has 'output_directory' => ( is => 'ro', isa  => 'Str',      default  => 'fixed_input_files' );
has 'suffix_counter'   => ( is => 'rw', isa  => 'Int',      default  => 1 );

has 'fixed_gff_files' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

sub _build_logger {
    my ($self) = @_;
    Log::Log4perl->easy_init( $ERROR );
    my $logger = get_logger();
    return $logger;
}

sub fix_duplicate_gene_ids {
    my ($self) = @_;

    my %gene_ids_seen_before;
	
	my %file_md5s;
	
    for my $file ( @{ $self->gff_files } ) {
        my $digest = file_md5_hex($file);
		
		if(defined($file_md5s{$digest}))
		{
            $self->logger->warn(
                "Input files have identical MD5 hashes, only using the first file: ".$file_md5s{$digest}." == ".$file
            );
			next;
		}
		else
		{
			$file_md5s{$digest} = $file;
		}
		
        my $ids_seen      = 0;
        my $ids_from_file = $self->_get_ids_for_gff_file($file);

        if ( @{$ids_from_file} < 1 ) {
            $self->logger->error(
                "Input GFF file doesnt contain annotation we can use so excluding it from the analysis: $file"
            );
        }
        else {
            for my $gene_id ( @{$ids_from_file} ) {
                if ( $gene_ids_seen_before{$gene_id} ) {
                    $self->logger->error(
  "Input file contains duplicate gene IDs, attempting to fix by adding a unique suffix, new GFF in the fixed_input_files directory: $file "
                    );
                    my $updated_file = $self->_add_suffix_to_gene_ids_and_return_new_file($file, $digest);
                    push( @{ $self->fixed_gff_files }, $updated_file ) if ( defined($updated_file) );
                    $ids_seen = 1;
                    last;
                }
                $gene_ids_seen_before{$gene_id}++;
            }
			
			# We know its a valid GFF file since we could open it and extract IDs. 
			# We need to make sure the filenames end in .gff. If it contained duplicate IDs, then they are fixed so nothing to do, but 
			# if they didnt, then we have to double check and repair if necessary.			
            if ( $ids_seen == 0 ) {
				
				
                push( @{ $self->fixed_gff_files }, $self->_fix_gff_file_extension($file) );
            }
        }
    }
    return 1;
}

sub _fix_gff_file_extension
{
	my ( $self, $input_file ) = @_;
	
	my ( $filename, $directories, $suffix ) = fileparse( $input_file, qr/\.[^.]*/ );
	return $input_file if($suffix eq '.gff');
	
	
    make_path( $self->output_directory ) if ( !( -d $self->output_directory ) );
    my $output_file = $self->output_directory . '/' . $filename . '.gff';
	copy($input_file, $output_file) or $self->logger->error("Couldnt copy file with invalid gff extention: $input_file -> $output_file");
	return $output_file;
}


sub _add_suffix_to_gene_ids_and_return_new_file {
    my ( $self, $input_file, $digest ) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $input_file, qr/\.[^.]*/ );
    make_path( $self->output_directory ) if ( !( -d $self->output_directory ) );
    my $output_file = $self->output_directory . '/' . $filename . '.gff';

    open( my $input_gff_fh, $input_file );
    open( my $out_gff_fh, '>', $output_file );
 
    # There is a chance that there can be a collision here, but its remote.
	my $random_locus_tag = "".$digest;
	
    $self->logger->warn(
        "Renamed GFF file from: $input_file -> $output_file" );
    $self->logger->warn(
        "Locus tag used is '$random_locus_tag' for file: $input_file" );

    my $found_fasta = 0;
	my $gene_counter = 1;
    while (<$input_gff_fh>) {
        my $line = $_;

        if ( $line =~ /^\#\#FASTA/ ) {
            $found_fasta = 1;
        }

        if ( $line =~ /\#/ || $found_fasta == 1 ) {
            print {$out_gff_fh} $line;
            next;
        }

        my @cells = split( /\t/, $line );
        my @tags  = split( /;/,  $cells[8] );
        my $found_id = 0;
        for ( my $i = 0 ; $i < @tags ; $i++ ) {
            if ( $tags[$i] =~ /^(ID=["']?)([^;"']+)(["']?)/ ) {
                my $current_id = $2;
                $current_id .= '___' . $self->suffix_counter;
                $tags[$i] = $1 .$random_locus_tag.'_'. $gene_counter . $3;
				$gene_counter++;
                $found_id++;
                last;
            }
        }
        if ( $found_id == 0 ) {
            unshift( @tags, 'ID=' . $random_locus_tag.'_'. $gene_counter );
			$gene_counter++;
        }
        $cells[8] = join( ';', @tags );
        print {$out_gff_fh} join( "\t", @cells );
    }

    if ( $found_fasta == 0 ) {
        $self->logger->warn(
            "Input GFF file doesnt appear to have the FASTA sequence at the end of the file so is being excluded from the analysis: $input_file" );
        return undef;
    }
    close($out_gff_fh);
    close($input_gff_fh);
    return $output_file;
}

sub _get_ids_for_gff_file {
    my ( $self, $file ) = @_;
    my @gene_ids;
    my $tags_regex = $self->_tags_to_filter;
    my $gffio = Bio::Tools::GFF->new( -file => $file, -gff_version => 3 );
    while ( my $feature = $gffio->next_feature() ) {
        next if !( $feature->primary_tag =~ /$tags_regex/ );
        my $gene_id = $self->_get_feature_id($feature);
        push( @gene_ids, $gene_id ) if ( defined($gene_id) );
    }
    return \@gene_ids;
}

sub _get_feature_id {
    my ( $self, $feature ) = @_;
    my ( $gene_id, @junk );
    if ( $feature->has_tag('ID') ) {
        ( $gene_id, @junk ) = $feature->get_tag_values('ID');
    }
    elsif ( $feature->has_tag('locus_tag') ) {
        ( $gene_id, @junk ) = $feature->get_tag_values('locus_tag');
    }
    else {
        return undef;
    }
    $gene_id =~ s!["']!!g;
    return undef if ( $gene_id eq "" );
    return $gene_id;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
