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
  * [ ] Pull Configuration
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
          * [ ] Powershell
        * Network
          * [ ] SNMP
          * [ ] Trap
      * [ ] Data Normalization 
    * Resouces
      * [ ] Cloud CLI - AWS 
      * [ ] Cloud CLI - Azure 
      * [x] Cloud CLI - OCI
      * [x] JSoN
      * [ ] SNMP
      * [ ] PowerShell
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
 

## Locally Build 927 Operations Centeer
```
cd build
docker build -t 927technology/ops-ms:0.1.17 .
```

## Start 927 Operations Center
```
docker run -name ops-ms --hostname ops-ms -v ${HOME}/secrets:/etc/927/secrets -v ${HOME}/configuraitons:/etc/927/configurations -d 927technology/ops-ms:0.1.17
```

## Access 927 Operatons Center
http://<ip address>/thruk
