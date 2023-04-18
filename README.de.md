# Projekt GenieBuiltLifeProto

Bei diesem Projekt handelt es sich um einen Versuch, eine Grundlage für ein Open Source System zur Verwaltung von Lebensversicherungen durch einen Versicherer zu erstellen.


## Entwurfsziele

dieses Projekts sind:
* performante und hoch skalierende  Web App zur
    * Dialogbearbeitung von Versicherungsverträgen und
    * Bereitstellung von Services für den Betrieb
* Lauffähigkeit auf Laptops wie auf Servern
* Nutzung von Cloud Entwicklungsumgebungen 
* Nutzung von Kooperationsplattformenin der Cloud
* Produkt-agnostisches Verwaltungssystem, d.h. maximale Kapselung produktspezifischen Wissens in produktspezifischen Komponenten
    * Rechnungsgrundlagen
    * Tariffunktionen
    * Metadaten tariflicher Funktionen zur Nutzung in Schnittstellen für Dialoge und Services.
    * Steuerung und Validierung von Eingaben für produktspezifische Geschäftsprozesse
* Verwendung einer aktuarsfreundlichen Entwicklungsumgebung hinsichtlich Programmiersprache und vorhandenen Bibliotheken
* Verwendung eines möglichst kohärenten Anwendungs-Stacks, der Tests über alle Ebenen von aktuariellen Funktionen über Persistenz bis zum Browser unterstützt, d.h. kein Umgebungsbruch, zwischen aktuarieller Produktentwicklung von und Entwicklung des Verwaltungssystems.
* Revisionssichere Speicherung von Verträgen durch bitemporale Persistierung

## Funktionsumfang des Prototyps

### Funktionsumfang API

Bitemporale CRUD- Aktionen für das gesamte Datenmodell.

### Funktionsumfang WebUI

#### Funktionsbereich Search Contracts

#### Anzeige einer Liste von Vertrags-IDs.

<details >
<summary>Sbcreenshot anzeigen: Contracts tab</summary>
<p>
<img src="docs/images/image1.png" alt="Contracts">
</p>
</details>

Anklicken wechselt in die Anzeige der neuesten Vertragsversion.

#### Funktionsbereich Contract Version

Anzeige / Bearbeitung von Vertragsversionen.

Das Bearbeiten erfordert einen aktiven Workflow (Transaktion). Dieser entsteht durch Anlegen eines neuen Vertrags, oder durch Eröffnen einer Vertragsmutation.

Ohne geladenen Vertrag wird der Button zum Anlegen eines Vertrages angezeigt.



<p id="gdcalert2" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image2.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert3">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image2.png "image_tooltip")




<p id="gdcalert3" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image3.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert4">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image3.png "image_tooltip")


Wurde ein unbearbeiteter Vertrag in der Suche ausgewählt worden, erscheint der Button zum Eröffnen einer Mutation.



<p id="gdcalert4" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image4.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert5">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image4.png "image_tooltip")


In beiden Fällen muss der Gültigkeitsbeginn angeben werden. Danach erscheint der Vertrag als in Bearbeitung. 

<p id="gdcalert5" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image5.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert6">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image5.png "image_tooltip")


Dieser Zustand bleibt erhalten bis der Workflow abgebrochen (rollback) oder vollendet wird (commit).



<p id="gdcalert6" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image6.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert7">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image6.png "image_tooltip")
Danach wird ie Version als in Bearbeitung angezeigt:


#### Funktionsbereich History


#### Funktionsbereich Search Partners


#### Funktionsbereich Partner


#### Funktionsbereich Search Product


#### Funktionsbereich Product
