# WPHOTWrapper

## Description
  This wrapper will automatically generate a frames_list.tbl and run WPHOT in a given parent directory. This parent directory structure will follow the CatWISE Directory Structure provided in the CatWISE wiki (CatWISE/Documentation/CatWISE_IOdirectoryStructure2017nov21.pdf). Thus, **UnWISE/ and CatWISE/ need to exist under the parent directory.**
    
  
## How to Run Modes
* Mode 1: Everything Mode
	* Run all tiles in input directory
	* **./wphot_wrapper_executable** 1 \<ParentDirectory\>
* Mode 2: List Mode
	* Run all tiles in input list
	* **./wphot_wrapper_executable** 2 \<ParentDirectory\> \<TileList\>
* Mode 3: Single-Tile Mode
	* Run tile given in command line input. The input TileName should be a RaDecID (eg 3568m182)
	* **./wphot_wrapper_executable** 3 \<ParentDirectory\> \<TileName\>
  
## Arguments
  * \-nl \<NamesList\>
  * \-rsync
