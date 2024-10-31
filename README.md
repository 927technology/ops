# 927 Operations Center

This solutionis aimed at automating tasks of deployment, compliace, and telemetry in complicated distributed systems.  Leveraging on the ability to dynamically determine best case location of resources base on multiple factors.   Resource deployments are capable of migrating to and from physical resources and to and from on-prem and external cloud infrastructures.

By using granular telemetry and flexable inputs, resources can be altered and migrated based on needs of the moment without intervention.


# Ops Engine

* Management Server
  * Build Container
    * [ ] Health Checker
    * [x] Engine
    * [x] Entrypoint 
    * [x] Poller
    * Resources
      * [x] Engine
      * [x] JSoN 
  * Pull Configuraiton  
    * [x] Global Configuration
    * [x] Infrastructure Configuration
  * Engine Configurations
    * [x] Parse Priovided Configurations
* Job Server
  * [x] Build Container
  * [ ] Pull Configuration
  * [ ] Pull Secrets
* Job Worker
  * [X] Build Container
  * [ ] Pull Configuraiton
  * [ ] Pull Secrets
  * Resouces
    * [ ] Cloud - AWS 
    * [ ] Cloud - Azure 
    * [x] Cloud - OCI
    * [x] JSoN
    * [ ] SNMP
    * [ ] Bare Metal Provisioning
    * [ ] On-Prem - Nutanix 
    * [ ] On-Prem - KVM
    * [ ] On-Prem - VMWare 
* Secrets
 * [ ] Move secrets from local to secrets provider

