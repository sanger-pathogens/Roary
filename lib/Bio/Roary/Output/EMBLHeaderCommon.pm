package Bio::Roary::Output::EMBLHeaderCommon;

# ABSTRACT: a role containing some common methods for embl header files

=head1 SYNOPSIS

a role containing some common methods for embl header files
   with 'Bio::Roary::Output::EMBLHeaderCommon';

=cut

use Moose::Role;

sub _header_top {
    my ($self) = @_;
    my $header_lines = 'ID   Genome standard; DNA; PRO; 1234 BP.' . "\n";
    $header_lines .= 'XX' . "\n";
    $header_lines .= 'FH   Key             Location/Qualifiers' . "\n";
    $header_lines .= 'FH' . "\n";
    return $header_lines;
}

sub _header_bottom {
    my ($self) = @_;
    my $header_lines = 'XX' . "\n";
    $header_lines .= 'SQ   Sequence 1234 BP; 789 A; 1717 C; 1693 G; 691 T; 0 other;' . "\n";
    $header_lines .= '//' . "\n";
    return $header_lines;
}

sub _annotation_type {
    my ( $self, $annotated_group_name ) = @_;
    my $annotation_type = "   feature         ";
    if ( $annotated_group_name =~ /group_/ ) {
        $annotation_type = "   misc_feature    ";
    }
    return $annotation_type;
}


1;
