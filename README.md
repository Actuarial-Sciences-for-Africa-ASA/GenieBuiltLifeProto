# What is it?

This is initial scaffolding for a 
* reactive Webapp for Life Insurance Contracts
* sporting bitemporal data management and
* pluggable product data

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

This is a is a wrapper project to allow running GenieBuilder on gitpod, namely my project

https://github.com/michaelfliegner/geniebuiltlifeproto

# Getting ready

after firing up the workspace do the following (not yet done automatically):

## Initializing the environment

at the terminal prompt enter:

- julia --project=.

  - on julia command line enter:
    - ] instantiate
      - wait for the precompiler, then
      - type BACKSPACE to return from package mode

## Populating the data base

- on julia command line enter:
  - include("testAPI.jl")
  - wait for the script to populate the data base

## Starting the web server

- on julia command line enter:
- include("app.jl")
- using GenieFramework
- Server.up()
- and then You open the ports view clicking Ports at the lower right corner of the editor window and open the browser
