![Work in Progress](docs/assets/wip.png)
[![en](https://img.shields.io/badge/lang-en-red.svg)](README.md)
[![fr](https://img.shields.io/badge/lang-fr-blue.svg)](README.fr.md)
[![de](https://img.shields.io/badge/lang-de-green.svg)](README.de.md)


## [installation and start](#3-installation-and-startup)

# Projekt GenieBuiltLifeProto
This project is an attempt to create a foundation for an open source system for managing life insurance policies by an insurer.

### 1. design goals

of this project are:

* performant and highly scalable web app for* dialog processing of insurance contracts and.
* provision of services for operation
* runnability on laptops as well as on servers
* use of cloud development environments 
* Use of collaboration platforms in the cloud
* Product-agnostic management system, i.e. maximum encapsulation of product-specific knowledge in product-specific components
  * bases of calclulation
  * Tariff functions
  * Metadata of tariff functions for use in interfaces for dialogs and services.
  * control and validation of inputs for product-specific business processes
* Use of an actuary-friendly development environment with regard to programming language and existing libraries
* Use of an application stack that is as coherent as possible and supports tests across all levels from actuarial functions to persistence to the browser, i.e. no environmental break, between actuarial product development of and development of the management system.
* Audit-proof storage of contracts through bitemporal persistence.

## 2. functional scope of the prototype

### 2.1 Functional scope API

Bitemporal CRUD actions for the entire data model.

### 2.2 Scope of functions WebUI

### 2.2.1 Functional area Search Contracts

#### Display a list of contract IDs.

<details>
<summary>screenshot: Contracts tab</summary>
<p>
<img src="docs/images/image1.png" alt="Contracts">
</p>
</details>
Clicking changes to the display of the latest contract version.

### 2.2.2 Contract version functional area

#### Displaying/editing contract versions.

Editing requires an active workflow (transaction). This is created by creating a new contract, or by opening a contract mutation.

Without a loaded contract, the button for creating a contract is displayed.
<details>
<summary>screenshot: Contract version: no contract loaded</summary>
<p>
<img src="docs/images/image2.png" alt="Contracts">
</p>
</details>
If an unprocessed contract has been selected in the search, the button to open a mutation will appear.
<details>
<summary>screenshot: Contract version: contract immutable</summary>
<p>
<img src="docs/images/image4.png" alt="Contracts">
</p>
</details>
In both cases, to open a workflow, the validity start date must be specified.
<details>
<summary>screenshot: Contract version: open contract workflow</summary>
<p>
<img src="docs/images/image3.png" alt="Contracts">
</p>
</details>
After that, the contract will appear as in process. 
<details>
<summary>screenshot: Contract version: contract mutable</summary>
<p>
<img src="docs/images/image6.png" alt="Contracts">
</p>
</details>
<details>
<summary>screenshot: Contract search: mutable contracts shown in red</summary>
<p>
<img src="docs/images/image6a.png" alt="Contracts">
</p>
</details>

This state remains until

* the workflow is rolled back or
* committed.

 Other workflow-related commands provide
  * push the state of changes onto a stack  
  * pop the state of changes from the stack  
  * persist the state of changes, which empties the stack of changes

<details >
<summary>screenshot: Contract version: Workflow Kommandos</summary>
<p>
<img src="docs/images/image7.png" alt="Contracts">
</p>
</details>
<br>

### 2.2.1 Funktionsbereich Contract Version - contract partners

Clicking opens the section for viewing / editing contractor relationships.

<details >
<summary>screenshot: Contract version: contract partners</summary>
<p>
<img src="docs/images/image8.png" alt="Contract partners">
</p>
</details>

If the contract is mutable.

* Selection of a contract partner role and
* a partner
  
activate the button to insert a new partner relationship].

<details>
<summary>screenshot: Contract version: partner role selection</summary>.
<p><img src="docs/images/image9.png" alt="select contract partner role"></p>
</details>
<details>
<summary>screenshot: Contract version: select partner</summary>
<p><img src="docs/images/image10.png" alt="select contract partner"></p>
</details>
</details>
<details>
<summary>screenshot: Contract version: button to insert a new partner relationship</summary>.
<p><img src="docs/images/image11.png" alt="add contract partner"></p>
</details>
<details>
<summary>screenshot: Contract version: new partner relationship added</summary>
<p><img src="docs/images/image12.png" alt="contract partner added"></p>
</details>

### 2.2.2 Contract version - product items functional area.

Clicking opens the section for viewing / editing product items.
<details>
<summary>screenshot: product items expanded</summary>.
<p>
<img src="docs/images/image13.png" alt="product items">
</p>
</details>
### 2.2.2.1 Contract version - product items - tariff items functional area.

Clicking opens the section for viewing / editing tariff items.

<details>
<summary>screenshot: Tariff items expanded</summary>
<p>
<img src="docs/images/image14.png" alt="tariff items">
</p>
</details>

Clicking the "select" button changes the button to "calculator"
<details>
<summary>screenshot: Tariff item selected </summary>
<p>
<img src="docs/images/image15.png" alt="tariff item selected">
</p>
</details>

Clicking the button "calculator" calculation window opens the calculation window:
<details>
<summary>screenshot: Tariff calculator started</summary>
<p>
<img src="docs/images/image16.png" alt="tariff item calculator">
</p>
</details> 
Different calculation targets can be specified.
<details>
<summary>screenshot: Tariff calculator started </summary>
<p>
<img src="docs/images/image17.png" alt="input calculation target">
</p>
</details>

After specifying the calculation target, the parameters can be entered.
<details>
<summary>screenshot: Calculation target specified</summary>
<p>
<img src="docs/images/image18.png" alt="calculation target determined">
</p>
</details>

Input dialog 

<details>
<summary>screenshot: Input dialog </summary>
<p>
<img src="docs/images/image19.png" alt="calculation target determined">
</p>
</details>


When all mandatory parameters are occupied, calculation can be performed.
<details>
<summary>screenshot: Calculation call </summary>
<p>
<img src="docs/images/image20.png" alt="calculation callable">
</p><p>
<img src="docs/images/image21.png" alt="calculation called">
</p>
</details>

Parameters and calculation result can be synchronized into the corresponding, i.e. existing if necessary, contract fields with the same name
<details>
<summary>screenshot: Synchronization with contract status</summary>.
<p>
<img src="docs/images/image22.png" alt="calculation callable">
</p>
</details>

### 2.2.2.1.1 Contract version - product items - tariff items - tariff item partners functional area.

Clicking opens the section for displaying / editing partner relationships for tariff items.
<details>
<summary>screenshot: Tariff item partners</summary>
<p>
<img src="docs/images/image23.png" alt="tariff item partners">
</p>
</details>

### 2.3 History functional area
Clicking a version node opens the version view
<details>
<summary>screenshot: Version selection</summary>
<p>
<img src="docs/images/image24.png" alt="choose uncommitted workflow">
</p>
<p>
<img src="docs/images/image6.png" alt="show uncommitted workflow">
</p>
<p>
<img src="docs/images/image25.png" alt="choose committed workflow">
</p>
<p>
<img src="docs/images/image4.png" alt="show committed workflow">
</p>
</details>

Retroactive mutations shadow previously entered mutations with the same or later effective date.
<details>
<summary>screenshot: Retroactive transaction</summary>.
<p>
<img src="docs/images/image26.png" alt="retroactive Transaction">
</p>
<p>
<img src="docs/images/image27.png" alt="select shadowed Transaction">
</p>
</details>

### 2.3.1 Search Partner functional area.
#### Display a list of partner IDs.

<details>
<summary>screenshot: Partners tab</summary>
<p>
<img src="docs/images/image28.png" alt="Partners">
</p>
</details>
Clicking changes to the display of the latest partner version.

### 2.3.2 Partners functional area

Display partner version.

The partner management is rudimentary. It contains only the tariff relevant partner data and editing is not possible in the webapp, only via the contract API [example: here ](testAPI.jl).
<details>
<summary>screenshot: Partner versions tab</summary>
<p>
<img src="docs/images/image29.png" alt="Partner">
</p>
</details>

### 2.3.3 Search Product functional area.
#### Display a list of product IDs.

<details>
<summary>screenshot: Products tab</summary>
<p>
<img src="docs/images/image30.png" alt="Products">
</p>
</details>
Clicking changes to the display of the latest partner version.

### 2.3.4 Functional area Product

Display product version 
The product management is rudimentary. It contains only the tariff relevant partner data and editing is not possible in the webapp, only via the contract API [example: here ](testAPI.jl).

#### 2.3.4.1 Product functional area - tariff parameters field.

The semantics of this field are clear from the tariff debugger scripts.

[Pension](https://github.com/Actuarial-Sciences-for-Africa-ASA/LifeInsuranceProduct.jl/blob/main/testCalPEN.jl)
[SingleLifeRisk](https://github.com/Actuarial-Sciences-for-Africa-ASA/LifeInsuranceProduct.jl/blob/main/testCalcSLR.jl)
[JointLifeRisk](https://github.com/Actuarial-Sciences-for-Africa-ASA/LifeInsuranceProduct.jl/blob/main/testCalcJLR.jl)

#### 2.3.4.2 Product functional area - contract attributes field

This field defines the dynamic attributes of the tariff items.

<details>
<summary>screenshot: Productversion tab</summary>
<p>
<img src="docs/images/image31.png" alt="Partner">
</p>
</details>

## 3 installation and startup

The package needs a POSTGRES database, the [configuration folder](db) and product data [see: testScript](testAPI.jl)
### 3.1 Start under gitpod

[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/Actuarial-Sciences-for-Africa-ASA/GenieBuiltLifeProto)

When the gitpod workspace is started, the database is pre-installed and three products / contracts are loaded. VS code is started.

### 3.1.1 Start Web Server

In the terminal view start Julia
    ``julia --project=.```
and load the start script>
 ```include("run.jl")```
Here you need some patience, the application will become reactive :-).

### 3.1.2 Start browser session

VS Code automatically starts a browser session. If not, the port display
 ``Menu -> View -> Open View -> Ports``
and click the port for the Application Web Server.

BE PATIENT! Initialization takes some time. It gets reactive then!

Three contracts are preloaded: pension, SingleLifeRisk, JointLifeRisk
