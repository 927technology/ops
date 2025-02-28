# 927 Operations Center

This solution is aimed at automating tasks of deployment, compliace, and telemetry in complicated distributed systems.  Leveraging on the ability to dynamically determine best case location of resources base on multiple factors.   Resource deployments are capable of migrating to and from physical resources and to and from on-prem and external cloud infrastructures.

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
      * [x] Web Server
        * [ ] TLS 
      * [x] JSoN
  * Pull Configuraiton  
    * [x] Global Configuration
    * [x] Infrastructure Configuration
  * Engine Configurations
    * [x] Parse Priovided Configurations

* Job Server
  * [x] Build Container
  * [x] Pull Configuration
  * [ ] Pull Secrets

* Job Worker
  * Build Container
    * Ingestion
      * Bulk Data Collection
        * Cloud
          * [ ] Cloud CLI/API
        * On-Prem
          * [ ] VM SDK
          * [ ] VM CLI
          * [x] Powershell
        * Network
          * [x] SNMP
          * [x] Trap
      * [ ] Data Normalization 
    * Resouces
      * [ ] Cloud CLI - AWS 
      * [ ] Cloud CLI - Azure 
      * [x] Cloud CLI - OCI
      * [x] JSoN
      * [x] SNMP
      * [x] PowerShell
      * [x] Ansible
      * [ ] Bare Metal Provisioning
      * [ ] On-Prem - Nutanix 
      * [ ] On-Prem - KVM
      * [ ] On-Prem - VMWare 
    * Pull Configuraiton
      * [ ] Worker Configuration
      * [ ] TLS
      * [ ] Pull Secrets

* Identity Service
  * [ ] Authentication

* Secrets
   * [ ] Move secrets from local to secrets provider
 
* Library
    * [x] Migrate libraries to 927 library repo

## Locally Build 927 Operations Center
```
cd build
docker build -t 927technology/ops-ms:latest .
```

## Start 927 Operations Center
```
./run.sh
```

## Access 927 Operatons Center
http://\<ip address\>/thruk

## Documentation
[Understanding Ops Flow](./documentation/flow.md)

