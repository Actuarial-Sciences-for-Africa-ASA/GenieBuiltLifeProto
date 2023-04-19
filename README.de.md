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

Anzeige einer Liste von Vertrags-IDs.

<details >
<summary>Screenshot anzeigen: Search contract tab</summary>
<p>
<img src="docs/images/image1.png" alt="Contracts">
</p>
</details>

Anklicken wechselt in die Anzeige der neuesten Vertragsversion.

#### Funktionsbereich Contract Version

Anzeige / Bearbeitung von Vertragsversionen.
Wurde ein unbearbeiteter Vertrag in der Suche ausgewählt worden, erscheint der Button zum Eröffnen einer Mutation.
<details >
<summary>Screenshot anzeigen: Contract Version tab: contract immutable</summary>
<p>
<img src="docs/images/image4.png" alt="unbearbeitet Vertrag">
</p>
</details>
Wurde kein Vertrag in der Suche ausgewählt, erscheint der Button zum Anlegen eines Vertrages.
<details >
<summary>Screenshot anzeigen: Contract version tab: no contract loaded</summary>
<p>
<img src="docs/images/image2.png" alt="Contracts">
</p>
</details>
Bei Start einer Bearbeitung muss der Gültigkeitsbeginn angeben werden. 
<details >
<summary>Screenshot anzeigen: Contract version tab: start creation or mutation</summary>
<p>
<img src="docs/images/image3.png" alt="Contracts">
</p>
</details>
Danach erscheint der Vertrag als in Bearbeitung.
<details >
<summary>Screenshot anzeigen: Contract version tab: mutable</summary>
<p>
<img src="docs/images/image6.png" alt="Contracts">
</p>
</details>
Die Workflow wird persisitiert, d.h. der Zustand mutabel bleibt erhalten bis der Workflow abgebrochen (rollback) oder vollendet wird (commit).
Änderungsstände können mehrfach zwischengespeichert und wiederhergestellt werden, um z.B. Varianten zu vergleichen. Der Änderungsstand kann auch vor Commit des Workflows persistiert werden. Zwischenstände gehen dann verloren. 
<details >
<summary>Screenshot anzeigen: Contract version: Workflow commands</summary>
<p>
<img src="docs/images/image7.png" alt="Contracts">
</p>
</details>
Danach wird ie Version als in Bearbeitung angezeigt:

#### Funktionsbereich History

#### Funktionsbereich Search Partners

#### Funktionsbereich Partner

#### Funktionsbereich Search Product

#### Funktionsbereich Product
