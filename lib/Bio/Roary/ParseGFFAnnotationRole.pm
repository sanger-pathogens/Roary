package Bio::Roary::ParseGFFAnnotationRole;

# ABSTRACT: A role for parsing a gff file efficiently

=head1 SYNOPSIS

with 'Bio::Roary::ParseGFFAnnotationRole';

=cut
use Moose::Role;
use Bio::Tools::GFF;

has 'gff_file' => ( is => 'ro', isa => 'Str', required => 1 );

has '_tags_to_filter' => ( is => 'ro', isa => 'Str',             default => '(CDS|ncRNA|tRNA|tmRNA|rRNA)' );
has '_gff_parser'     => ( is => 'ro', isa => 'Bio::Tools::GFF', lazy    => 1, builder => '_build__gff_parser' );
has '_awk_filter'     => ( is => 'ro', isa => 'Str',             lazy    => 1, builder => '_build__awk_filter' );

sub _gff_fh_input_string {
    my ($self) = @_;
    return 'sed -n \'/##gff-version 3/,/^>/p\' '.$self->gff_file.'| grep -v \'^>\''." | " .  $self->_awk_filter;
}

sub _build__awk_filter {
    my ($self) = @_;
    return
        'awk \'BEGIN {FS="\t"};{ if ($3 ~/'
      . $self->_tags_to_filter
      . '/) print $9;}\' ';
}

1;
