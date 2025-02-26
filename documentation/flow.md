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

The API can be any source that provides a JSoN object with the correct schema.  This object can be generated manually, via AI, or any other mechanisms.  The API is not provided by this project.  This project only consumes the data and specifies the schema of the API's output.  For our test, a manually generated json is used.

The Management Server interprets the data object and populates the configuration and infrastructure databases at initialization.  These databases are updated on a polling cycle from new data objects offered by the API.  Candidate data objects are parsed and validated.  Once validation is completed the new values are imported into the running database.

The management server hosts the job engine.  Host and service checks are disseminated to the workers.  Workers process the job and return status objects to the management server.  On an event, the management server will queue a remediation job and that will be processed by a worker.

The management server will host a web interface.  This interface will display data objects, host and service check values, and historical graphs of telemetry state.

Workers process jobs and return data objects to the job wngine.  Workers can be single or clustered.  Workers can exist in remote locations behind network boundaries, provided they have callback ability to the job server.  w9rker communication is secure with SSH communication on port 4730/tcp.  Jobs can target workers based on criteria ensuring boundaries are observed.

Workers communicate with on prem and cloud management platforms.  Using API tooling to perform telemetry gathering and infrastructure changes.  For hosts not managed by a platform, special workers can be deployed to perform deployments.  Checks can be directly made to a host via SSH or an installed agent.

All roles are performed by a singular container image.  This helps reduce disk space when multiple roles are on a host.  Only delta layers for additional instances consume disk space beyond the initial image footprint.