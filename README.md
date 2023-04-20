![Work in Progress](docs/assets/wip.png)
[![en](https://img.shields.io/badge/lang-en-red.svg)](README.md)
[![fr](https://img.shields.io/badge/lang-fr-blue.svg)](README.fr.md)
[![de](https://img.shields.io/badge/lang-de-green.svg)](README.de.md)
# What is it?

This is initial scaffolding for a 
* reactive Webapp for Life Insurance Contracts
* sporting bitemporal data management and
* pluggable product data

It is built with GenieBuilder, which at the moment cannot be used in GITPOD.
But the app can be run in GITPOD 
as shown below.
To run it under GenieBuilder You have to use a non-cloud computer. This app is not runnable in Genie Cloud, as it builds on postgres
and cannot be run with mysql.

## MVVM Architecture 
This app leverages the great [Genie Framework](https://genieframework.com/)
### Transactions

Transaction data are persistent. 

Transactions are started 
* implicitly on creation of entities
* explicitly on existing entities

Once a transaction is open
* mutations can be savepointed.
* mutations can be persisted, Persising deletes prior savepoints and makes the persisted state a savepoint.
* it can be 
    * committed - provided data integrity rules are complied.
    * rolled back.


# Getting ready

after firing up the workspace do the following (not yet done automatically):

## Starting the web server

- on julia command line enter:
- include("run.jl")
vscode opens a browser tab for the app.

BE PATIENT! Intialization takes some time. It gets reactive then!

Three contracts are preloaded: pension, SingleLifeRisk, JointLifeRisk
