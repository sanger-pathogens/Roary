Bio-PanGenome
=============

The algorithm works as follows:

1.) Extract protein sequences for each CDS from GFF files, reorienting to positive strand,
2.) Create a combined protein sequence, filtering out proteins with more than 5% missing data (assembly errors),
3.) Cluster sequences with 99% identity and 99% length with cd-hit,
4.) Parallel all-against-all blastp with clustered sequences,
5.) TribeMCL,
6.) Reinflate MCL groups with cd-hit clusters,
7.) Transfer annotation to the groups (gene names),

Outputs:
1.) Plot of group frequency in isolates so you can visually see core and accessory
2.) Spreadsheet with statistics on groups, annotation, etc...
3.) FASTA file with a single representative sequence per group

Querying the data:
1.) Given two sets of isolates, output the genes unique to each set, and the set of common genes (3 files).
2.) Given a set of isolates, output the union, intersection or complement.
3.) Given a list of genes, create multifasta files for each gene from all isolates



Dependancies
============
BedTools
gsed
RevTrans - http://www.cbs.dtu.dk/services/RevTrans/download.php