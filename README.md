# Roary - The pan genome pipeline
Takes annotated assemblies in GFF3 format and calculates the pan genome.

PLEASE NOTE: we currently do not have the resources to provide support for Roary, so please do not expect a reply if you flag any issue.

[![Unmaintained](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)   
[![Build Status](https://travis-ci.org/sanger-pathogens/Roary.svg?branch=master)](https://travis-ci.org/sanger-pathogens/Roary)   
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-brightgreen.svg)](https://github.com/sanger-pathogens/roary/blob/master/GPL-LICENSE)   
[![status](https://img.shields.io/badge/Bioinformatics-10.1093-brightgreen.svg)](https://academic.oup.com/bioinformatics/article/31/22/3691/240757)  
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg)](http://bioconda.github.io/recipes/roary/README.html)  
[![Container ready](https://img.shields.io/badge/container-ready-brightgreen.svg)](https://quay.io/repository/biocontainers/roary)  
[![Docker Build Status](https://img.shields.io/docker/build/sangerpathogens/roary.svg)](https://hub.docker.com/r/sangerpathogens/roary)  
[![Docker Pulls](https://img.shields.io/docker/pulls/sangerpathogens/roary.svg)](https://hub.docker.com/r/sangerpathogens/roary)  
[![codecov](https://codecov.io/gh/sanger-pathogens/roary/branch/master/graph/badge.svg)](https://codecov.io/gh/sanger-pathogens/roary)

## Contents
  * [Introduction](#introduction)
  * [Installation](#installation)
    * [Required dependencies](#required-dependencies)
    * [Optional dependencies](#optional-dependencies)
    * [Ubuntu/Debian](#ubuntudebian)
      * [Debian Testing](#debian-testing)
      * [Ubuntu 14\.04/16\.04](#ubuntu-14041604)
      * [Ubuntu 12\.04](#ubuntu-1204)
    * [Bioconda \- OSX/Linux](#bioconda---osxlinux)
    * [Galaxy](#galaxy)
    * [GNU Guix](#gnu-guix)
    * [Virtual Machine \- OSX/Linux/Windows](#virtual-machine---osxlinuxwindows)
    * [Docker \- OSX/Linux/Windows/Cloud](#docker---osxlinuxwindowscloud)
    * [Installing from source (advanced Linux users only)](#installing-from-source-advanced-linux-users-only)
    * [Ancient systems and versions of perl](#ancient-systems-and-versions-of-perl)
    * [Running the tests](#running-the-tests)
    * [Versions of software we test against](#versions-of-software-we-test-against)
  * [Usage](#usage)
  * [License](#license)
  * [Feedback/Issues](#feedbackissues)
  * [Citation](#citation)
  * [Further Information](#further-information)

## Introduction
Roary is a high speed stand alone pan genome pipeline, which takes annotated assemblies in GFF3 format (produced by Prokka) and calculates the pan genome.  Using a standard desktop PC, it can analyse datasets with thousands of samples, something which is computationally infeasible with existing methods, without compromising the quality of the results.  128 samples can be analysed in under 1 hour using 1 GB of RAM and a single processor. To perform this analysis using existing methods would take weeks and hundreds of GB of RAM.

## Installation
Roary has the following dependencies:

### Required dependencies
* [bedtools](https://bedtools.readthedocs.io/en/latest/)
* [cd-hit](http://weizhongli-lab.org/cd-hit/)
* [ncbi-blast+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download)
* [mcl](https://micans.org/mcl/)
* [parallel](https://www.gnu.org/software/parallel/)
* [prank](http://wasabiapp.org/software/prank/)
* [mafft](https://mafft.cbrc.jp/alignment/software/)
* [fasttree](http://www.microbesonline.org/fasttree/)

### Optional dependencies
* [kraken](http://ccb.jhu.edu/software/kraken/MANUAL.html)

There are a number of ways to install Roary and details are provided below. If you encounter an issue when installing Roary please contact your local system administrator.

### Ubuntu/Debian
#### Debian Testing
```
sudo apt-get install roary
```

#### Ubuntu 14.04/16.04
All the dependancies can be installed using apt and cpanm. Root permissions are required. Ubuntu 16.04 contains a package for Roary but it is frozen at v3.6.0.

```
sudo apt-get install bedtools cd-hit ncbi-blast+ mcl parallel cpanminus prank mafft fasttree
sudo cpanm -f Bio::Roary
```

#### Ubuntu 12.04
Some of the software versions in apt are quite old so follow the instructions for Bioconda below.

### Bioconda - OSX/Linux
Install conda. Then install bioconda and roary:

```
conda config --add channels r
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda
conda install roary
```

### Galaxy
Roary is available from the Galaxy toolshed (as is Prokka).

### GNU Guix
Roary is included in [Guix](https://www.gnu.org/software/guix) and can be installed in the usual way:
```
guix package --install roary
```

### Virtual Machine - OSX/Linux/Windows
Roary wont run natively on Windows but we have created virtual machine which has all of the software setup, including Prokka, along with the test datasets from the paper. It is based on [Bio-Linux 8](http://environmentalomics.org/bio-linux/).  You need to first install [VirtualBox](https://www.virtualbox.org/), then load the virtual machine, using the 'File -> Import Appliance' menu option. The root password is 'manager'.

ftp://ftp.sanger.ac.uk/pub/pathogens/pathogens-vm/pathogens-vm.latest.ova

More importantly though, if you're trying to do bioinformatics on Windows, you're not going to get very far and you should seriously consider upgrading to Linux.

### Docker - OSX/Linux/Windows/Cloud
We have a docker container which gets automatically built from the latest version of Roary in Debian Med. To install it:

```
docker pull sangerpathogens/roary
```

To use it you would use a command such as this (substituting in your directories), where your GFF files are assumed to be stored in /home/ubuntu/data:
```
docker run --rm -it -v /home/ubuntu/data:/data sangerpathogens/roary roary -f /data /data/*.gff
```

### Installing from source (advanced Linux users only)
As a last resort you can install everything from source. This is for users with advanced Linux skills and we do not provide any support with this method since you have the skills to figure things out.
Download the latest software from (https://github.com/sanger-pathogens/Roary/tarball/master).

Choose somewhere to put it, for example in your home directory (no root access required):

```
cd $HOME
tar zxvf sanger-pathogens-Roary-xxxxxx.tar.gz
ls Roary-*
```

Add the following lines to your $HOME/.bashrc file, or to /etc/profile.d/roary.sh to make it available to all users:

```
export PATH=$PATH:$HOME/Roary-x.x.x/bin
export PERL5LIB=$PERL5LIB:$HOME/Roary-x.x.x/lib
```
Install the Perl dependencies:

```
sudo cpanm  Array::Utils Bio::Perl Exception::Class File::Basename File::Copy File::Find::Rule File::Grep File::Path File::Slurper File::Spec File::Temp File::Which FindBin Getopt::Long Graph Graph::Writer::Dot List::Util Log::Log4perl Moose Moose::Role Text::CSV PerlIO::utf8_strict Devel::OverloadInfo Digest::MD5::File
```
Install the external dependances either from source or from your packaging system:
```
bedtools cd-hit blast mcl GNUparallel prank mafft fasttree
```

### Ancient systems and versions of perl
The code will not work with perl 5.8 or below (pre-modern perl). We no longer test against 5.10 (released 2007) or 5.12 (released 2010). If you're running a very old verison of Linux, you're also in trouble.

### Running the tests
The test can be run with dzil from the top level directory:  

```
dzil test
```

### Versions of software we test against
* Perl 5.14, 5.26
* cdhit 4.6.8
* ncbi blast+ 2.6.0
* mcl 14-137
* bedtools 2.27.1
* prank 140603
* GNU parallel 20170822, 20160722
* FastTree 2.1.9

## Usage
```
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
         -ap       allow paralogs in core alignment
         -z        dont delete intermediate files
         -v        verbose output to STDOUT
         -w        print version and exit
         -y        add gene inference information to spreadsheet, doesnt work with -e
         -iv STR   Change the MCL inflation value [1.5]
         -h        this help message

Example: Quickly generate a core gene alignment using 8 threads
         roary -e --mafft -p 8 *.gff

For further info see: http://sanger-pathogens.github.io/Roary/
```
For further instructions on how to use the software, the input format and output formats, please see [the Roary website](http://sanger-pathogens.github.io/Roary).

## License
Roary is free software, licensed under [GPLv3](https://github.com/sanger-pathogens/Roary/blob/master/GPL-LICENSE).

## Feedback/Issues
We currently do not have the resources to provide support for Roary. However, the community might be able to help you out if you report any issues about usage of the software to the [issues page](https://github.com/sanger-pathogens/Roary/issues).

## Citation
If you use this software please cite:

    "Roary: Rapid large-scale prokaryote pan genome analysis",
    Andrew J. Page, Carla A. Cummins, Martin Hunt, Vanessa K. Wong, Sandra Reuter, Matthew T. G. Holden, Maria Fookes, Daniel Falush, Jacqueline A. Keane, Julian Parkhill,
    Bioinformatics, (2015). doi: http://dx.doi.org/10.1093/bioinformatics/btv421
[Roary: Rapid large-scale prokaryote pan genome analysis](http://dx.doi.org/10.1093/bioinformatics/btv421)

## Further Information
For more information on this software see:
* [The Roary website](http://sanger-pathogens.github.io/Roary)
* [The Jupyter notebook tutorial](https://github.com/sanger-pathogens/pathogen-informatics-training)
