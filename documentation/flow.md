# Roles

|-|-|-|
|API|||
||Provides JSoN configuration||
     |||↳|Data can be updated via any mechanisms|

[Ops Management Server]
  ↳ Initalize ops engine
     ↳ Pull configuration from API
     ↳ Pull infrastructure from API
  ↳ Poll API
     ↳ Update configuration 
     ↳ Update infrastructure 
  ↳ Initalize job engine
     ↳ distribute jobs to workers
     ↳ collect data objects from workers
     ↳ target jobs to job server
     ↳ Interpt data objects
  ↳ initalize web interface
  ↳ Telemetry
     ↳ Alarm on insufficient values
  ↳ Remediate
     ↳ action on known insufficient values
  ↳  Infrastructure 
     ↳ Augment infrastructure to given configuration 
        ↳  Provision new
        ↳  Destroy old
        ↳  Update existing

[Ops Worker Nodes]
  ↳  Process jobs
  ↳  Return data object