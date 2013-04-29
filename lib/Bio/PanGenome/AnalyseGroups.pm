package Bio::PanGenome::AnalyseGroups;

# ABSTRACT: Take in a groups file and the original FASTA files and create plots and stats

=head1 SYNOPSIS

Take in a groups file and the original FASTA files and create plots and stats 
   use Bio::PanGenome::AnalyseGroups;
   
   my $plot_groups_obj = Bio::PanGenome::AnalyseGroups->new(
       fasta_files      => $fasta_files,
       groups_filename  => $groups_filename,
       output_filename  => $output_filename
     );
   $plot_groups_obj->create_plots();

=cut

use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::Plot::FreqOfGenes;

has 'fasta_files'     => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'groups_filename' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'output_filename' => ( is => 'ro', isa => 'Str',      default  => 'summary_of_groups' );

has '_number_of_isolates' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_builder__number_of_isolates' );
has '_number_of_genes_per_file' =>
  ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__number_of_genes_per_file' );
has '_genes_to_file'  => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__genes_to_file' );
has '_files_to_genes' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__files_to_genes' );
has '_freq_groups_per_genome' =>
  ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_builder__freq_groups_per_genome' );
has '_groups_to_genes' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__groups_to_genes' );
has '_genes_to_groups' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__genes_to_groups' );

# Fixme: Same files opened multiple times plus some fragile shelling out

sub _builder__number_of_isolates {
    my ($self) = @_;
    return @{ $self->fasta_files };
}

sub _builder__number_of_genes_per_file {
    my ($self) = @_;

    my %gene_count;
    for my $filename ( @{ $self->fasta_files } ) {

        # Count the number of sequence description lines
        open( my $fh, '-|', 'grep \> ' . $filename . ' | wc -l' );
        my $count = <$fh>;
        chomp($count);
        $count =~ s/^\s*(.*?)\s*$/$1/;
        $gene_count{$filename} = $count;
        close($fh);
    }
    return \%gene_count;
}

sub _freq_dist_of_genes {
    my ($self) = @_;
    my @gene_counts = values %{ $self->_number_of_genes_per_file };
    my %gene_freq;
    for my $gene_count (@gene_counts) {
        $gene_freq{$gene_count}++;
    }
    return \%gene_freq;
}

sub _builder__genes_to_file {
    my ($self) = @_;
    my %genes_to_file;
    for my $filename ( @{ $self->fasta_files } ) {
        open( my $fh, '-|', 'grep \> ' . $filename . ' | awk \'{print $1}\' | sed \'s/>//\' ' );
        while (<$fh>) {
            chomp;
            $genes_to_file{$_} = $filename;
        }
        close($fh);
    }
    return \%genes_to_file;
}

sub _builder__files_to_genes {
    my ($self) = @_;
    my %files_to_genes;
    for my $filename ( @{ $self->fasta_files } ) {
        open( my $fh, '-|', 'grep \> ' . $filename . ' | awk \'{print $1}\' | sed \'s/>//\' ' );
        while (<$fh>) {
            chomp;
            my $gene_name = $_;
            next if($gene_name eq "");
            push( @{ $files_to_genes{$filename} }, $gene_name );
        }
        close($fh);
    }
    return \%files_to_genes;
}

sub _count_num_files_in_group {
    my ( $self, $genes ) = @_;
    my $count = 0;
    my %filename_freq;
    for my $gene ( @{$genes} ) {
        next if ( $gene eq "" );
        if ( defined( $self->_genes_to_file->{$gene} ) ) {
            $filename_freq{ $self->_genes_to_file->{$gene} }++;
        }
    }
    my @uniq_filenames = keys %filename_freq;
    return @uniq_filenames;
}

sub _builder__genes_to_groups {
    my ($self) = @_;
    my %genes_to_groups;

    open( my $fh, $self->groups_filename )
      or Bio::PanGenome::Exceptions::FileNotFound->throw( error => "Group file not found:" . $self->groups_filename );
    while (<$fh>) {
        chomp;
        my $line = $_;
        if ( $line =~ /^(.+): (.+)$/ ) {
            my $group_name = $1;
            my $genes      = $2;
            my @elements   = split( /[\s\t]+/, $genes );

            for my $gene (@elements) {
                $genes_to_groups{$gene} = $group_name;
            }
        }
    }
    return \%genes_to_groups;
}

sub _builder__groups_to_genes {
    my ($self) = @_;
    my %groups_to_genes;

    open( my $fh, $self->groups_filename )
      or Bio::PanGenome::Exceptions::FileNotFound->throw( error => "Group file not found:" . $self->groups_filename );
    while (<$fh>) {
        chomp;
        my $line = $_;
        if ( $line =~ /^(.+): (.+)$/ ) {
            my $group_name = $1;
            my $genes      = $2;
            my @elements   = split( /[\s\t]+/, $genes );
            $groups_to_genes{$group_name} = \@elements;
        }
    }
    return \%groups_to_genes;
}

sub _builder__freq_groups_per_genome {
    my ($self) = @_;
    my @group_count;

    open( my $fh, $self->groups_filename )
      or Bio::PanGenome::Exceptions::FileNotFound->throw( error => "Group file not found:" . $self->groups_filename );
    while (<$fh>) {
        chomp;
        my $line = $_;

        # Remove the group name
        $line =~ s!^(.+: )?!!;
        my @elements = split( /[\s\t]+/, $line );
        my $number_of_files_in_group = $self->_count_num_files_in_group( \@elements );
        $number_of_files_in_group = ( $number_of_files_in_group * 100 / $self->_number_of_isolates );
        push( @group_count, $number_of_files_in_group );

    }
    close($fh);
    my @sorted_group_count = sort { $b <=> $a } @group_count;
    return \@sorted_group_count;
}

sub create_plots {
    my ($self) = @_;

    my $plot_groups_obj =
      Bio::PanGenome::Plot::FreqOfGenes->new( freq_groups_per_genome => $self->_freq_groups_per_genome );
    $plot_groups_obj->create_plot();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

