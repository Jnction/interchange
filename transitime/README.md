There are several main classes which are used in the set up of the system. These can be run directly by specifying the class to run or by using the executable jar in the target directory.

The steps to set up the system are 
<ul>
	<li>Create Database. For this step you are on your own and you should find instructions on the related database providers web sites.
	</li>
	<li>Create Database structures
		using generateDatabaseScheme.jar
	</li>
	</li>
	<li>Import GTFS static data using
		processGTFSFile.jar
	</li>		
	<li>Get access to a source of realtime GPS data.</li>
	<li>Create transiTime module to read realtime GPS data or create a converter to convert the realtime datasource to a GTFS-RT vechicle location source.</li>
	<li>Config and run core module</li>
	<li>Create Web Agency using WebAgency class</li>
	<li>Create API key. For the moment see TestAPIKeyManager.java test. The testAPIKeyManger test will create a key for you.</li>
	<li>Setup transitime api webapp. Instructions to be added to README.MD in transitimeApi.</li>
	<li>Setup transitime webapp. Instructions to be added to README.MD in transitimeWebapp.</li>
	
	<li>Configure travel times/predictions based on historical data using UpdateTravelTimes.java. Instructions in "Improving Predictions" section below.</li>
</ul>
	

generateDatabaseSchema.jar -- Main class: org.transitime.applications.SchemaGenerator
=================================
ISSUE: skip to ISSUE below for the moment as there is a classloader issue when using onejar.
<br/>
The jar generateDatabaseSchema.jar can be used to re-generate the SQL required to create the database structures required to run transiTime. It generates three files in the specified directory. A file is generated for each supported database type. (Postgres, Oracle, Mysql). The script generated will drop tables that already exist.
<br/>
<i>


```
usage: 
	java -jar generateDatabaseSchema.jar<br/>
 		-o,--outputDirectory <arg>        This is the directory to output the sql<br/>
 		-p,--hibernatePackagePath <arg>   This is the path to the package
                		                  containing the hibernate annotated java<br/>
                                		  classes<br/>
```                                		  
                                   

```
example:
	java -jar generateDatabaseSchema.jar -o c:\temp\ -p org.transitime.db.structs	
```
To create all tables require you to support the core and the webapp you could run

```
	java -jar generateDatabaseSchema.jar -o c:\temp\core\ -p org.transitime.db.structs
	java -jar generateDatabaseSchema.jar -o c:\temp\web\ -p org.transitime.db.webstructs
```

Once these commands have been run you should run the sql created in the files in the core and web directory in your database.
	
ISSUE: This works in eclipse by executing the class but not on command line using the executable jar. It is an issue with the ClassLoader and onejar. Maybe better to create using mvn exec plugin.

The following will can be run from the transitime directory under core and will place the required SQL in the target directory.
```
mvn exec:java -Dexec.mainClass="org.transitime.applications.SchemaGenerator" -Dexec.args="-o target -p org.transitime.db.structs"
mvn exec:java -Dexec.mainClass="org.transitime.applications.SchemaGenerator" -Dexec.args="-o target -p org.transitime.db.webstructs"
````

processGTFSFile.jar -- Main class: org.transitime.applications.GTFSFileProcessor
=================================    
This class the usage can be got from specifying the -h option on its own.

```
usage: java processGTFSFile.jar [-c <configFile>] [-combineRouteNames]
       [-defaultWaitTimeAtStopMsec <msec>] [-gtfsDirectoryName <dirName>]
       [-gtfsUrl <url>] [-gtfsZipFileName <zipFileName>] [-h]
       [-maxDistanceForEliminatingVertices <meters>] [-maxSpeedKph <kph>]
       [-maxStopToPathDistance <meters>] [-maxTravelTimeSegmentLength <meters>]
       [-n <notes>] [-pathOffsetDistance <meters>] [-regexReplaceFile
       <fileName>] [-storeNewRevs] [-supplementDir <dirName>]
       [-trimPathBeforeFirstStopOfTrip] [-unzipSubdirectory <dirName>]
