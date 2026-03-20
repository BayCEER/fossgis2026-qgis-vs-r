# QGIS vs. R

Demo zur schrittweise Umsetzung einer räumlichen 2D-Standortanalyse in R und in QGIS.

# Aufgabenstellung

**"Ermittle potentielle Standorte für eine Mülldeponie im Stadtgebiet von Bayreuth"**

# Daten

- [ALKIS® Verwaltungsgebiete von Bayern - Komplettdatensatz](https://geodaten.bayern.de/opengeodata/OpenDataDetail.html?pn=verwaltung),"Bayerische Vermessungsverwaltung – www.geodaten.bayern.de", CC BY 4.0
- [Digitale Geologische Karte von Bayern 1:25.000 (dGK25) - Komplettdatensatz](https://www.umweltatlas.bayern.de/mapapps/resources/apps/umweltatlas/index.html?lang=de&layers=lfu_domain-geologie,service_geo_vt3,14;lfu_domain-geologie,service_geo_vt3,15;lfu_domain-geologie,service_geo_vt3,16&center=685990,5513914,25832&scale=72224). 'Datenquelle: Bayerisches Landesamt für Umwelt, www.lfu.bayern.de', CC BY 4.0
- [Digitales Geländemodell 1m (DGM1)](https://geodaten.bayern.de/opengeodata/OpenDataDetail.html?pn=dgm1),"Bayerische Vermessungsverwaltung – www.geodaten.bayern.de", CC BY 4.0
- [OpenStreetMap for the region of Oberfranken](https://download.geofabrik.de/europe/germany/bayern/oberfranken.html) , 'Data processed by Geofabrik GmbH and created by OpenStreetMap Contributors | License: ODbL 1.0'

Bitte entpacken sie die Datei [Data.zip](https://cloud.bayceer.uni-bayreuth.de/index.php/s/7qvWF9zqj4UV4aU/download) in das lokale [Data Verzeichnis.](Data/)

# Standortkriterien

- Positiv
  - wasserundurchlässiger geologischer Untergrund
  - Flächengröße > 4 ha
- Negativ
  - Abstand zu Straßen (25 m)
  - Abstand zu Gewässer (50 m)
  - Abstand zu Gebäuden (150 m)
- Wünschenswert
  - Hangneigung zwischen 2 und 4 %

# Realisierung

## QGIS

Die Analyse ist in mehrere Teile aufgeteilt. Zur Ausführung der gesamten Analyse fasst das Model [StandortSuche.model3](Standortsuche.model3) alle Teilmodelle zusammen.

| Teil-Model            | Analyseschritt                   |
| --------------------- | -------------------------------- |
| Positive Areas.model3 | Berechnung der positiven Flächen |
| Negative Areas.model3 | Berechnung der negativen Flächen |
| Analysis I.model3     | Potentielle geeignete Flächen    |
| Analysis II.model3    | Geologie der pot. Flächen        |
| Analysis III.model3   | Hangneigung der pot. Flächen     |

**Weitere Models**
| Model | Beschreibung |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Build Virtual Raster.model3 | Erzeugen eines Virtuellen Raster Layers aus mehreren Raster Tiles. Erfordert die Installation von [getFileListFromFolder.py](getFileListFromFolder.py) als Algorithm |
| OSM Download.model3 | Download von OpenStreetMap Daten mit QuickOSM Plugin |

## R

Die gesamte Analyse befindet sich im Skript [StandortSuche.R](Standortsuche.R)
