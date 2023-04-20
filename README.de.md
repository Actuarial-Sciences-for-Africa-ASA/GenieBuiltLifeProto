[![Work in Progress](docs/assets/wip.png)](README.md)
[![en](https://img.shields.io/badge/lang-en-red.svg)](README.md)
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
<summary>screenshot: Contracts tab</summary>
<p>
<img src="docs/images/image1.png" alt="Contracts">
</p>
</details>
Anklicken wechselt in die Anzeige der neuesten Vertragsversion.

#### Funktionsbereich Contract Version

Anzeige / Bearbeitung von Vertragsversionen.

Das Bearbeiten erfordert einen aktiven Workflow (Transaktion). Dieser entsteht durch Anlegen eines neuen Vertrags, oder durch Eröffnen einer Vertragsmutation.

Ohne geladenen Vertrag wird der Button zum Anlegen eines Vertrages angezeigt.
<details >
<summary>screenshot: Contract version: no contract loaded</summary>
<p>
<img src="docs/images/image2.png" alt="Contracts">
</p>
</details>
Wurde ein unbearbeiteter Vertrag in der Suche ausgewählt worden, erscheint der Button zum Eröffnen einer Mutation.
<details >
<summary>screenshot: Contract version: contract immutable</summary>
<p>
<img src="docs/images/image4.png" alt="Contracts">
</p>
</details>
In beiden Fällen muss zur Eröffnung eines Workflows der Gültigkeitsbeginn angeben werden.
<details >
<summary>screenshot: Contract version: open contract workflow</summary>
<p>
<img src="docs/images/image3.png" alt="Contracts">
</p>
</details>
Danach erscheint der Vertrag als in Bearbeitung. 
<details >
<summary>screenshot: Contract version: contract mutable</summary>
<p>
<img src="docs/images/image6.png" alt="Contracts">
</p>
</details>

Dieser Zustand bleibt erhalten bis
- der Workflow abgebrochen (rollback) oder
- vollendet wird (commit)
- Weitere workflow-bezogene Kommandos bieten
    - Kellern des Änderungsstandes (push)
    - Zurückholen des Änderungsstandes (pop)
    - Persistieren des Änderungsstandes (persist). Nach dem Persistieren 
ist der Ändderungskeller leer.
<details >
<summary>screenshot: Contract version: Workflow Kommandos</summary>
<p>
<img src="docs/images/image7.png" alt="Contracts">
</p>
</details>

##### Funktionsbereich Contract Version - contract partners
Anklicken öffnet den Abschnitt zur Anzeige / Bearbeitung von Vertragspartnerbeziehungen.

##### Funktionsbereich Contract Version - product items
Anklicken öffnet den Abschnitt zur Anzeige / Bearbeitung von Produktpositionen.

##### Funktionsbereich Contract Version - product items - tariff items

Anklicken öffnet den Abschnitt zur Anzeige / Bearbeitung von Tarifpositionen.

###### Funktionsbereich Contract Version - product items - tariff items - tariff item partners

Anklicken öffnet den Abschnitt zur Anzeige / Bearbeitung von Partnerbeziehungen zu Tariffpositionen.

#### Funktionsbereich History

#### Funktionsbereich Search Partner

### Funktionsbereich Partner

#### Funktionsbereich Search Product

#### Funktionsbereich Product
