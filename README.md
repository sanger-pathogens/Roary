#Website
(http://sanger-pathogens.github.io/Roary)

#Roary the pan genome pipeline

Roary is a high speed stand alone pan genome pipeline, which takes annotated assemblies in GFF3 format (produced by Prokka) and calculates the pan genome.  Using a standard desktop PC, it can analyse datasets with thousands of samples, something which is computationally infeasible with existing methods, without compromising the quality of the results.  128 samples can be analysed in under 1 hour using 1 GB of RAM and a single processor. To perform this analysis using existing methods would take weeks and hundreds of GB of RAM.

##Input
Roary takes annotated assemblies as input in GFF3 format, such as those produced by [Prokka](http://www.vicbioinformatics.com/software.prokka.shtml).


##Installation - Ubuntu/Debian
Assuming you have root on your system, all the dependancies can be installed using apt and cpanm.

   `sudo apt-get install bedtools cd-hit ncbi-blast+ mcl muscle parallel cpanminus`
   
   `sudo cpanm Bio::Roary`
   

##Installation - OSX using homebrew
Assuming you have homebrew setup and installed on your OSX system, tap the science keg and install the dependancies, then install the perl modules:

   `brew tap homebrew/science`
   
   `brew install bedtools cd-hit blast mcl muscle parallel`
   
   `cpanm Bio::Roary`


##Installation - With bundled binaries

###Download
Download the latest software from 
https://github.com/sanger-pathogens/Roary/archive/v2.0.0.tar.gz

###Extract
Choose somewhere to put it, for example in your home directory (no root access required):

  `cd $HOME`
  `tar zxvf v2.0.0.tar.gz`
  `ls Roary-*`

###Add to your Environment

Add the following lines to your $HOME/.bashrc file, or to /etc/profile.d/roary.sh to make it available to all users:

   `export PATH=$PATH:$HOME/Roary-x.x.x/bin`
   `export PERL5LIB=$PERL5LIB:$HOME/Roary-x.x.x/lib`

###Install perl dependancies
   `cpanm Array::Utils BioPerl Exception::Class File::Find::Rule File::Grep File::Slurp::Tiny Graph Moose Moose::Role Text::CSV`
   
