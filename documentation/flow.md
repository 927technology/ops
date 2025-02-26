## Flow

|Role|Service|Task|
|:-|:-|:-|
|API|||
||Provides JSoN configuration||
|||Data can be updated via any mechanisms|
||||
|Management|||
||Ops engine||
|||Pull configuration from API|
|||Pull infrastructure from API|
||Poll API||
|||Update configuration from API|
|||Update infrastructure from API|
||Initalize job engine||
|||distribute jobs to workers|
|||collect data objects from workers|
||target jobs to job server||
|||Interpt data objects|
||web interface||
||Telemetry||
|||Alarm on insufficient values|
|||Track values|
||Remediate||
|||Action on known insufficient values|
||Infrastructure||
|||Provision new|
|||Destroy old|
|||Update existing|
||||
|Worker|||
||Process jobs||
|||Return data object|