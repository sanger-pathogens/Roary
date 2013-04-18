package Bio::PanGenome::Exceptions;
# ABSTRACT: Exceptions for input data 

=head1 SYNOPSIS

Exceptions for input data 

=cut


use Exception::Class (
    Bio::PanGenome::Exceptions::FileNotFound   => { description => 'Couldnt open the file' },
    Bio::PanGenome::Exceptions::CouldntWriteToFile   => { description => 'Couldnt open the file for writing' },
);  

1;
