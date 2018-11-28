# Change Log

## [Unreleased](https://github.com/sanger-pathogens/Roary/tree/HEAD)

[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.12.0...HEAD)

**Implemented enhancements:**

- Feature Request: Clear error message for duplicated file names [\#363](https://github.com/sanger-pathogens/Roary/issues/363)

**Fixed bugs:**

- uninitialized value warning [\#297](https://github.com/sanger-pathogens/Roary/issues/297)
- Bio::Root::Exception thrown during core genome alignment, missing some sequence in core\_gene\_alignment.aln [\#224](https://github.com/sanger-pathogens/Roary/issues/224)

**Closed issues:**

- Interpretation accessory\_binary\_genes newick [\#429](https://github.com/sanger-pathogens/Roary/issues/429)
- No gene annotation in gene\_presence\_absence.csv output   [\#428](https://github.com/sanger-pathogens/Roary/issues/428)
- Compilation aborted at pan\_genome\_post\_analysis [\#427](https://github.com/sanger-pathogens/Roary/issues/427)
- Could not obtain pan\_genome\_sequences [\#426](https://github.com/sanger-pathogens/Roary/issues/426)
- Pan genome for fungal genomes [\#425](https://github.com/sanger-pathogens/Roary/issues/425)
- multifasta for all proteins [\#424](https://github.com/sanger-pathogens/Roary/issues/424)
- roary\_plots.py KeyError: "X" not in index [\#423](https://github.com/sanger-pathogens/Roary/issues/423)
- Confirm that use of BLAST's `-max\_target\_seqs` is intentional [\#422](https://github.com/sanger-pathogens/Roary/issues/422)
- query\_pan\_genome 'Cant access file' error \(Non-Working-Directory inputs\) [\#421](https://github.com/sanger-pathogens/Roary/issues/421)
- How many .gff files does Roary need? [\#419](https://github.com/sanger-pathogens/Roary/issues/419)
- Installation through Bioconda not working [\#418](https://github.com/sanger-pathogens/Roary/issues/418)
- Is it possible to run roary without prokka output files? [\#417](https://github.com/sanger-pathogens/Roary/issues/417)
- Exiting early because number of clusters is too high [\#415](https://github.com/sanger-pathogens/Roary/issues/415)
- MSG: Got a sequence without letters. Could not guess alphabet? [\#414](https://github.com/sanger-pathogens/Roary/issues/414)
- Which is the advantage to pre-use prokka to perform analysis using genbank \(.gbk and gbff\) files? [\#412](https://github.com/sanger-pathogens/Roary/issues/412)
- issues with running and empty files [\#411](https://github.com/sanger-pathogens/Roary/issues/411)
- MSG: Got a sequence without letters. Could not guess alphabet [\#410](https://github.com/sanger-pathogens/Roary/issues/410)
- moose.pm issue [\#407](https://github.com/sanger-pathogens/Roary/issues/407)
- Tutorial data: extract\_proteome\_from\_gff  [\#406](https://github.com/sanger-pathogens/Roary/issues/406)
- Tutorial data: extract\_proteome\_from\_gff [\#403](https://github.com/sanger-pathogens/Roary/issues/403)
- gene\_presence\_absence.csv incomplete [\#402](https://github.com/sanger-pathogens/Roary/issues/402)
- Roary including non-protein coding features? [\#398](https://github.com/sanger-pathogens/Roary/issues/398)
- Question: what programs can be used to visualize embl and dot files? [\#394](https://github.com/sanger-pathogens/Roary/issues/394)
- Roary Does not terminated successfully  [\#388](https://github.com/sanger-pathogens/Roary/issues/388)
- python: can't open file 'roary\_plots.py': \[Errno 2\] No such file or directory [\#385](https://github.com/sanger-pathogens/Roary/issues/385)
- Roary does not finish analysis even though cluster job queue returns successful completion [\#383](https://github.com/sanger-pathogens/Roary/issues/383)
- Genes \(well\) annotated in prokka end up all in different groups?? [\#355](https://github.com/sanger-pathogens/Roary/issues/355)
- could not determine version of cd-hit [\#322](https://github.com/sanger-pathogens/Roary/issues/322)
- Use of uninitialized value in require at \(eval 792\) line 1. [\#308](https://github.com/sanger-pathogens/Roary/issues/308)
- Error: unexpected input in "\_" [\#299](https://github.com/sanger-pathogens/Roary/issues/299)
- inconsistent referencing of $TMPDIR ? [\#287](https://github.com/sanger-pathogens/Roary/issues/287)

**Merged pull requests:**

- Include tests in README [\#430](https://github.com/sanger-pathogens/Roary/pull/430) ([ssjunnebo](https://github.com/ssjunnebo))
- 621556 badges [\#420](https://github.com/sanger-pathogens/Roary/pull/420) ([ssjunnebo](https://github.com/ssjunnebo))
- Update roary\_plots from .ix to .loc [\#416](https://github.com/sanger-pathogens/Roary/pull/416) ([EvdH0](https://github.com/EvdH0))
- Use only CDS features from GFF [\#400](https://github.com/sanger-pathogens/Roary/pull/400) ([embatty](https://github.com/embatty))
- also mention Devel::OverloadInfo and Digest::MD5::File as required Perl dependencies [\#397](https://github.com/sanger-pathogens/Roary/pull/397) ([boegel](https://github.com/boegel))
- Avoid deprecation errors in roary\_plots [\#389](https://github.com/sanger-pathogens/Roary/pull/389) ([mgalardini](https://github.com/mgalardini))

## [v3.12.0](https://github.com/sanger-pathogens/Roary/tree/v3.12.0) (2018-01-23)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.11.4...v3.12.0)

**Merged pull requests:**

- Reduce min gene size [\#384](https://github.com/sanger-pathogens/Roary/pull/384) ([ssjunnebo](https://github.com/ssjunnebo))

## [v3.11.4](https://github.com/sanger-pathogens/Roary/tree/v3.11.4) (2018-01-16)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.11.3...v3.11.4)

**Closed issues:**

- Roary seemed to have stopped prematurely; any way to continue the run? [\#380](https://github.com/sanger-pathogens/Roary/issues/380)
- Getting prank version without the online check [\#377](https://github.com/sanger-pathogens/Roary/issues/377)
- Kraken version parsing error: [\#376](https://github.com/sanger-pathogens/Roary/issues/376)
- 3.11.1 failing 2/55 \(3/791\) tests  [\#375](https://github.com/sanger-pathogens/Roary/issues/375)
- Fix for prank version check [\#361](https://github.com/sanger-pathogens/Roary/issues/361)
- mafft version check still failing - bug in regexp found [\#360](https://github.com/sanger-pathogens/Roary/issues/360)
- roary -a  =\> Use of uninitialized value in concatenation \(.\) [\#270](https://github.com/sanger-pathogens/Roary/issues/270)

**Merged pull requests:**

- Fix dependancy checking option [\#382](https://github.com/sanger-pathogens/Roary/pull/382) ([andrewjpage](https://github.com/andrewjpage))

## [v3.11.3](https://github.com/sanger-pathogens/Roary/tree/v3.11.3) (2018-01-12)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.11.2...v3.11.3)

**Merged pull requests:**

- Version fix [\#379](https://github.com/sanger-pathogens/Roary/pull/379) ([andrewjpage](https://github.com/andrewjpage))

## [v3.11.2](https://github.com/sanger-pathogens/Roary/tree/v3.11.2) (2018-01-12)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.11.1...v3.11.2)

**Fixed bugs:**

- ExtractProteomeFromGff.t failing tests 3.11.0 [\#373](https://github.com/sanger-pathogens/Roary/issues/373)

**Merged pull requests:**

- fix mafft and kraken version extraction [\#378](https://github.com/sanger-pathogens/Roary/pull/378) ([andrewjpage](https://github.com/andrewjpage))

## [v3.11.1](https://github.com/sanger-pathogens/Roary/tree/v3.11.1) (2018-01-10)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.11.0...v3.11.1)

**Closed issues:**

- Sorting in version 3.11.0: uppercase letters first, lowercase second \(non-alphabetical\) [\#371](https://github.com/sanger-pathogens/Roary/issues/371)
- Genbank input [\#365](https://github.com/sanger-pathogens/Roary/issues/365)
- not all annotated features are allocated to the clusters [\#359](https://github.com/sanger-pathogens/Roary/issues/359)

**Merged pull requests:**

- Bedtools getfasta format fix [\#374](https://github.com/sanger-pathogens/Roary/pull/374) ([andrewjpage](https://github.com/andrewjpage))
- Update roary\_plots.py [\#372](https://github.com/sanger-pathogens/Roary/pull/372) ([franz89](https://github.com/franz89))
- Issue \#363 add check for duplicate basenames [\#370](https://github.com/sanger-pathogens/Roary/pull/370) ([nickp60](https://github.com/nickp60))
- README.md: Update Guix install instructions. [\#362](https://github.com/sanger-pathogens/Roary/pull/362) ([wwood](https://github.com/wwood))

## [v3.11.0](https://github.com/sanger-pathogens/Roary/tree/v3.11.0) (2017-10-10)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.10.2...v3.11.0)

**Fixed bugs:**

- Can't get version of kraken, kraken-report or mafft ? [\#312](https://github.com/sanger-pathogens/Roary/issues/312)

**Closed issues:**

- number\_of\_conserved\_genes.Rtab [\#354](https://github.com/sanger-pathogens/Roary/issues/354)
- \[question\] Should it take this long? [\#352](https://github.com/sanger-pathogens/Roary/issues/352)

**Merged pull requests:**

- change missing gene in core to be dashes rather than Ns [\#358](https://github.com/sanger-pathogens/Roary/pull/358) ([andrewjpage](https://github.com/andrewjpage))

## [v3.10.2](https://github.com/sanger-pathogens/Roary/tree/v3.10.2) (2017-09-08)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.10.1...v3.10.2)

**Closed issues:**

- \[version 3.8.0\] Roary crashes at end on perl error message [\#323](https://github.com/sanger-pathogens/Roary/issues/323)
-  Cant open file: \_accessory\_clusters.clstr [\#320](https://github.com/sanger-pathogens/Roary/issues/320)

**Merged pull requests:**

- get kraken version [\#351](https://github.com/sanger-pathogens/Roary/pull/351) ([andrewjpage](https://github.com/andrewjpage))

## [v3.10.1](https://github.com/sanger-pathogens/Roary/tree/v3.10.1) (2017-09-07)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.10.0...v3.10.1)

**Implemented enhancements:**

- Auto-detect if input files are GFF or FASTA [\#348](https://github.com/sanger-pathogens/Roary/issues/348)
- Can "Fixing input GFF files" be parallelized? [\#342](https://github.com/sanger-pathogens/Roary/issues/342)

**Fixed bugs:**

- The GNU General Public License, Version not specified [\#344](https://github.com/sanger-pathogens/Roary/issues/344)

**Closed issues:**

- MSG: The sequence does not appear to be FASTA format \(lacks a descriptor line '\>'\) [\#346](https://github.com/sanger-pathogens/Roary/issues/346)

**Merged pull requests:**

- Improve input file handling [\#350](https://github.com/sanger-pathogens/Roary/pull/350) ([andrewjpage](https://github.com/andrewjpage))

## [v3.10.0](https://github.com/sanger-pathogens/Roary/tree/v3.10.0) (2017-09-07)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.9.1...v3.10.0)

**Closed issues:**

- Use of uninitialized value \(Perl\) [\#345](https://github.com/sanger-pathogens/Roary/issues/345)
- identical .gff file names from different genome, and then issue with mcl groups [\#341](https://github.com/sanger-pathogens/Roary/issues/341)
- Cant open file: \_clustered.clstr [\#339](https://github.com/sanger-pathogens/Roary/issues/339)

## [v3.9.1](https://github.com/sanger-pathogens/Roary/tree/v3.9.1) (2017-08-22)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.9.0...v3.9.1)

**Merged pull requests:**

- Optionally allow paralogs in core gene alignment [\#343](https://github.com/sanger-pathogens/Roary/pull/343) ([andrewjpage](https://github.com/andrewjpage))
- Script to find frequency of unique genes in samples [\#340](https://github.com/sanger-pathogens/Roary/pull/340) ([andrewjpage](https://github.com/andrewjpage))

## [v3.9.0](https://github.com/sanger-pathogens/Roary/tree/v3.9.0) (2017-08-09)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.8.2...v3.9.0)

**Closed issues:**

- roary\_plots: pangenome matrix tree does not look like input.newick tree [\#333](https://github.com/sanger-pathogens/Roary/issues/333)
- use Roary with RAST files [\#332](https://github.com/sanger-pathogens/Roary/issues/332)
- Roary  [\#329](https://github.com/sanger-pathogens/Roary/issues/329)
- sampling number is 10 in number of genes in pan and core genome [\#319](https://github.com/sanger-pathogens/Roary/issues/319)

**Merged pull requests:**

- Grammar edits [\#327](https://github.com/sanger-pathogens/Roary/pull/327) ([cgreene](https://github.com/cgreene))
- allow for inflation factor for MCL to be changed [\#326](https://github.com/sanger-pathogens/Roary/pull/326) ([andrewjpage](https://github.com/andrewjpage))

## [v3.8.2](https://github.com/sanger-pathogens/Roary/tree/v3.8.2) (2017-05-21)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.8.1...v3.8.2)

## [v3.8.1](https://github.com/sanger-pathogens/Roary/tree/v3.8.1) (2017-05-21)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.8.0...v3.8.1)

**Closed issues:**

- BLAST Database error [\#321](https://github.com/sanger-pathogens/Roary/issues/321)
- Results for same input differ always a bit \(summary\_statistics.txt\) [\#318](https://github.com/sanger-pathogens/Roary/issues/318)
- Error: Couldnt open GFF file [\#314](https://github.com/sanger-pathogens/Roary/issues/314)
- Help with query\_pan\_genome [\#313](https://github.com/sanger-pathogens/Roary/issues/313)

**Merged pull requests:**

- update email address [\#325](https://github.com/sanger-pathogens/Roary/pull/325) ([ssjunnebo](https://github.com/ssjunnebo))
- New option to roary\_plots.py [\#317](https://github.com/sanger-pathogens/Roary/pull/317) ([mgalardini](https://github.com/mgalardini))

## [v3.8.0](https://github.com/sanger-pathogens/Roary/tree/v3.8.0) (2017-01-25)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.7.1...v3.8.0)

**Closed issues:**

- Old version in the master tarball? [\#300](https://github.com/sanger-pathogens/Roary/issues/300)
- prank is not installed \(Linuxbrew\) [\#294](https://github.com/sanger-pathogens/Roary/issues/294)
- roary\_plots.py problem [\#292](https://github.com/sanger-pathogens/Roary/issues/292)

**Merged pull requests:**

- Support latest version of blast [\#306](https://github.com/sanger-pathogens/Roary/pull/306) ([andrewjpage](https://github.com/andrewjpage))
- infgen [\#305](https://github.com/sanger-pathogens/Roary/pull/305) ([andrewjpage](https://github.com/andrewjpage))
- update from 108 to 118 [\#304](https://github.com/sanger-pathogens/Roary/pull/304) ([andrewjpage](https://github.com/andrewjpage))
- update usage text for iterative CD-hit [\#301](https://github.com/sanger-pathogens/Roary/pull/301) ([andrewjpage](https://github.com/andrewjpage))

## [v3.7.1](https://github.com/sanger-pathogens/Roary/tree/v3.7.1) (2016-11-01)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.7.0...v3.7.1)

**Closed issues:**

- core\_gene\_alignment.aln missing [\#284](https://github.com/sanger-pathogens/Roary/issues/284)
- Is these results fine to use? [\#282](https://github.com/sanger-pathogens/Roary/issues/282)

**Merged pull requests:**

- fix spelling [\#280](https://github.com/sanger-pathogens/Roary/pull/280) ([satta](https://github.com/satta))
- dont add POD to end of R scripts [\#279](https://github.com/sanger-pathogens/Roary/pull/279) ([andrewjpage](https://github.com/andrewjpage))

## [v3.7.0](https://github.com/sanger-pathogens/Roary/tree/v3.7.0) (2016-09-23)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.9...v3.7.0)

## [v3.6.9](https://github.com/sanger-pathogens/Roary/tree/v3.6.9) (2016-09-22)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.8...v3.6.9)

**Implemented enhancements:**

- I have published a Roary homebrew formula [\#208](https://github.com/sanger-pathogens/Roary/issues/208)
- Getting Roary into Homebrew [\#152](https://github.com/sanger-pathogens/Roary/issues/152)

**Closed issues:**

- roary\_plots.py missing  [\#277](https://github.com/sanger-pathogens/Roary/issues/277)
- Errors when downloaded sequences from NCBI [\#274](https://github.com/sanger-pathogens/Roary/issues/274)
- Same dataset different results! [\#271](https://github.com/sanger-pathogens/Roary/issues/271)
- \_clustered.clstr file does not exist, cannot be read [\#250](https://github.com/sanger-pathogens/Roary/issues/250)

**Merged pull requests:**

- Fixed easy-init warnings - 529655 [\#278](https://github.com/sanger-pathogens/Roary/pull/278) ([psweston](https://github.com/psweston))
- README.md: Add instructions for GNU Guix. [\#273](https://github.com/sanger-pathogens/Roary/pull/273) ([wwood](https://github.com/wwood))

## [v3.6.8](https://github.com/sanger-pathogens/Roary/tree/v3.6.8) (2016-08-02)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.7...v3.6.8)

**Merged pull requests:**

- Allow gene names from gb [\#266](https://github.com/sanger-pathogens/Roary/pull/266) ([andrewjpage](https://github.com/andrewjpage))
- Missing genes [\#265](https://github.com/sanger-pathogens/Roary/pull/265) ([andrewjpage](https://github.com/andrewjpage))

## [v3.6.7](https://github.com/sanger-pathogens/Roary/tree/v3.6.7) (2016-07-26)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.6...v3.6.7)

**Fixed bugs:**

- Roary 3.6.5 giving different \(erroneous\) results compared to 3.5.7 and 3.6.1/3.6.3/3.6.4 [\#263](https://github.com/sanger-pathogens/Roary/issues/263)
- roary R plots don't work on server --- lack of X11 [\#194](https://github.com/sanger-pathogens/Roary/issues/194)

**Closed issues:**

- empty accessory\_binary\_genes.fa file [\#262](https://github.com/sanger-pathogens/Roary/issues/262)
- a guix package [\#259](https://github.com/sanger-pathogens/Roary/issues/259)
- create\_pan\_genome\_plots.R - X11 font problem [\#230](https://github.com/sanger-pathogens/Roary/issues/230)
- Roary not generating pan\_genome\_reference.fa [\#223](https://github.com/sanger-pathogens/Roary/issues/223)
- Roary not using packaged executables [\#215](https://github.com/sanger-pathogens/Roary/issues/215)

## [v3.6.6](https://github.com/sanger-pathogens/Roary/tree/v3.6.6) (2016-07-25)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.5...v3.6.6)

**Fixed bugs:**

- GFF parsing doesn't match GFF3 specification [\#249](https://github.com/sanger-pathogens/Roary/issues/249)

**Merged pull requests:**

- Fix empty accessory binary [\#264](https://github.com/sanger-pathogens/Roary/pull/264) ([andrewjpage](https://github.com/andrewjpage))
- change to dist zilla starter bundle [\#261](https://github.com/sanger-pathogens/Roary/pull/261) ([nds](https://github.com/nds))

## [v3.6.5](https://github.com/sanger-pathogens/Roary/tree/v3.6.5) (2016-07-20)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.4...v3.6.5)

**Merged pull requests:**

- allow new format bedtools and dont look for FASTA in GFF [\#260](https://github.com/sanger-pathogens/Roary/pull/260) ([andrewjpage](https://github.com/andrewjpage))
- catch divide  by zero error [\#258](https://github.com/sanger-pathogens/Roary/pull/258) ([andrewjpage](https://github.com/andrewjpage))

## [v3.6.4](https://github.com/sanger-pathogens/Roary/tree/v3.6.4) (2016-07-06)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.3...v3.6.4)

**Merged pull requests:**

- drop testing for perl 5.10, add 5.24. dzil no longer works below 5.14 [\#257](https://github.com/sanger-pathogens/Roary/pull/257) ([andrewjpage](https://github.com/andrewjpage))

## [v3.6.3](https://github.com/sanger-pathogens/Roary/tree/v3.6.3) (2016-07-01)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.2...v3.6.3)

**Merged pull requests:**

- Speed up alignments [\#256](https://github.com/sanger-pathogens/Roary/pull/256) ([andrewjpage](https://github.com/andrewjpage))

## [v3.6.2](https://github.com/sanger-pathogens/Roary/tree/v3.6.2) (2016-05-10)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.1...v3.6.2)

**Implemented enhancements:**

- Prefix utility commands with roary- ? [\#226](https://github.com/sanger-pathogens/Roary/issues/226)

**Merged pull requests:**

- fix bug Can't exec /bin/sh: Argument list too long [\#247](https://github.com/sanger-pathogens/Roary/pull/247) ([duytintruong](https://github.com/duytintruong))
- get rid of warning message [\#246](https://github.com/sanger-pathogens/Roary/pull/246) ([satta](https://github.com/satta))

## [v3.6.1](https://github.com/sanger-pathogens/Roary/tree/v3.6.1) (2016-04-18)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.6.0...v3.6.1)

**Fixed bugs:**

- roary\_plots.py generating flawed plots [\#221](https://github.com/sanger-pathogens/Roary/issues/221)

**Closed issues:**

- Core gene file missing error [\#241](https://github.com/sanger-pathogens/Roary/issues/241)

**Merged pull requests:**

- prefix commands with roary [\#244](https://github.com/sanger-pathogens/Roary/pull/244) ([andrewjpage](https://github.com/andrewjpage))
- More improvements to roary\_plots [\#240](https://github.com/sanger-pathogens/Roary/pull/240) ([mgalardini](https://github.com/mgalardini))

## [v3.6.0](https://github.com/sanger-pathogens/Roary/tree/v3.6.0) (2016-02-23)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.9...v3.6.0)

**Fixed bugs:**

- MSG: Got a sequence without letters. Could not guess alphabet [\#229](https://github.com/sanger-pathogens/Roary/issues/229)

**Closed issues:**

- Roary 3.5.8 works with -i 80 switch, but not with -i 90 or higher with large datasets? [\#234](https://github.com/sanger-pathogens/Roary/issues/234)
- How to use multiple switches in commandline? [\#232](https://github.com/sanger-pathogens/Roary/issues/232)

**Merged pull requests:**

- Improvements to roary\_plots [\#236](https://github.com/sanger-pathogens/Roary/pull/236) ([mgalardini](https://github.com/mgalardini))
- Rollback 3 5 8 [\#235](https://github.com/sanger-pathogens/Roary/pull/235) ([andrewjpage](https://github.com/andrewjpage))

## [v3.5.9](https://github.com/sanger-pathogens/Roary/tree/v3.5.9) (2016-02-17)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.8...v3.5.9)

**Implemented enhancements:**

- What clusters end up in gene accessory\_binary\_genes.fa ? [\#225](https://github.com/sanger-pathogens/Roary/issues/225)

**Closed issues:**

- roary.github.io just prints HELLO [\#233](https://github.com/sanger-pathogens/Roary/issues/233)

**Merged pull requests:**

- Fix minor typo [\#231](https://github.com/sanger-pathogens/Roary/pull/231) ([abremges](https://github.com/abremges))

## [v3.5.8](https://github.com/sanger-pathogens/Roary/tree/v3.5.8) (2016-01-20)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.7...v3.5.8)

**Implemented enhancements:**

- Getting Roary into Debian Med [\#219](https://github.com/sanger-pathogens/Roary/issues/219)
- Add embl output file mapping location of each core gene in the core genome alignment [\#192](https://github.com/sanger-pathogens/Roary/issues/192)

**Closed issues:**

- Error message: Cannot find the mcxdeblast executable, please ensure its in your PATH [\#217](https://github.com/sanger-pathogens/Roary/issues/217)

**Merged pull requests:**

- Provide full accessory for building binary tree [\#227](https://github.com/sanger-pathogens/Roary/pull/227) ([andrewjpage](https://github.com/andrewjpage))
- roary\_plots: new fields in roary output must be parsed away [\#222](https://github.com/sanger-pathogens/Roary/pull/222) ([mgalardini](https://github.com/mgalardini))
- Debian nitpicks [\#220](https://github.com/sanger-pathogens/Roary/pull/220) ([satta](https://github.com/satta))
- Core alignment header file [\#218](https://github.com/sanger-pathogens/Roary/pull/218) ([andrewjpage](https://github.com/andrewjpage))

## [v3.5.7](https://github.com/sanger-pathogens/Roary/tree/v3.5.7) (2015-12-17)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.6...v3.5.7)

**Closed issues:**

- Roary not checking tools needed to run [\#214](https://github.com/sanger-pathogens/Roary/issues/214)

**Merged pull requests:**

- Core gene count [\#213](https://github.com/sanger-pathogens/Roary/pull/213) ([andrewjpage](https://github.com/andrewjpage))

## [v3.5.6](https://github.com/sanger-pathogens/Roary/tree/v3.5.6) (2015-12-01)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.5...v3.5.6)

**Implemented enhancements:**

- Non-issue, FYI regarding my 'roary2svg.pl' script [\#195](https://github.com/sanger-pathogens/Roary/issues/195)

**Merged pull requests:**

- add roary2svg script [\#212](https://github.com/sanger-pathogens/Roary/pull/212) ([andrewjpage](https://github.com/andrewjpage))

## [v3.5.5](https://github.com/sanger-pathogens/Roary/tree/v3.5.5) (2015-11-26)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.4...v3.5.5)

**Merged pull requests:**

- CD-hit threads limit [\#211](https://github.com/sanger-pathogens/Roary/pull/211) ([andrewjpage](https://github.com/andrewjpage))

## [v3.5.4](https://github.com/sanger-pathogens/Roary/tree/v3.5.4) (2015-11-26)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.3...v3.5.4)

**Fixed bugs:**

- Use of uninitialized value in require at \(eval ..\) line 1. [\#204](https://github.com/sanger-pathogens/Roary/issues/204)
- \[bug\] Newick files in 3.5.1 have branch lengths of 0.0 [\#202](https://github.com/sanger-pathogens/Roary/issues/202)

**Merged pull requests:**

- Accessory binary fasta contains all C's fix [\#210](https://github.com/sanger-pathogens/Roary/pull/210) ([andrewjpage](https://github.com/andrewjpage))

## [v3.5.3](https://github.com/sanger-pathogens/Roary/tree/v3.5.3) (2015-11-26)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.2...v3.5.3)

**Implemented enhancements:**

- Enhancement:  roary -a to continue on if other parameters as well [\#207](https://github.com/sanger-pathogens/Roary/issues/207)
- Make summary\_statistics a TAB/TSV file? [\#193](https://github.com/sanger-pathogens/Roary/issues/193)

**Fixed bugs:**

- roary --version should return 0 not 255 exit code [\#206](https://github.com/sanger-pathogens/Roary/issues/206)
- Is the roary -a check complete? [\#205](https://github.com/sanger-pathogens/Roary/issues/205)

## [v3.5.2](https://github.com/sanger-pathogens/Roary/tree/v3.5.2) (2015-11-25)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.1...v3.5.2)

**Fixed bugs:**

- Use of uninitialized value in File::Slurper and Encode.pm  [\#196](https://github.com/sanger-pathogens/Roary/issues/196)

**Merged pull requests:**

- Improved dependancy checking [\#209](https://github.com/sanger-pathogens/Roary/pull/209) ([andrewjpage](https://github.com/andrewjpage))
- Lsf update gene alignments [\#201](https://github.com/sanger-pathogens/Roary/pull/201) ([andrewjpage](https://github.com/andrewjpage))

## [v3.5.1](https://github.com/sanger-pathogens/Roary/tree/v3.5.1) (2015-11-12)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.5.0...v3.5.1)

**Fixed bugs:**

- Accessory genes newick file contains full path of infividual files [\#200](https://github.com/sanger-pathogens/Roary/issues/200)
- add optional dependancy from File::Slurper to stop warnings being printed [\#199](https://github.com/sanger-pathogens/Roary/pull/199) ([andrewjpage](https://github.com/andrewjpage))

## [v3.5.0](https://github.com/sanger-pathogens/Roary/tree/v3.5.0) (2015-11-12)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.4.3...v3.5.0)

**Merged pull requests:**

- remove path from accessory tree [\#198](https://github.com/sanger-pathogens/Roary/pull/198) ([andrewjpage](https://github.com/andrewjpage))

## [v3.4.3](https://github.com/sanger-pathogens/Roary/tree/v3.4.3) (2015-11-11)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.4.2...v3.4.3)

**Merged pull requests:**

- consensus group name for pan reference [\#190](https://github.com/sanger-pathogens/Roary/pull/190) ([andrewjpage](https://github.com/andrewjpage))

## [v3.4.2](https://github.com/sanger-pathogens/Roary/tree/v3.4.2) (2015-10-12)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.4.1...v3.4.2)

**Merged pull requests:**

- Gene presence and absence rtab [\#189](https://github.com/sanger-pathogens/Roary/pull/189) ([andrewjpage](https://github.com/andrewjpage))

## [v3.4.1](https://github.com/sanger-pathogens/Roary/tree/v3.4.1) (2015-10-08)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.4.0...v3.4.1)

**Implemented enhancements:**

- Need protein lengths in the final spreadsheet [\#116](https://github.com/sanger-pathogens/Roary/issues/116)

**Fixed bugs:**

- Bio-RetrieveAssemblies-1.0.1 fails to install [\#151](https://github.com/sanger-pathogens/Roary/issues/151)

**Merged pull requests:**

- \* Proposed fix for CPANTS error. [\#187](https://github.com/sanger-pathogens/Roary/pull/187) ([manwar](https://github.com/manwar))

## [v3.4.0](https://github.com/sanger-pathogens/Roary/tree/v3.4.0) (2015-10-07)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.3.4...v3.4.0)

**Merged pull requests:**

- Extra columns in spreadsheet with gene lengths [\#186](https://github.com/sanger-pathogens/Roary/pull/186) ([andrewjpage](https://github.com/andrewjpage))

## [v3.3.4](https://github.com/sanger-pathogens/Roary/tree/v3.3.4) (2015-10-07)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.3.3...v3.3.4)

**Closed issues:**

- EXCEPTION: Bio::Root::Exception could not read ...faa.intermediate.extracted.fa [\#175](https://github.com/sanger-pathogens/Roary/issues/175)

**Merged pull requests:**

- increase dependancy RAM [\#185](https://github.com/sanger-pathogens/Roary/pull/185) ([andrewjpage](https://github.com/andrewjpage))
- Use lsf for gene alignment [\#184](https://github.com/sanger-pathogens/Roary/pull/184) ([andrewjpage](https://github.com/andrewjpage))

## [v3.3.3](https://github.com/sanger-pathogens/Roary/tree/v3.3.3) (2015-09-29)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.3.2...v3.3.3)

**Merged pull requests:**

- dont align if sequences same length and nearly the same [\#183](https://github.com/sanger-pathogens/Roary/pull/183) ([andrewjpage](https://github.com/andrewjpage))

## [v3.3.2](https://github.com/sanger-pathogens/Roary/tree/v3.3.2) (2015-09-28)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.3.1...v3.3.2)

**Implemented enhancements:**

- Use of temporary folders and files [\#177](https://github.com/sanger-pathogens/Roary/issues/177)

**Merged pull requests:**

- Duplicate sequences in pan genome reference fasta [\#182](https://github.com/sanger-pathogens/Roary/pull/182) ([andrewjpage](https://github.com/andrewjpage))

## [v3.3.1](https://github.com/sanger-pathogens/Roary/tree/v3.3.1) (2015-09-25)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.3.0...v3.3.1)

**Merged pull requests:**

- Fix usage text [\#181](https://github.com/sanger-pathogens/Roary/pull/181) ([andrewjpage](https://github.com/andrewjpage))

## [v3.3.0](https://github.com/sanger-pathogens/Roary/tree/v3.3.0) (2015-09-24)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.9...v3.3.0)

**Fixed bugs:**

- Check at least 2 gff files have been passed in [\#171](https://github.com/sanger-pathogens/Roary/issues/171)
- Pentuple memory for worst case sCenario [\#170](https://github.com/sanger-pathogens/Roary/issues/170)
- 00\_requires\_external.t missing "mafft" ? [\#168](https://github.com/sanger-pathogens/Roary/issues/168)

**Merged pull requests:**

- Check dependancies [\#180](https://github.com/sanger-pathogens/Roary/pull/180) ([andrewjpage](https://github.com/andrewjpage))

## [v3.2.9](https://github.com/sanger-pathogens/Roary/tree/v3.2.9) (2015-09-23)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.8...v3.2.9)

**Implemented enhancements:**

- Add --outdir option to avoid blatting current directory [\#176](https://github.com/sanger-pathogens/Roary/issues/176)

**Fixed bugs:**

- CPAN install failure "unknown option mafft" [\#169](https://github.com/sanger-pathogens/Roary/issues/169)

**Closed issues:**

- Error "Cant open file: \_uninflated\_mcl\_groups" [\#179](https://github.com/sanger-pathogens/Roary/issues/179)

**Merged pull requests:**

- Add the option to specify an output directory [\#178](https://github.com/sanger-pathogens/Roary/pull/178) ([andrewjpage](https://github.com/andrewjpage))

## [v3.2.8](https://github.com/sanger-pathogens/Roary/tree/v3.2.8) (2015-09-23)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.7...v3.2.8)

## [v3.2.7](https://github.com/sanger-pathogens/Roary/tree/v3.2.7) (2015-09-02)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.6...v3.2.7)

**Merged pull requests:**

- count paralogs correctly when looking for differences in datasets [\#174](https://github.com/sanger-pathogens/Roary/pull/174) ([andrewjpage](https://github.com/andrewjpage))

## [v3.2.6](https://github.com/sanger-pathogens/Roary/tree/v3.2.6) (2015-09-02)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.5...v3.2.6)

**Merged pull requests:**

- revert core tree generation [\#173](https://github.com/sanger-pathogens/Roary/pull/173) ([andrewjpage](https://github.com/andrewjpage))

## [v3.2.5](https://github.com/sanger-pathogens/Roary/tree/v3.2.5) (2015-08-17)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.4...v3.2.5)

**Merged pull requests:**

- Verbose stats [\#172](https://github.com/sanger-pathogens/Roary/pull/172) ([andrewjpage](https://github.com/andrewjpage))
- dont set bioperl version [\#167](https://github.com/sanger-pathogens/Roary/pull/167) ([andrewjpage](https://github.com/andrewjpage))

## [v3.2.4](https://github.com/sanger-pathogens/Roary/tree/v3.2.4) (2015-07-23)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.3...v3.2.4)

**Merged pull requests:**

- update readme citation [\#165](https://github.com/sanger-pathogens/Roary/pull/165) ([andrewjpage](https://github.com/andrewjpage))

## [v3.2.3](https://github.com/sanger-pathogens/Roary/tree/v3.2.3) (2015-07-22)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.1...v3.2.3)

**Merged pull requests:**

- update citation message [\#164](https://github.com/sanger-pathogens/Roary/pull/164) ([andrewjpage](https://github.com/andrewjpage))
- Pass mafft through to alignment [\#163](https://github.com/sanger-pathogens/Roary/pull/163) ([andrewjpage](https://github.com/andrewjpage))

## [v3.2.1](https://github.com/sanger-pathogens/Roary/tree/v3.2.1) (2015-07-21)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.2.0...v3.2.1)

## [v3.2.0](https://github.com/sanger-pathogens/Roary/tree/v3.2.0) (2015-07-20)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.1.2...v3.2.0)

**Merged pull requests:**

- Use mafft [\#162](https://github.com/sanger-pathogens/Roary/pull/162) ([andrewjpage](https://github.com/andrewjpage))
- output summary file [\#161](https://github.com/sanger-pathogens/Roary/pull/161) ([andrewjpage](https://github.com/andrewjpage))
- Pass through dont delete flag [\#160](https://github.com/sanger-pathogens/Roary/pull/160) ([andrewjpage](https://github.com/andrewjpage))
- Assembly statistics [\#159](https://github.com/sanger-pathogens/Roary/pull/159) ([andrewjpage](https://github.com/andrewjpage))

## [v3.1.2](https://github.com/sanger-pathogens/Roary/tree/v3.1.2) (2015-07-13)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/3.1.2...v3.1.2)

## [3.1.2](https://github.com/sanger-pathogens/Roary/tree/3.1.2) (2015-07-13)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.1.1...3.1.2)

**Fixed bugs:**

- prank seg fault [\#157](https://github.com/sanger-pathogens/Roary/issues/157)

**Merged pull requests:**

- Core gene missing files [\#158](https://github.com/sanger-pathogens/Roary/pull/158) ([andrewjpage](https://github.com/andrewjpage))

## [v3.1.1](https://github.com/sanger-pathogens/Roary/tree/v3.1.1) (2015-06-26)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.1.0...v3.1.1)

**Closed issues:**

- sadaf [\#154](https://github.com/sanger-pathogens/Roary/issues/154)

## [v3.1.0](https://github.com/sanger-pathogens/Roary/tree/v3.1.0) (2015-06-22)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.0.3...v3.1.0)

**Merged pull requests:**

- Accessory binary tree [\#155](https://github.com/sanger-pathogens/Roary/pull/155) ([andrewjpage](https://github.com/andrewjpage))

## [v3.0.3](https://github.com/sanger-pathogens/Roary/tree/v3.0.3) (2015-06-15)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.0.2...v3.0.3)

**Fixed bugs:**

- Annotation missing in set\_difference\_unique\_set\_one/two\_statistics.csv files [\#137](https://github.com/sanger-pathogens/Roary/issues/137)

**Merged pull requests:**

- when creating core gene alignment, lookup sample names to genes in sp… [\#153](https://github.com/sanger-pathogens/Roary/pull/153) ([andrewjpage](https://github.com/andrewjpage))
- Only align core files [\#150](https://github.com/sanger-pathogens/Roary/pull/150) ([andrewjpage](https://github.com/andrewjpage))

## [v3.0.2](https://github.com/sanger-pathogens/Roary/tree/v3.0.2) (2015-06-12)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.0.1...v3.0.2)

**Implemented enhancements:**

- Print out the version number [\#119](https://github.com/sanger-pathogens/Roary/issues/119)

**Merged pull requests:**

- Mafft and exonerate dependancies [\#149](https://github.com/sanger-pathogens/Roary/pull/149) ([andrewjpage](https://github.com/andrewjpage))
- Add a version parameter and add in marcos plots code [\#148](https://github.com/sanger-pathogens/Roary/pull/148) ([andrewjpage](https://github.com/andrewjpage))

## [v3.0.1](https://github.com/sanger-pathogens/Roary/tree/v3.0.1) (2015-06-12)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v3.0.0...v3.0.1)

**Fixed bugs:**

- Use of -e switch gives multifasta file with N's only [\#132](https://github.com/sanger-pathogens/Roary/issues/132)

## [v3.0.0](https://github.com/sanger-pathogens/Roary/tree/v3.0.0) (2015-06-11)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.3.4...v3.0.0)

**Merged pull requests:**

- Use prank for core genome alignments [\#147](https://github.com/sanger-pathogens/Roary/pull/147) ([andrewjpage](https://github.com/andrewjpage))
- Accessory graph [\#146](https://github.com/sanger-pathogens/Roary/pull/146) ([andrewjpage](https://github.com/andrewjpage))

## [v2.3.4](https://github.com/sanger-pathogens/Roary/tree/v2.3.4) (2015-06-10)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.3.3...v2.3.4)

## [v2.3.3](https://github.com/sanger-pathogens/Roary/tree/v2.3.3) (2015-06-08)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.3.2...v2.3.3)

**Merged pull requests:**

- Simplify perl dependency installation [\#145](https://github.com/sanger-pathogens/Roary/pull/145) ([bewt85](https://github.com/bewt85))
- Pan genome reference [\#144](https://github.com/sanger-pathogens/Roary/pull/144) ([andrewjpage](https://github.com/andrewjpage))
- Fix input files with duplicate IDs [\#143](https://github.com/sanger-pathogens/Roary/pull/143) ([andrewjpage](https://github.com/andrewjpage))
- Test against different versions of GNU Parallel [\#142](https://github.com/sanger-pathogens/Roary/pull/142) ([bewt85](https://github.com/bewt85))

## [v2.3.2](https://github.com/sanger-pathogens/Roary/tree/v2.3.2) (2015-06-08)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.3.1...v2.3.2)

**Fixed bugs:**

- GFF files derived from Prokka genbank raise errors [\#130](https://github.com/sanger-pathogens/Roary/issues/130)
- MSG: Got a sequence without letters. Could not guess alphabet [\#127](https://github.com/sanger-pathogens/Roary/issues/127)

**Merged pull requests:**

- TravisCI only wants the major and minor version of perl [\#141](https://github.com/sanger-pathogens/Roary/pull/141) ([bewt85](https://github.com/bewt85))
- Add TravisCI support [\#140](https://github.com/sanger-pathogens/Roary/pull/140) ([bewt85](https://github.com/bewt85))
- Use locus tag when ID is missing from GFF [\#139](https://github.com/sanger-pathogens/Roary/pull/139) ([andrewjpage](https://github.com/andrewjpage))

## [v2.3.1](https://github.com/sanger-pathogens/Roary/tree/v2.3.1) (2015-06-02)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.3.0...v2.3.1)

**Merged pull requests:**

- Extract IDs from GFF file using Bio::Perl [\#138](https://github.com/sanger-pathogens/Roary/pull/138) ([andrewjpage](https://github.com/andrewjpage))

## [v2.3.0](https://github.com/sanger-pathogens/Roary/tree/v2.3.0) (2015-06-01)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.2.6...v2.3.0)

**Closed issues:**

- "cpan" command reports Bio::Roary as version '\(undef\)' [\#134](https://github.com/sanger-pathogens/Roary/issues/134)

## [v2.2.6](https://github.com/sanger-pathogens/Roary/tree/v2.2.6) (2015-06-01)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.2.4...v2.2.6)

**Closed issues:**

- No tagged release for 2.2.3 [\#133](https://github.com/sanger-pathogens/Roary/issues/133)
- Syntax \(?\) errors on perl 5.10.1 [\#128](https://github.com/sanger-pathogens/Roary/issues/128)

**Merged pull requests:**

- include version numbers for cpan [\#136](https://github.com/sanger-pathogens/Roary/pull/136) ([andrewjpage](https://github.com/andrewjpage))
- New version number for contributed fix for issue \#128 [\#135](https://github.com/sanger-pathogens/Roary/pull/135) ([andrewjpage](https://github.com/andrewjpage))
- gnu parallel switch for ubuntu [\#131](https://github.com/sanger-pathogens/Roary/pull/131) ([andrewjpage](https://github.com/andrewjpage))
- Backward compatible deferencing of hashes [\#129](https://github.com/sanger-pathogens/Roary/pull/129) ([mgalardini](https://github.com/mgalardini))

## [v2.2.4](https://github.com/sanger-pathogens/Roary/tree/v2.2.4) (2015-05-29)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.2.3...v2.2.4)

**Closed issues:**

- ERROR: cannot remove directory for split\_groups [\#115](https://github.com/sanger-pathogens/Roary/issues/115)
- cleanup outputfiles [\#114](https://github.com/sanger-pathogens/Roary/issues/114)

**Merged pull requests:**

- Cleanup files [\#126](https://github.com/sanger-pathogens/Roary/pull/126) ([andrewjpage](https://github.com/andrewjpage))

## [v2.2.3](https://github.com/sanger-pathogens/Roary/tree/v2.2.3) (2015-05-21)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.2.2...v2.2.3)

**Closed issues:**

- Change QC so that it doesnt shred reads [\#117](https://github.com/sanger-pathogens/Roary/issues/117)
- QC doesnt work outside sanger [\#112](https://github.com/sanger-pathogens/Roary/issues/112)

**Merged pull requests:**

- Update Kraken QC [\#125](https://github.com/sanger-pathogens/Roary/pull/125) ([andrewjpage](https://github.com/andrewjpage))

## [v2.2.2](https://github.com/sanger-pathogens/Roary/tree/v2.2.2) (2015-05-21)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.2.0...v2.2.2)

**Closed issues:**

- Hard-coded Sanger paths in some scripts [\#124](https://github.com/sanger-pathogens/Roary/issues/124)
- You're missing some Perl dependancies [\#123](https://github.com/sanger-pathogens/Roary/issues/123)
- Add support for GFF files from NCBI [\#120](https://github.com/sanger-pathogens/Roary/issues/120)

**Merged pull requests:**

- Fix usage text [\#122](https://github.com/sanger-pathogens/Roary/pull/122) ([andrewjpage](https://github.com/andrewjpage))

## [v2.2.0](https://github.com/sanger-pathogens/Roary/tree/v2.2.0) (2015-05-14)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.1.2...v2.2.0)

**Closed issues:**

- Verbose output with -v [\#113](https://github.com/sanger-pathogens/Roary/issues/113)

**Merged pull requests:**

- Accept genbank files [\#121](https://github.com/sanger-pathogens/Roary/pull/121) ([andrewjpage](https://github.com/andrewjpage))

## [v2.1.2](https://github.com/sanger-pathogens/Roary/tree/v2.1.2) (2015-05-12)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.1.1...v2.1.2)

**Merged pull requests:**

- Verbose output [\#118](https://github.com/sanger-pathogens/Roary/pull/118) ([andrewjpage](https://github.com/andrewjpage))

## [v2.1.1](https://github.com/sanger-pathogens/Roary/tree/v2.1.1) (2015-04-29)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.0.9...v2.1.1)

**Merged pull requests:**

- pass core definition into number of conserved genes plot [\#111](https://github.com/sanger-pathogens/Roary/pull/111) ([andrewjpage](https://github.com/andrewjpage))
- Vary core definition [\#110](https://github.com/sanger-pathogens/Roary/pull/110) ([andrewjpage](https://github.com/andrewjpage))
- Use block quotes in readme [\#109](https://github.com/sanger-pathogens/Roary/pull/109) ([bewt85](https://github.com/bewt85))

## [v2.0.9](https://github.com/sanger-pathogens/Roary/tree/v2.0.9) (2015-04-20)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.0.8...v2.0.9)

**Merged pull requests:**

- Allow for multiple processors to be used [\#108](https://github.com/sanger-pathogens/Roary/pull/108) ([andrewjpage](https://github.com/andrewjpage))

## [v2.0.8](https://github.com/sanger-pathogens/Roary/tree/v2.0.8) (2015-04-09)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.0.7...v2.0.8)

**Merged pull requests:**

- Speedup [\#107](https://github.com/sanger-pathogens/Roary/pull/107) ([andrewjpage](https://github.com/andrewjpage))
- new version 2.0.7 [\#106](https://github.com/sanger-pathogens/Roary/pull/106) ([andrewjpage](https://github.com/andrewjpage))

## [v2.0.7](https://github.com/sanger-pathogens/Roary/tree/v2.0.7) (2015-03-28)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.0.5...v2.0.7)

**Merged pull requests:**

- old splits [\#105](https://github.com/sanger-pathogens/Roary/pull/105) ([andrewjpage](https://github.com/andrewjpage))
- Speedup split [\#104](https://github.com/sanger-pathogens/Roary/pull/104) ([andrewjpage](https://github.com/andrewjpage))

## [v2.0.5](https://github.com/sanger-pathogens/Roary/tree/v2.0.5) (2015-03-26)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/2.0.4...v2.0.5)

**Merged pull requests:**

- Stop deep recursion [\#103](https://github.com/sanger-pathogens/Roary/pull/103) ([andrewjpage](https://github.com/andrewjpage))
- check programs installed [\#102](https://github.com/sanger-pathogens/Roary/pull/102) ([andrewjpage](https://github.com/andrewjpage))

## [2.0.4](https://github.com/sanger-pathogens/Roary/tree/2.0.4) (2015-03-23)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/2.0.3...2.0.4)

**Merged pull requests:**

- File slurp tiny [\#101](https://github.com/sanger-pathogens/Roary/pull/101) ([andrewjpage](https://github.com/andrewjpage))
- version 2.0.3 [\#100](https://github.com/sanger-pathogens/Roary/pull/100) ([andrewjpage](https://github.com/andrewjpage))

## [2.0.3](https://github.com/sanger-pathogens/Roary/tree/2.0.3) (2015-03-17)
[Full Changelog](https://github.com/sanger-pathogens/Roary/compare/v2.0.0...2.0.3)

**Merged pull requests:**

- Remove LSF support [\#99](https://github.com/sanger-pathogens/Roary/pull/99) ([andrewjpage](https://github.com/andrewjpage))
- Dont set LSF as the default runner [\#98](https://github.com/sanger-pathogens/Roary/pull/98) ([andrewjpage](https://github.com/andrewjpage))
- Rename directories to Roary [\#97](https://github.com/sanger-pathogens/Roary/pull/97) ([andrewjpage](https://github.com/andrewjpage))

## [v2.0.0](https://github.com/sanger-pathogens/Roary/tree/v2.0.0) (2015-03-16)
**Merged pull requests:**

- Ship binaries [\#96](https://github.com/sanger-pathogens/Roary/pull/96) ([andrewjpage](https://github.com/andrewjpage))
- Pad merged multifastas when data is missing [\#95](https://github.com/sanger-pathogens/Roary/pull/95) ([carlacummins](https://github.com/carlacummins))
- Subsample reads [\#94](https://github.com/sanger-pathogens/Roary/pull/94) ([andrewjpage](https://github.com/andrewjpage))
- Merge Carlas CGN [\#93](https://github.com/sanger-pathogens/Roary/pull/93) ([andrewjpage](https://github.com/andrewjpage))
- rename spreadsheet [\#92](https://github.com/sanger-pathogens/Roary/pull/92) ([andrewjpage](https://github.com/andrewjpage))
- Refactor out fasta grep [\#91](https://github.com/sanger-pathogens/Roary/pull/91) ([andrewjpage](https://github.com/andrewjpage))
- remove fasta\_grep [\#90](https://github.com/sanger-pathogens/Roary/pull/90) ([andrewjpage](https://github.com/andrewjpage))
- Add gnu parallel support [\#89](https://github.com/sanger-pathogens/Roary/pull/89) ([andrewjpage](https://github.com/andrewjpage))
- Updated create\_pan\_genome help text to include -qc option [\#88](https://github.com/sanger-pathogens/Roary/pull/88) ([carlacummins](https://github.com/carlacummins))
- QC report option added [\#87](https://github.com/sanger-pathogens/Roary/pull/87) ([carlacummins](https://github.com/carlacummins))
- increase blastp min memory to 3gb from 100 [\#86](https://github.com/sanger-pathogens/Roary/pull/86) ([andrewjpage](https://github.com/andrewjpage))
- Remove fastatranslate dependancy [\#85](https://github.com/sanger-pathogens/Roary/pull/85) ([andrewjpage](https://github.com/andrewjpage))
- Queue set to basement if number of samples \> 600 \(previously 800\) [\#84](https://github.com/sanger-pathogens/Roary/pull/84) ([carlacummins](https://github.com/carlacummins))
- Bug fix [\#83](https://github.com/sanger-pathogens/Roary/pull/83) ([carlacummins](https://github.com/carlacummins))
- Added verbose stats option [\#82](https://github.com/sanger-pathogens/Roary/pull/82) ([carlacummins](https://github.com/carlacummins))
- Group limit changed to 50,000 [\#81](https://github.com/sanger-pathogens/Roary/pull/81) ([carlacummins](https://github.com/carlacummins))
- Multifastas not created when group limit \(default 8000\) exceeded [\#80](https://github.com/sanger-pathogens/Roary/pull/80) ([carlacummins](https://github.com/carlacummins))
- allow for translation table to be passed in [\#79](https://github.com/sanger-pathogens/Roary/pull/79) ([andrewjpage](https://github.com/andrewjpage))
- increase memory [\#78](https://github.com/sanger-pathogens/Roary/pull/78) ([andrewjpage](https://github.com/andrewjpage))
- Allow user specify sorting when reordering spreadsheet against a tree [\#77](https://github.com/sanger-pathogens/Roary/pull/77) ([andrewjpage](https://github.com/andrewjpage))
- Bug fixing [\#76](https://github.com/sanger-pathogens/Roary/pull/76) ([carlacummins](https://github.com/carlacummins))
- Added AUTHORS file [\#75](https://github.com/sanger-pathogens/Roary/pull/75) ([aslett1](https://github.com/aslett1))
- if theres more than 1k samples use basement for default analysis [\#74](https://github.com/sanger-pathogens/Roary/pull/74) ([andrewjpage](https://github.com/andrewjpage))
- use long queue for more than 200 samples [\#73](https://github.com/sanger-pathogens/Roary/pull/73) ([andrewjpage](https://github.com/andrewjpage))
- core alignment gets run with lsf [\#72](https://github.com/sanger-pathogens/Roary/pull/72) ([andrewjpage](https://github.com/andrewjpage))
- Job runner ids lsf [\#71](https://github.com/sanger-pathogens/Roary/pull/71) ([andrewjpage](https://github.com/andrewjpage))
- Core alignment missing file [\#70](https://github.com/sanger-pathogens/Roary/pull/70) ([andrewjpage](https://github.com/andrewjpage))
- Core alignment missing file [\#69](https://github.com/sanger-pathogens/Roary/pull/69) ([andrewjpage](https://github.com/andrewjpage))
- update error reporting [\#68](https://github.com/sanger-pathogens/Roary/pull/68) ([andrewjpage](https://github.com/andrewjpage))
- Create core alignment from spreadsheet and multifasta files [\#67](https://github.com/sanger-pathogens/Roary/pull/67) ([andrewjpage](https://github.com/andrewjpage))
- make script executable [\#66](https://github.com/sanger-pathogens/Roary/pull/66) ([andrewjpage](https://github.com/andrewjpage))
- script to merge multifasta files together [\#65](https://github.com/sanger-pathogens/Roary/pull/65) ([andrewjpage](https://github.com/andrewjpage))
- rename output gene multfastas and pass all sequences through [\#64](https://github.com/sanger-pathogens/Roary/pull/64) ([andrewjpage](https://github.com/andrewjpage))
- Align genes at protein level and back translate to nucleotides [\#63](https://github.com/sanger-pathogens/Roary/pull/63) ([andrewjpage](https://github.com/andrewjpage))
- Depth first search for reordering spreadsheet [\#62](https://github.com/sanger-pathogens/Roary/pull/62) ([andrewjpage](https://github.com/andrewjpage))
- make the iterative cdhit script useful for standalone use [\#61](https://github.com/sanger-pathogens/Roary/pull/61) ([andrewjpage](https://github.com/andrewjpage))
- query\_pan\_genome\_update\_text [\#60](https://github.com/sanger-pathogens/Roary/pull/60) ([andrewjpage](https://github.com/andrewjpage))
- fix failing tests [\#59](https://github.com/sanger-pathogens/Roary/pull/59) ([andrewjpage](https://github.com/andrewjpage))
- Create plot for % blast identity [\#58](https://github.com/sanger-pathogens/Roary/pull/58) ([andrewjpage](https://github.com/andrewjpage))
- add a flag to keep intermediate files [\#57](https://github.com/sanger-pathogens/Roary/pull/57) ([andrewjpage](https://github.com/andrewjpage))
- set the known gene names to black and rest to colours [\#56](https://github.com/sanger-pathogens/Roary/pull/56) ([andrewjpage](https://github.com/andrewjpage))
- print fragment blocks [\#55](https://github.com/sanger-pathogens/Roary/pull/55) ([andrewjpage](https://github.com/andrewjpage))
- Fix ordering of accessory [\#54](https://github.com/sanger-pathogens/Roary/pull/54) ([andrewjpage](https://github.com/andrewjpage))
- fix r plots [\#53](https://github.com/sanger-pathogens/Roary/pull/53) ([andrewjpage](https://github.com/andrewjpage))
- Overlapping proteins [\#52](https://github.com/sanger-pathogens/Roary/pull/52) ([andrewjpage](https://github.com/andrewjpage))
- Gene order [\#51](https://github.com/sanger-pathogens/Roary/pull/51) ([andrewjpage](https://github.com/andrewjpage))
- pass job runner to iterative cdhit [\#50](https://github.com/sanger-pathogens/Roary/pull/50) ([andrewjpage](https://github.com/andrewjpage))
- iterative cdhit in a job [\#49](https://github.com/sanger-pathogens/Roary/pull/49) ([andrewjpage](https://github.com/andrewjpage))
- Fix tests [\#48](https://github.com/sanger-pathogens/Roary/pull/48) ([andrewjpage](https://github.com/andrewjpage))
- Prefilter optimisation [\#47](https://github.com/sanger-pathogens/Roary/pull/47) ([andrewjpage](https://github.com/andrewjpage))
- dont split groups [\#46](https://github.com/sanger-pathogens/Roary/pull/46) ([andrewjpage](https://github.com/andrewjpage))
- rename create plots R script [\#45](https://github.com/sanger-pathogens/Roary/pull/45) ([andrewjpage](https://github.com/andrewjpage))
- cdhit should output full description of sequence name [\#44](https://github.com/sanger-pathogens/Roary/pull/44) ([andrewjpage](https://github.com/andrewjpage))
- Gene count plot [\#43](https://github.com/sanger-pathogens/Roary/pull/43) ([andrewjpage](https://github.com/andrewjpage))
- align gene multifasta files using muscle [\#42](https://github.com/sanger-pathogens/Roary/pull/42) ([andrewjpage](https://github.com/andrewjpage))
- Reorder spreadsheet [\#41](https://github.com/sanger-pathogens/Roary/pull/41) ([andrewjpage](https://github.com/andrewjpage))
- Reorder spreadsheet [\#40](https://github.com/sanger-pathogens/Roary/pull/40) ([andrewjpage](https://github.com/andrewjpage))
- Speedup post analysis [\#39](https://github.com/sanger-pathogens/Roary/pull/39) ([andrewjpage](https://github.com/andrewjpage))
- Presence and absence of genes [\#38](https://github.com/sanger-pathogens/Roary/pull/38) ([andrewjpage](https://github.com/andrewjpage))
- split big groups based on annotation [\#37](https://github.com/sanger-pathogens/Roary/pull/37) ([andrewjpage](https://github.com/andrewjpage))
- make multifasta files easier to sort [\#36](https://github.com/sanger-pathogens/Roary/pull/36) ([andrewjpage](https://github.com/andrewjpage))
- dont wait in lfs scheduler [\#35](https://github.com/sanger-pathogens/Roary/pull/35) ([andrewjpage](https://github.com/andrewjpage))
- run post analysis as a job [\#34](https://github.com/sanger-pathogens/Roary/pull/34) ([andrewjpage](https://github.com/andrewjpage))
- annotate the names of the groups files [\#33](https://github.com/sanger-pathogens/Roary/pull/33) ([andrewjpage](https://github.com/andrewjpage))
- Output all sequences making up pan genome in multifasta files [\#32](https://github.com/sanger-pathogens/Roary/pull/32) ([andrewjpage](https://github.com/andrewjpage))
- Run external applications through lsf [\#31](https://github.com/sanger-pathogens/Roary/pull/31) ([andrewjpage](https://github.com/andrewjpage))
- remove done dependancy job [\#30](https://github.com/sanger-pathogens/Roary/pull/30) ([andrewjpage](https://github.com/andrewjpage))
- blocking job [\#29](https://github.com/sanger-pathogens/Roary/pull/29) ([andrewjpage](https://github.com/andrewjpage))
- Filter unknowns in LSF jobs [\#28](https://github.com/sanger-pathogens/Roary/pull/28) ([andrewjpage](https://github.com/andrewjpage))
- Pass job runner through to extract gffs [\#27](https://github.com/sanger-pathogens/Roary/pull/27) ([andrewjpage](https://github.com/andrewjpage))
- Change case of GFF commandline class [\#26](https://github.com/sanger-pathogens/Roary/pull/26) ([andrewjpage](https://github.com/andrewjpage))
- use LSF to do the inital parsing of input files [\#25](https://github.com/sanger-pathogens/Roary/pull/25) ([andrewjpage](https://github.com/andrewjpage))
- renamed LICENSE [\#24](https://github.com/sanger-pathogens/Roary/pull/24) ([CraigPorter](https://github.com/CraigPorter))
- GPL [\#23](https://github.com/sanger-pathogens/Roary/pull/23) ([andrewjpage](https://github.com/andrewjpage))
- lsf memory in mb [\#22](https://github.com/sanger-pathogens/Roary/pull/22) ([andrewjpage](https://github.com/andrewjpage))
- low complexity filtering [\#21](https://github.com/sanger-pathogens/Roary/pull/21) ([andrewjpage](https://github.com/andrewjpage))
- inflate clusters where the representative gene is not the first [\#20](https://github.com/sanger-pathogens/Roary/pull/20) ([andrewjpage](https://github.com/andrewjpage))
- report more sequences from blastp [\#19](https://github.com/sanger-pathogens/Roary/pull/19) ([andrewjpage](https://github.com/andrewjpage))
- update tests for different input processing [\#18](https://github.com/sanger-pathogens/Roary/pull/18) ([andrewjpage](https://github.com/andrewjpage))
- speedup extracting proteins from gff [\#17](https://github.com/sanger-pathogens/Roary/pull/17) ([andrewjpage](https://github.com/andrewjpage))
- sort spreadsheet by number of isolates [\#16](https://github.com/sanger-pathogens/Roary/pull/16) ([andrewjpage](https://github.com/andrewjpage))
- create spreadsheets of differences between sets [\#15](https://github.com/sanger-pathogens/Roary/pull/15) ([andrewjpage](https://github.com/andrewjpage))
- Output statistics on groups [\#14](https://github.com/sanger-pathogens/Roary/pull/14) ([andrewjpage](https://github.com/andrewjpage))
- Find the difference between isolates [\#13](https://github.com/sanger-pathogens/Roary/pull/13) ([andrewjpage](https://github.com/andrewjpage))
- check if group is null [\#12](https://github.com/sanger-pathogens/Roary/pull/12) ([andrewjpage](https://github.com/andrewjpage))
- catch undef [\#11](https://github.com/sanger-pathogens/Roary/pull/11) ([andrewjpage](https://github.com/andrewjpage))
- tests for create pan genome script [\#10](https://github.com/sanger-pathogens/Roary/pull/10) ([andrewjpage](https://github.com/andrewjpage))
- label fasta sequences with annotation ID [\#9](https://github.com/sanger-pathogens/Roary/pull/9) ([andrewjpage](https://github.com/andrewjpage))
- extract proteomes from gffs and transfer anntotation as part of script [\#8](https://github.com/sanger-pathogens/Roary/pull/8) ([andrewjpage](https://github.com/andrewjpage))
- transfer annotation [\#7](https://github.com/sanger-pathogens/Roary/pull/7) ([andrewjpage](https://github.com/andrewjpage))
- speedup searching fastas [\#6](https://github.com/sanger-pathogens/Roary/pull/6) ([andrewjpage](https://github.com/andrewjpage))
- typo in memory estimation [\#5](https://github.com/sanger-pathogens/Roary/pull/5) ([andrewjpage](https://github.com/andrewjpage))
- run mcl and inflate results [\#4](https://github.com/sanger-pathogens/Roary/pull/4) ([andrewjpage](https://github.com/andrewjpage))
- vary memory usage according to input file size [\#3](https://github.com/sanger-pathogens/Roary/pull/3) ([andrewjpage](https://github.com/andrewjpage))
- working on real data [\#2](https://github.com/sanger-pathogens/Roary/pull/2) ([andrewjpage](https://github.com/andrewjpage))
- Initial functionality [\#1](https://github.com/sanger-pathogens/Roary/pull/1) ([andrewjpage](https://github.com/andrewjpage))