args:
  -c,--config <configFile>                     Specifies configuration file to
                                               read in. Needed for specifying
                                               how to connect to database.
  -combineRouteNames                           Combines short and long route
                                               names to create full name.
  -defaultWaitTimeAtStopMsec <msec>            For initial travel times before
                                               AVL data used to refine them.
                                               Specifies how long vehicle is
                                               expected to wait at the stop.
                                               Default is 10,000 msec (10
                                               seconds).
  -gtfsDirectoryName <dirName>                 Directory where unzipped GTFS
                                               file are. Can be used if already
                                               have current version of GTFS data
                                               and it is already unzipped.
  -gtfsUrl <url>                               URL where to get GTFS zip file
                                               from. It will be copied over,
                                               unzipped, and processed.
  -gtfsZipFileName <zipFileName>               Local file name where the GTFS
                                               zip file is. It will be unzipped
                                               and processed.
  -h                                           Display usage and help info.
  -maxDistanceForEliminatingVertices <meters>  For consolidating vertices for a
                                               path. If have short segments that
                                               line up then might as combine
                                               them. If a vertex is off the rest
                                               of the path by only the distance
                                               specified then the vertex will be
                                               removed, thereby simplifying the
                                               path. Value is in meters. Default
                                               is 0.0m, which means that no
                                               vertices will be eliminated.
  -maxSpeedKph <kph>                           For initial travel times before
                                               AVL data used to refine them.
                                               Specifies maximum speed a vehicle
                                               can go between stops when
                                               determining schedule based travel
                                               times. Default is 97kph (60mph).
  -maxStopToPathDistance <meters>              How far a stop can be away from
                                               the stopPaths. If the stop is
                                               further away from the distance
                                               then a warning message will be
                                               output and the path will be
                                               modified to include the stop.
  -maxTravelTimeSegmentLength <meters>         For determining how many travel
                                               time segments should have between
                                               a pair of stops. Default is
                                               200.0m, which means that many
                                               stop stopPaths will have only a
                                               single travel time segment
                                               between stops.
  -n,--notes <notes>                           Description of why processing the
                                               GTFS data
  -pathOffsetDistance <meters>                 When set then the shapes from
                                               shapes.txt are offset to the
                                               right by this distance in meters.
                                               Useful for when shapes.txt is
                                               street centerline data. By
                                               offsetting the shapes then the
                                               stopPaths for the two directions
                                               won't overlap when zoomed in on
                                               the map. Can use a negative
                                               distance to adjust stopPaths to
                                               the left instead of right, which
                                               could be useful for countries
                                               where one drives on the left side
                                               of the road.
  -regexReplaceFile <fileName>                 File that contains pairs or regex
                                               and replacement text. The names
                                               in the GTFS files are processed
                                               using these replacements to fix
                                               up spelling mistakes,
                                               capitalization, etc.
  -storeNewRevs                                Stores the config and travel time
                                               revs into ActiveRevisions in
                                               database.
  -supplementDir <dirName>                     Directory where supplemental GTFS
                                               files can be found. These files
                                               are combined with the regular
                                               GTFS files. Useful for additing
                                               additional info such as
                                               routeorder and hidden.
  -trimPathBeforeFirstStopOfTrip               For trimming off path from
                                               shapes.txt for before the first
                                               stops of trips. Useful for when
                                               the shapes have problems at the
                                               beginning, which is suprisingly
                                               common.
  -unzipSubdirectory <dirName>                 For when unzipping GTFS files. If
                                               set then the resulting files go
                                               into this subdirectory.
```

```
example:
	java  -Xmx1000M -Dtransitime.core.agencyId=02 -jar processGTFSFile.jar -c d:/transiTime/transiTimeConfig.xml -gtfsDirectoryName d:/transiTime/updated_google_transit_irishrail/ -storeNewRevs -maxTravelTimeSegmentLength 1000
```


WORK IN PROGRESS........................
Improving Predictions
=================================
UpdateTravelTimes.java is a main application which looks at historical data in the system and updates the estimated times where there is relavent historical data.

This takes one or two date arguments. It is intended to process one days data and update the travel times in the database based on this data.

If two dates supplied it processes all data within the date range. If a single date provided it processes all data for that day.

Date in is format MM-dd-yyyy

Example using maven to execute
````


mvn exec:java -Dtransitime.configFiles=/home/scrudden/workspace/transitimeconfig/transiTimeConfig.xml -Dtransitime.logging.dir=/home/scrudden/workspace/core/logs/ -Dexec.mainClass="org.transitime.applications.UpdateTravelTimes" -Dexec.args="08-24-2015"
````
Configuration File for core.java
==============================
Core can read its configuration from an xml configuration file. The xml file is not based on a schema but on nested tags that match the hierachy specified in the names in the source. The main work is done by the modules which are configured in the semi colon delimited list in the optionModuleList tag.  The choice of module and the their individual configuration is a complex task which will be specific to each transit agency.

The database and hibernate config file are specified in this file.

<b>/home/scrudden/workspace/transitimeconfig/transiTimeConfig.xml</b>
````
<?xml version="1.0" encoding="UTF-8"?>
<transitime>
    <modules>
        <!-- <optionalModulesList>org.transitime.core.schedBasedPreds.SchedBasedPredsModule;org.transitime.avl.GtfsRealtimeModule</optionalModulesList> -->                            
     	<!--<optionalModulesList>org.transitime.avl.GtfsRealtimeModule;org.transitime.custom.irishrail.NexalaAvlModule</optionalModulesList>-->
     	<optionalModulesList>org.transitime.custom.irishrail.NexalaAvlModule</optionalModulesList>
    </modules>
     
      <core>
	    <allowableEarlySecondsForInitialMatching>1200</allowableEarlySecondsForInitialMatching>
	    <allowableLateSecondsForInitialMatching>1200</allowableLateSecondsForInitialMatching>
	    <maxDistanceFromSegment>10000</maxDistanceFromSegment>	    
	    <maxPredictionsTimeSecs>7200</maxPredictionsTimeSecs>	    
	    <agencyId>02</agencyId>
    </core>	
    <avl>
        <!-- URL for GTFS realtime vechicle location stream -->
        <gtfsRealtimeFeedURI>http://0.0.0.0:8092/vehiclePositions</gtfsRealtimeFeedURI>        
	<gtfsRealtimeNexalaFeedURI>http://0.0.0.0:8091/vehiclePositions</gtfsRealtimeNexalaFeedURI>
        <minLongitude>-10.725</minLongitude>
        <maxLongitude>-5.35</maxLongitude>             
        <minLatitude>51.35</minLatitude>
        <maxLatitude>55.45</maxLatitude>                
        <feedPollingRateSecs>60</feedPollingRateSecs>
	<!-- Max Speed set to 62.6m/s=140mph -->
	<maxSpeed>62.6</maxSpeed>	
    </avl>   
    <db>
        <dbName>transitime</dbName>
        <dbHost>127.0.0.1:5432</dbHost>
        <dbType>postgresql</dbType>
        <dbUserName>ogcrudden</dbUserName>
        <dbPassword>password</dbPassword>
    </db>     
    <hibernate>
        <configFile>/home/ogcrudden/workspace/transitimeconfig/postgres_hibernate.cfg.xml</configFile>        
    </hibernate>
</transitime>
````
