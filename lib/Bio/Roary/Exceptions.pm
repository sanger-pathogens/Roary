package Bio::Roary::Exceptions;
# ABSTRACT: Exceptions for input data 

=head1 SYNOPSIS

Exceptions for input data 

=cut


use Exception::Class (
    Bio::Roary::Exceptions::FileNotFound   => { description => 'Couldnt open the file' },
    Bio::Roary::Exceptions::CouldntWriteToFile   => { description => 'Couldnt open the file for writing' },
    Bio::Roary::Exceptions::LSFJobFailed   => { description => 'Jobs failed' },
);  

1;
