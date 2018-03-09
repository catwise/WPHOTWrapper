#! /bin/tcsh -fe

#===============================================================================================================================================================

set wrapperDir = $PWD
set startTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Started at:
echo $startTime
echo 
echo Version 2.03 
echo
echo This Wrapper will wrap around and run WPHOTPMC
#echo ================================================================================================================
#echo WARNING\: Elijah is doing testing\/editing to this program \(Oct10 2017\). This script will not work propperly.
#echo ================================================================================================================
if ($# != 2 && $# != 3) then
        #Error handling
        #Too many or too little arguments       
        echo ""
	echo "ERROR: not enough arguments:"
	echo Mode 1 call:
	echo ./wphot_wrapper_executable_opt1.tcsh 1 ParentDir/
	echo Mode 2 call:
	echo ./wphot_wrapper_executable_opt1.tcsh 2 inputList.txt ParentDir/
	echo Mode 3 call:
        echo ./wphot_wrapper_executable_opt1.tcsh 3 ParentDir/ TileName
        echo
        echo Exiting...
        exit
#Mode1
else if ($# == 2 && $1 == 1) then
        set ParentDir = $2
       # set OutputsDir = $3
        echo Parent directory ==  $ParentDir
       # echo Outputs directory == $OutputsDir
        echo "Is this the correct Parent directory? (y/n)"
        set userInput = $<

        #Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with full Input Directory path as the 2nd parameter and the Ouput Directory path as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -d $ParentDir) then
                echo ERROR: Input Directory $ParentDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
        #if (! -d $OutputsDir) then
        #        echo ERROR: Output Directory $OutputsDir does not exist.
        #        echo
        #        echo Exiting...
        #        exit
        #endif

	goto Mode1
#Mode2
else if ($1 == 2) then
	set InputsList = $2
        set ParentDir = $3
        echo Inputs list ==  $InputsList
        echo Parent directory == $ParentDir
        echo
        echo "Is this the correct input list and Parent directory? (y/n)"
        set userInput = $<
    
    #Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with full Input List file as the 2nd parameter and the Parent Directory path as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -f $InputsList) then
                echo ERROR: Input List file $InputsDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
        if (! -d $ParentDir) then
                echo ERROR: Parent Directory $ParentDir does not exist.
                echo
                echo Exiting...
                exit
        endif
        goto Mode2
#Mode3 Single Tile Mode
else if ($1 == 3) then
	set ParentDir = $2
	set RadecID = $3
 	echo Parent Dir ==  $ParentDir
        echo Tile Name == $RadecID
        echo
        echo "Is this the correct Parent Directory and Tile Name? (y/n)"
        set userInput = $<
 	#Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with Parent Directory as the 2nd parameter and the Tile Name as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -d $ParentDir) then
                echo ERROR: $ParentDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
	goto Mode3
else
        #Error handling
        #option 1/2/3 not second parameter. program exits.
        echo
	echo ERROR mode 1, 2, or 3 not selected
	echo Mode 1 call:
        echo ./wphot_wrapper_executable_opt1.tcsh 1 ParentDir/
        echo Mode 2 call:
        echo ./wphot_wrapper_executable_opt1.tcsh 2 inputList.txt ParentDir/
        echo Mode 3 call:
        echo ./wphot_wrapper_executable_opt1.tcsh 3 ParentDir/ TileName
        echo
        echo Exiting...
	exit
endif

Mode1:
#===============================================================================================================================================================        
# loops through all of the tiles and executes wphot
#TODO update this to work for option1
set InputDir = $ParentDir/UnWISE/

echo Wrapper now starting...
echo
echo
echo 1\) wphot wrapper programs now starting...

foreach RaRaRaDir ($InputDir*/) #for each directory in InputDir, get each RadecIDdir, run wrapper on RadecID tile

        foreach RadecIDDir ($RaRaRaDir*/)

                echo =============================== starting wphot wrapper loop iteration =================================
	#Stops calling programs if number of scripts running is greater than number of threads on CPU
               
		set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
        	@ tempIndex = ($tempSize - 8)
        	set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
		set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
		set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
		set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
		set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
		set AsceDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Asce/ 
		set DescDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Desc/ 

		
		#Error Checking
		if(! -d $UnWISEDir) then
	                echo ERROR: $UnWISEDir does not exist.
	                echo
	                echo Exiting...
	                exit
	        endif
		if(! -d $CatWISEDir) then
	                echo ERROR: $CatWISEDir does not exist.
	                echo
	                echo Exiting...
	                exit
	        endif 
		if(! -d $AsceDir) then
	                echo ERROR: $AsceDir does not exist.
	                echo
	                echo Exiting...
	                exit
	        endif
		if(! -d $DescDir) then
	                echo ERROR: $DescDir does not exist.
	                echo
	                echo Exiting...
	                exit
	        endif 
	echo a
		(echo y | ./wphot_wrapper_executable_opt1.tcsh 3 $ParentDir $RadecID) &  #; echo Wrapper Call for ${RadecID} success! &
	echo b
		while(`ps -ef | grep wphot | wc -l` > 12)
                        #echo IM WATING
                        #do nothing
        	end
	
        echo wphot for ${RadecID} done!


        echo ================================ ending wphot wrapper loop iteration =================================
        end
end

#===============================================================================================================================================================

#wait for background processes to finish
wait
echo wphot wrapper finished!
echo
goto Done

Mode2:
	
    foreach line (`cat $InputsList`)    
        echo ===================================== start wphot wrapper loop iteration ======================================
     
        set RadecID = `echo $line`
        set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`

        echo "RaRaRa == "$RaRaRa
        echo "RadecID == "$RadecID
        set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
	set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
	set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
	set AsceDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Asce/ 
	set DescDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Desc/ 

	
	#Error Checking
	if(! -d $UnWISEDir) then
	        echo ERROR: $UnWISEDir does not exist.
	        echo
	        echo Exiting...
	        exit
	endif
	if(! -d $CatWISEDir) then
	        echo ERROR: $CatWISEDir does not exist.
	        echo
	        echo Exiting...
	        exit
	endif 
	if(! -d $AsceDir) then
	        echo ERROR: $AsceDir does not exist.
	        echo
	        echo Exiting...
	        exit
	endif
	if(! -d $DescDir) then
	        echo ERROR: $DescDir does not exist.
	        echo
	        echo Exiting...
	        exit
	endif 
	(echo y | ./wphot_wrapper_executable_opt1.tcsh 3 $ParentDir $RadecID) &  #; echo Wrapper Call for ${RadecID} success! &
	while(`ps -ef | grep wphot | wc -l` > 12)
                #echo IM WATING
                #do nothing
        end
	
        echo wphot for ${RadecID} done!
		
	end

    #===============================================================================================================================================================

    #wait for background processes to finish
    wait
    echo wphot wrapper finished!
    echo


	goto Done

Mode3:
	set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
	set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
	set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/ 
	set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
	set AsceDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Asce/ 
	set DescDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/Desc/ 

	
	#Error Checking
	if(! -d $UnWISEDir) then
                echo ERROR: $UnWISEDir does not exist.
                echo
                echo Exiting...
                exit
        endif
	if(! -d $CatWISEDir) then
                echo ERROR: $CatWISEDir does not exist.
                echo
                echo Exiting...
                exit
        endif 
	if(! -d $AsceDir) then
                echo ERROR: $AsceDir does not exist.
                echo
                echo Exiting...
                exit
        endif
	if(! -d $DescDir) then
                echo ERROR: $DescDir does not exist.
                echo
                echo Exiting...
                exit
        endif 
	
	##***READ CAUTION***, the cname == root name == unwise-0657p151... thus, same as the "base" in frames_list.tbl 
	#automatically generates frames_list.tbl
	set rootname = unwise-$RadecID
	#print tbl header in frames_list.tbl
	#echo "|  path              |      base     | b1 | b2 | b3 | b4 |" > ${wrapperDir}/frames_list.tbl
	#echo "|   c                |       c       |  i |  i |  i |  i |" >> ${wrapperDir}/frames_list.tbl
	#echo "|                    |" >> ${wrapperDir}/frames_list.tbl
	#echo "|                    |" >> ${wrapperDir}/frames_list.tbl
	#print each epoch in frames_list.tbl
	#set fullDir = ${TileDir}Full/
        #foreach subDir ($TileDir*/)
	#	echo "Subdir == ${subDir}"
	#	echo "fullDir == ${fullDir}"
	#	if($subDir != ${fullDir}) then
	#		echo $subDir $rootname 1 1 0 0 >> ${wrapperDir}/frames_list.tbl
	#	endif
	#end
	
	#GenWFL Makes frames list for Asce and Desc	
#	/Volumes/CatWISE1/CatWISEDev/genwfl -t $TileDir -oa ${AsceDir}/frames_list_Asce.tbl -od ${DescDir}frames_list_Desc.tbl -ox ${CatWISEDir}/epochs.tbl	
	/Volumes/CatWISE1/jwf/bin/genwfl -t $TileDir -oa ${AsceDir}/frames_list_Asce.tbl -od ${DescDir}frames_list_Desc.tbl -ox ${CatWISEDir}/epochs.tbl
	#wait for genWFL
	#wait	

	#replaces escape character on all existing "/"
	set editedUnWISEDir=`echo $UnWISEDir | sed 's/\//\\\//g'`
	set editedCatWISEDir=`echo $CatWISEDir | sed 's/\//\\\//g'`
	set editedAsceDir=`echo $AsceDir | sed 's/\//\\\//g'`
	set editedDescDir=`echo $DescDir | sed 's/\//\\\//g'`
	set editedTileDir=`echo $TileDir | sed 's/\//\\\//g'`

	echo "\033[1;31m Creating temp dir for $RadecID \033[0m"
	mkdir -p ${editedCatWISEDir}/ProgramTerminalOutput/DELETEME
	cp $wrapperDir/wphot_wrapper_option-0.tcsh ${editedCatWISEDir}/ProgramTerminalOutput/DELETEME/
	set wrapperDir = ${editedCatWISEDir}/ProgramTerminalOutput/DELETEME
	
	#Asce call
	sed -i --follow-symlinks "16s/.*.*/set mdetfile = ${editedCatWISEDir}detlist.tbl/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes frames_list output location TODO Do I really need to keep the frames list?
        sed -i --follow-symlinks "20s/.*.*/set flist =  ${editedAsceDir}\/frames_list_Asce.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes image id to the tile name (RadecID)
        sed -i --follow-symlinks "22s/.*.*/set imageid = ${RadecID}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes psfdir
        sed -i --follow-symlinks "40s/.*.*/set psfdir = ${editedAsceDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh	
	#changes cname
	sed -i --follow-symlinks "47s/.*.*/set cname = ${editedUnWISEDir}\/$rootname/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes outdir
        sed -i --follow-symlinks "55s/.*.*/set outdir = ${editedAsceDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes mdex output file name
        sed -i --follow-symlinks "59s/.*.*/set outname = ${editedAsceDir}\/mdex_asce.Opt-1a.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes meta output file name
        sed -i --follow-symlinks "60s/.*.*/set metaname = ${editedAsceDir}\/meta_asce.Opt-1a.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes verbose
        sed -i --follow-symlinks "61s/.*.*/set verbose = ${editedCatWISEDir}\/ProgramTerminalOutput\/wphot_1a_Asce_output.txt/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#Run WPHOT
	${wrapperDir}/wphot_wrapper_option-0.tcsh & 
	
	
	#Desc call
	sed -i --follow-symlinks "16s/.*.*/set mdetfile = ${editedCatWISEDir}detlist.tbl/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes frames_list output location TODO Do I really need to keep the frames list?
        sed -i --follow-symlinks "20s/.*.*/set flist =  ${editedDescDir}\/frames_list_Desc.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh 
        #changes image id to the tile name (RadecID)
        sed -i --follow-symlinks "22s/.*.*/set imageid = ${RadecID}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes psfdir
        sed -i --follow-symlinks "40s/.*.*/set psfdir = ${editedDescDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh	
	#changes cname
	sed -i --follow-symlinks "47s/.*.*/set cname = ${editedUnWISEDir}\/$rootname/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes outdir
        sed -i --follow-symlinks "55s/.*.*/set outdir = ${editedDescDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes mdex output file name
	sed -i --follow-symlinks "59s/.*.*/set outname = ${editedDescDir}\/mdex_desc.Opt-1a.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes meta output file name
        sed -i --follow-symlinks "60s/.*.*/set metaname = ${editedDescDir}\/meta_desc.Opt-1a.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes verbose
        sed -i --follow-symlinks "61s/.*.*/set verbose = ${editedCatWISEDir}\/ProgramTerminalOutput\/wphot_1a_Desc_output.txt/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#Run WPHOT
	${wrapperDir}/wphot_wrapper_option-0.tcsh &
	#wait for wphot calls to finish
	wait

	echo Removing ${editedCatWISEDir}/ProgramTerminalOutput/DELETEME 
	rm -rf ${editedCatWISEDir}/ProgramTerminalOutput/DELETEME

	#Post-WPHOT work

	#stf
	#call on Ascending
	(/Volumes/CatWISE1/CatWISEDev/stf ${AsceDir}/mdex_asce.Opt-1a.tbl 1-11 16-21 28 29 32 33 36-39 44-49 56-60 63 64 67-77 88-93 100-105 112-117 124-129 136-141 148-153 160-165 172-177 184-205 228 231 234-246 259-275 278-281 286-291 298-301 > ${AsceDir}/stf-mdex_asce.Opt-1a.tbl)  
	#call on Descending 
	(/Volumes/CatWISE1/CatWISEDev/stf ${DescDir}/mdex_desc.Opt-1a.tbl 1-11 16-21 28 29 32 33 36-39 44-49 56-60 63 64 67-77 88-93 100-105 112-117 124-129 136-141 148-153 160-165 172-177 184-205 228 231 234-246 259-275 278-281 286-291 298-301 > ${DescDir}/stf-mdex_desc.Opt-1a.tbl) 
	#TODO get pid, wait for pid && run cmd
	#wait for stf calls to finish
	#wait

	#gsa
	#set Radius
	#echo input radius size
	#$? > $Radius
	/Volumes/CatWISE1/CatWISEDev/gsa -t ${AsceDir}/stf-mdex_asce.Opt-1a.tbl -t ${DescDir}/stf-mdex_desc.Opt-1a.tbl -o ${CatWISEDir}/gsa.tbl -ra1 ra -ra2 ra -dec1 dec -dec2 dec -r 20 -cw -a1 -ns -rf1 ${CatWISEDir}/stf-mrg13_asce.Opt-1a-rf1.tbl -rf2 ${CatWISEDir}/stf-mrg13_desc.Opt-1a-rf2.tbl 
	#wait for gsa calls to finish
	#wait
	
	set date_t = `date`
	
	#mrgad
	/Volumes/CatWISE1/CatWISEDev/mrgad -i ${CatWISEDir}/gsa.tbl -ia ${AsceDir}/stf-mdex_asce.Opt-1a.tbl -id ${DescDir}/stf-mdex_desc.Opt-1a.tbl -o ${CatWISEDir}/${RadecID}_opt1_${date}.tbl 
	#wait for mrgad calls to finish
#	wait

	goto Done

Done:
echo WPHOTWrapper Done!
echo Removing wphot_wrapper_option-0.tcsh--follow-symlinks
rm -f wphot_wrapper_option-0.tcsh--follow-symlinks
set endTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Ended at:
echo $endTime
