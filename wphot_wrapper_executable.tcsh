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
        echo "Is this the correct Parent Directory  and Tile Name? (y/n)"
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
		echo
                echo ERROR: $ParentDir doest not exist.
                echo
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

set FulldepthDir = $ParentDir/UnWISE/

echo iterating over $FulldepthDir
echo Wrapper now starting...
echo
echo
echo 1\) wphot wrapper programs now starting...

#TESTING
#while
foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile

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
		echo $FulldepthDir
		echo $RadecIDDir
		echo RadecID == $RadecID
		echo RaRaRa == $RaRaRa
		#Error Checking
		if(! -d $UnWISEDir) then
			echo ERROR: Input dir $UnWISEDir does not exist.
                	echo
                	echo Exiting...
                	exit
        	endif
		if(! -d $CatWISEDir) then
                	echo ERROR: Output dir $CatWISE does not exist.
                	echo
                	echo Exiting...
                	exit
        	endif 
	
		##***READ CAUTION***, the cname == root name == unwise-0657p151... thus, same as the "base" in frames_list.tbl 
		#automatically generates frames_list.tbl
		set rootname = unwise-$RadecID
		#print tbl header in frames_list.tbl
		echo "|  path              |      base     | b1 | b2 | b3 | b4 |" > ${TileDir}/frames_list.tbl
		echo "|   c                |       c       |  i |  i |  i |  i |" >> ${TileDir}/frames_list.tbl
		echo "|                    |" >> ${TileDir}/frames_list.tbl
		echo "|                    |" >> ${TileDir}/frames_list.tbl
		#print each epoch in frames_list.tbl
		set fullDir = ${TileDir}Full/
       		foreach subDir ($TileDir*/)
			echo "Subdir == ${subDir}"
			echo "fullDir == ${fullDir}"
			if($subDir != ${fullDir}) then
				echo $subDir $rootname 1 1 0 0 >> ${TileDir}/frames_list.tbl
			endif
		end

		#replaces escape character on all existing "/"
		set editedUnWISEDir=`echo $UnWISEDir | sed 's/\//\\\//g'`
		set editedCatWISEDir=`echo $CatWISEDir | sed 's/\//\\\//g'`
		set editedTileDir=`echo $TileDir | sed 's/\//\\\//g'`
		sed -i --follow-symlinks "16s/.*.*/set mdetfile = ${editedCatWISEDir}detlist.tbl/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        	#changes frames_list output location TODO Do I really need to keep the frames list?
		 sed -i --follow-symlinks "20s/.*.*/set flist =  ${editedTileDir}\/frames_list.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        	#changes image id to the tile name (RadecID)
        	sed -i --follow-symlinks "22s/.*.*/set imageid = ${RadecID}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        	#changes psfdir
        	sed -i --follow-symlinks "40s/.*.*/set psfdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh	
		#changes cname
		sed -i --follow-symlinks "47s/.*.*/set cname = ${editedUnWISEDir}\/$rootname/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
		#changes outdir
        	sed -i --follow-symlinks "55s/.*.*/set outdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
		#changes mdex output file name
        	sed -i --follow-symlinks "59s/.*.*/set outname = ${editedCatWISEDir}\/mdex_STD-msk.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        	#changes meta output file name
        	sed -i --follow-symlinks "60s/.*.*/set metaname = ${editedCatWISEDir}\/meta_STD-msk.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
		#changes verbose
        	sed -i --follow-symlinks "61s/.*.*/set verbose = ${editedCatWISEDir}\/ProgramTerminalOutput\/wphot_output.txt/" ${wrapperDir}/wphot_wrapper_option-0.tcsh

		#Run WPHOT Option 0
		${wrapperDir}/wphot_wrapper_option-0.tcsh &
	
		wait	
		(/Volumes/CatWISE1/CatWISEDev/stf ${CatWISEDir}/mdex_STD-msk.tbl 1-11 16-21 28 29 32 33 36-39 44-49 56-60 63 64 67-77 88-93 100-105 112-117 124-129 136-141 148-153 160-165 172-177 184-205 228 231 234-246 259-275 278-281 286-291 298-301 > ${CatWISEDir}/stf-mdex_STD-msk.tbl) & 

		while(`ps -ef | grep wphot | wc -l` > 12)
                        #echo IM WATING
                        #do nothing
                end
		while(`ps -ef | grep stf | wc -l` > 12)
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
        
        #Error Checking
        if(! -d $UnWISEDir) then
            echo ERROR: Input dir $UnWISEDir does not exist.
                    echo
                    echo Exiting...
                    exit
            endif
        if(! -d $CatWISEDir) then
                    echo ERROR: Output dir $CatWISE does not exist.
                    echo
                    echo Exiting...
                    exit
            endif 
    
        ##***READ CAUTION***, the cname == root name == unwise-0657p151... thus, same as the "base" in frames_list.tbl 
        #automatically generates frames_list.tbl
        set rootname = unwise-$RadecID
        #print tbl header in frames_list.tbl
        echo "|  path              |      base     | b1 | b2 | b3 | b4 |" > ${TileDir}/frames_list.tbl
        echo "|   c                |       c       |  i |  i |  i |  i |" >> ${TileDir}/frames_list.tbl
        echo "|                    |" >> ${TileDir}/frames_list.tbl
        echo "|                    |" >> ${TileDir}/frames_list.tbl
        #print each epoch in frames_list.tbl
        set fullDir = ${TileDir}Full/
            foreach subDir ($TileDir*/)
            echo "Subdir == ${subDir}"
            echo "fullDir == ${fullDir}"
            if($subDir != ${fullDir}) then
                echo $subDir $rootname 1 1 0 0 >> ${TileDir}/frames_list.tbl
            endif
        end

        #replaces escape character on all existing "/"
        set editedUnWISEDir=`echo $UnWISEDir | sed 's/\//\\\//g'`
        set editedCatWISEDir=`echo $CatWISEDir | sed 's/\//\\\//g'`
	set editedTileDir=`echo $TileDir | sed 's/\//\\\//g'`
        sed -i --follow-symlinks "16s/.*.*/set mdetfile = ${editedCatWISEDir}detlist.tbl/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes frames_list output location TODO Do I really need to keep the frames list?
	 sed -i --follow-symlinks "20s/.*.*/set flist =  ${editedTileDir}\/frames_list.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes image id to the tile name (RadecID)
        sed -i --follow-symlinks "22s/.*.*/set imageid = ${RadecID}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes psfdir
        sed -i --follow-symlinks "40s/.*.*/set psfdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh 
        #changes cname
        sed -i --follow-symlinks "47s/.*.*/set cname = ${editedUnWISEDir}\/$rootname/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes outdir
        sed -i --follow-symlinks "55s/.*.*/set outdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes mdex output file name
        sed -i --follow-symlinks "59s/.*.*/set outname = ${editedCatWISEDir}\/mdex_STD-msk.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes meta output file name
        sed -i --follow-symlinks "60s/.*.*/set metaname = ${editedCatWISEDir}\/meta_STD-msk.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes verbose
        sed -i --follow-symlinks "61s/.*.*/set verbose = ${editedCatWISEDir}\/ProgramTerminalOutput\/wphot_output.txt/" ${wrapperDir}/wphot_wrapper_option-0.tcsh

        #Run WPHOT Option 0
        ${wrapperDir}/wphot_wrapper_option-0.tcsh &
       	
	wait 
	(/Volumes/CatWISE1/CatWISEDev/stf ${CatWISEDir}/mdex_STD-msk.tbl 1-11 16-21 28 29 32 33 36-39 44-49 56-60 63 64 67-77 88-93 100-105 112-117 124-129 136-141 148-153 160-165 172-177 184-205 228 231 234-246 259-275 278-281 286-291 298-301 > ${CatWISEDir}/stf-mdex_STD-msk.tbl) & 


        while(`ps -ef | grep wphot | wc -l` > 12)
                        #echo IM WATING
                        #do nothing
                end
	while(`ps -ef | grep stf | wc -l` > 12)
                        #echo IM WATING
                        #do nothing
                end

                echo wphot for ${RadecID} done!
            
            echo ====================================== end wphot wrapper loop iteration =======================================
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

	#Error Checking
	if(! -d $UnWISEDir) then
                echo ERROR: $UnWISEDir does not exist.
                echo
                echo Exiting...
                exit
        endif
	if(! -d $CatWISEDir) then
                echo ERROR: $CatWISE does not exist.
                echo
                echo Exiting...
                exit
        endif 
	
	##***READ CAUTION***, the cname == root name == unwise-0657p151... thus, same as the "base" in frames_list.tbl 
	#automatically generates frames_list.tbl
	set rootname = unwise-$RadecID
	#print tbl header in frames_list.tbl
	echo "|  path              |      base     | b1 | b2 | b3 | b4 |" > ${TileDir}/frames_list.tbl
	echo "|   c                |       c       |  i |  i |  i |  i |" >> ${TileDir}/frames_list.tbl
	echo "|                    |" >> ${TileDir}/frames_list.tbl
	echo "|                    |" >> ${TileDir}/frames_list.tbl
	#print each epoch in frames_list.tbl
	set fullDir = ${TileDir}Full/
        foreach subDir ($TileDir*/)
		echo "Subdir == ${subDir}"
		echo "fullDir == ${fullDir}"
		if($subDir != ${fullDir}) then
			echo $subDir $rootname 1 1 0 0 >> ${TileDir}/frames_list.tbl
		endif
	end

	#replaces escape character on all existing "/"
	set editedUnWISEDir=`echo $UnWISEDir | sed 's/\//\\\//g'`
	set editedCatWISEDir=`echo $CatWISEDir | sed 's/\//\\\//g'`
	 set editedTileDir=`echo $TileDir | sed 's/\//\\\//g'`
	sed -i --follow-symlinks "16s/.*.*/set mdetfile = ${editedCatWISEDir}detlist.tbl/g" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes frames_list output location TODO Do I really need to keep the frames list?
	sed -i --follow-symlinks "20s/.*.*/set flist =  ${editedTileDir}\/frames_list.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes image id to the tile name (RadecID)
        sed -i --follow-symlinks "22s/.*.*/set imageid = ${RadecID}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes psfdir
        sed -i --follow-symlinks "40s/.*.*/set psfdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh	
	#changes cname
	sed -i --follow-symlinks "47s/.*.*/set cname = ${editedUnWISEDir}\/$rootname/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes outdir
        sed -i --follow-symlinks "55s/.*.*/set outdir = ${editedCatWISEDir}/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes mdex output file name
        sed -i --follow-symlinks "59s/.*.*/set outname = ${editedCatWISEDir}\/mdex_STD-msk.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
        #changes meta output file name
        sed -i --follow-symlinks "60s/.*.*/set metaname = ${editedCatWISEDir}\/meta_STD-msk.tbl/" ${wrapperDir}/wphot_wrapper_option-0.tcsh
	#changes verbose
        sed -i --follow-symlinks "61s/.*.*/set verbose = ${editedCatWISEDir}\/ProgramTerminalOutput\/wphot_output.txt/" ${wrapperDir}/wphot_wrapper_option-0.tcsh

	#Run WPHOT Option 0
	${wrapperDir}/wphot_wrapper_option-0.tcsh

	
	(/Volumes/CatWISE1/CatWISEDev/stf ${CatWISEDir}/mdex_STD-msk.tbl 1-11 16-21 28 29 32 33 36-39 44-49 56-60 63 64 67-77 88-93 100-105 112-117 124-129 136-141 148-153 160-165 172-177 184-205 228 231 234-246 259-275 278-281 286-291 298-301 > ${CatWISEDir}/stf-mdex_STD-msk.tbl)  

	goto Done

Done:
echo WPHOTWrapper Done!
echo Removing wphot_wrapper_option-0.tcsh--follow-symlinks
rm -f wphot_wrapper_option-0.tcsh--follow-symlinks
set endTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Ended at:
echo $endTime
