#! /bin/tcsh -f

#  shell script that runs WPHotpmc
#  T. Jarrett ; June 25, 2017


###  these will not change during processing (one-time change only)

set wphot = /Users/jarrett/wphotpm/bin/WPHotpmc #wphot binary, this is the updated wphote as of nov21, 2017

set namelist = /Users/jarrett/wphotpm/bin/nl.WPHot_unwise 


#### MDET (this will change every time)

set mdetfile = ../Parent_Dir//CatWISE/217/2174p348/Full/detlist.tbl

###### Frame parameters  (file names here will likely change)
#CHANGE
set flist =  ../Parent_Dir//CatWISE/217/2174p348//frames_list_Desc.tbl

set imageid = 2174p348

set ftype = m #KEEP need to hard code, make sure MDET wrapper and WPHOT wrapper does -m-

set fint = img #KEEP

set func = std #KEEP

set fcov = n

####  PSF parameters  (likely will change, depending on scan angles, etc)

#  /Volumes/CatWISE1/jwf/COSMOS_PSFs/ (option-0 wpro PSFs and awaic PSFs for the COSMOS tile)
#  /Volumes/CatWISE1/jwf/COSMOS_PSFs/asce/ (option-1 ascending wpro PSFs for the COSMOS tile)
#  /Volumes/CatWISE1/jwf/COSMOS_PSFs/desc/ (option-1 descending wpro PSFs for the COSMOS tile)

#set psfdir = /Volumes/CatWISE1/jwf/COSMOS_PSFs
#CHANGE
set psfdir = ../Parent_Dir//CatWISE/217/2174p348/Full/Desc/

set psfname = unWISE

####  Coadd parameters  (coadd name will change with every set) *** CAUTION -- you need to add the root name at the end of the path

#CHANGE
set cname = ../Parent_Dir//UnWISE/217/2174p348//unwise-2174p348

set ctype = u


#### output directories & file names 

#CHANGE
set outdir = ../Parent_Dir//CatWISE/217/2174p348/Full/Desc/
mkdir -p $outdir

#CHANGE
set outname = ../Parent_Dir//CatWISE/217/2174p348/Full/Desc//mdex_desc.Opt-1a.tbl
set metaname = ../Parent_Dir//CatWISE/217/2174p348/Full/Desc//meta_desc.Opt-1a.tbl
set verbose = ../Parent_Dir//CatWISE/217/2174p348/Full//ProgramTerminalOutput/wphot_1a_Desc_output.txt

set outQAdir =  $outdir/QA 
mkdir -p $outQAdir


## copy some of the inputs to the outdir for the record
rsync -auv $flist $outdir #not needed
rsync -auv $namelist $outdir #not needed

########################################  run the command line
echo ' '

echo $wphot -namlis  $namelist \
-mdettab $mdetfile \
-mdex mdet \
-imageid $imageid  \
-ifile $flist \
-level $ftype -int $fint -unc $func -cov $fcov  \
-calpsfdir $psfdir \
-calbname $psfname \
-calgridszX 1  -calgridszY 1  \
-coadd  $cname \
-clevel $ctype \
-qadir $outQAdir \
-ofile $outname \
-meta $metaname 

echo 'begin: '
date
echo 'running ... standby ...'

echo ' ' #binary call for wphot
($wphot -namlis  $namelist \
-mdettab $mdetfile \
-mdex mdet \
-imageid $imageid  \
-ifile $flist \
-level $ftype -int $fint -unc $func -cov $fcov  \
-calpsfdir $psfdir \
-calbname $psfname \
-calgridszX 1  -calgridszY 1 \
-coadd  $cname \
-clevel $ctype \
-qadir $outQAdir \
-ofile $outname \
-meta $metaname -v >& $verbose) 

echo ' '
echo 'finished ; see '$verbose
date

