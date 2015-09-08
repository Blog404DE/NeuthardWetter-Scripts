# NeuthardWetter-Scriptsammlung

Diese Scriptsammlung dient zur einfachen Abfrage mehrere Informationen, die im Rahmen der Grundversorgung durch den Deutschen Wetterdienst angeboten werden.

###Welche Scripte werden angeboten?

**genRainRadarBW.php:**
Ein Script zum erstellen von Regenradar-Videos für Deutschland und/oder eines bestimmten Bundeslandes im Format mp4, webm und als animierte GIF.

### Wichtiger Hinweis:
Bitte beachtet, dass die vom DWD bereitgestellten Daten dem Urheberrecht unterliegen. Bei Fragen zur Verwendung wendet euch sicherheitshalber an den Deutschen Wetterdienst direkt. 



## Anleitung für genRainRadarBW.php

### Vorraussetzungen:

- Linux (unter Debian getestet)
- PHP 5.5 (oder neuer) mit FTP-Modul einkompiliert
- libav-tools oder ffmpeg installiert (für mp4/webm-Videos)
- Imagemagick (für animierte gif-datei)
- Shell-Zugriff zum einrichten eines Cronjob

### Vorbereitung:

1. Registrierung beim Deutschen Wetterdienst für den Zugriff auf die Grundversorgungs-Daten. Die Registrierung ist kostenlos über http://kunden.dwd.de/gdsRegistration/gdsRegistrationStart.do möglich. Die Registrierung benötigt ausschließlich eine E-Mail Adresse und die Zustellung der Zugangsdaten für den FTP Server erfolgt in der Regel innerhalb einer Stunde

2. Installation der zusätzlich zu php benötigten Pakete:

	Debian/Ubuntu/Mint:
	
	```sh
	apt-get update
	apt-get install imagemagick libav-tools
	```

	RHEL/CentOS/Fedora
	
	```sh
	yum install ImageMagick ffmpeg
	```

### Konfiguration:

Damit das Script die Regenradar-Videos erzeugt, muss dieses konfiguriert werden. Die Konfigurationsparameter sehen wie folgt aus:

1. FTP Zugangsdaten für den Zugriff auf den DWD FTP Server.

	```php
	// FTP Zugangsdaten:
	$ftp["host"]        = "ftp-outgoing2.dwd.de";
	$ftp["username"]    = "gds******";
	$ftp["password"]    = "*********";
	```

	Die benötigten Zugangsdaten und den Hostnamen wird vom DWD per E-Mail nach der Registrierung (siehe Vorbereitung) mitgeteilt. Bei ```$ftp["username"]``` handelt es sich um den Benutzername und bei ```$ftp["password"]``` um das zugeteilte Passwort. Der Hostname ```$ftp["hostname"]``` muss in der Regel nicht angepasst werden.
	
2. Pfade zu den für das erstellen der Videos benötigten Konsolen-Programme 

	```php
	// Pfade zu Konsolenprogramme:
	$converter["video"] = "/usr/bin/ffmpeg";
	$converter["gif"]   = "/usr/bin/convert";
	```	

	Für ```$converter["video"]``` benötigt man den Pfad zur libav-tool oder ffmpeg Binary. Dies wird benötigt zum erstellen der webm/mp4-Videos.
	```$converter["gif"]```benötigt den Pfad zum convert-Tool aus dem Imagemagick-Paket. Diese Binary dient zum erstellen der animierten GIF-Datei.
	
	Möchte man z.B. keine animierte GIF Datei erzeugen, so empfiehlt sich anstatt des Pfad *false* als Wert zu hinterlegen: 
	```$converter["gif"] = false;```
	
3. Konfiguration der zu erstellenden Video-Dateien (Array):

	```php
$config[] = array(	"remoteFolder"  => "/gds/gds/specials/radar",
                  		"localFolder"   => "/srv/webspacepfad/radarDaten/de",
						"frames"        => "30",
						"output"        => array(	"webm" => "/srv/webspacepfad/htdocs/img/regenradar_de.webm",
                                           			"mp4"  => "/srv/webspacepfad/htdocs/img/regenradar_de.mp4",
													"gif"  => "/srv/webspacepfad/htdocs/img/regenradar_det.gif"),
						"posterFile"    => "/srv/webspacepfad/htdocs/img/regenradar_de.jpg",
						"forceRebuild"  => false
                  );
	```	
	Der Array-Wert ```"remoteFolder"``` für beinhaltet der Pfad auf dem DWD FTP Server welches die Radar-Daten beinhaltet. Der beispielhaft hinterlegte Pfad beinhaltet der Regenradar-Bilder für Deutschland. Es existieren in diesem Pfad auch Unterordner für einzelne Regionen innerhalb von Deutschland wie z.B. */gds/gds/specials/radar/southwest* für Süd/Westen von Deutschland (z.B. Baden-Würrtemberg).
	
	Als Gegenstück zum Pfad auf dem FTP Server dient ```"localFolder"```. Dieser Array-Wert beinhaltet ein lokaler Ordner, in dem die benötigten einzelnen Radar-Bilder durch das Script gespeichert werden. 
	
	Mit dem Array-Wert ```"frames"``` wird hinterlegt aus wievielen Einzelbilder die erzeugten Videos bestehen sollen. Als praktischer Wert hat sich 30 Einzelbilder herausgestellt. Dies deckt, bei Einzelbilder alle 5 Minuten durch den DWD, einen Zeitraum von 150 Minuten bzw. 2 1/2h ab. Abhängig von der Anzahl der Frames verändert sich die Laufzeit des Cronjobs. Um eine zu hohe Belastung des DWD FTP Server zu verhindern, werden maximal die Bilder der letzten 3h zur Verarbeitung herangezogen. Dieser Grenzwert ist hart im Script einprogrammiert. 
	
	```"output"``` ist der Dreh- und Angelpunkt für das erstellen der Videos und beinhaltet ein Array welches einerseits beinhaltet für welches Format (webm, mp4, gif) die Videos erzeugt werden sollen und den Ziel-Pfad in dem die Datei jeweils gespeichert werden soll. Im Beispiel werden die Videos in allen 3 verfügbaren Formate erstellt. Falls Sie z.B. die animierte GIF Datei nicht benötigen hinterlegen Sie anstatt des Zielpfad einfach *false*.
	
	Der vorletzte Konfigurationsparameter ```"posterFile"``` dient zum getrennten speichern des ersten im Video verwendeten Radar-Bild. Einige HTML5 Video-Player wie z.b. <http://www.videojs.com> verwenden eine Grafik für die schnelle Darstellung einer Grafik im Videoplayer noch bevor das Video heruntergeladen wurde. Sollte eine solche Poster-Datei nicht benötigt werden, verwenden Sie auch hier *false* als Parameter.
	
	```"forceRebuild"``` dient ausschließlich zu Test-Zwecken und dient dazu das Script anzuweisen auf jeden Fall alle Videos neu zu erstellen unabhängig davon, ob neue Radar-Bilder hinzugekommen sind. Standardmäßig sollte dieser Parameter auf *false* stehen.
	
	**Hinweis:** Um Videos für mehrere Bereiche in Deutschland zu erstellen, können Sie das ```$config[]``` Array entsprechend um weitere Einträge erweitern. Beispielhaft sind in der Beispiel-Konfiguration zwei Array-Elemente enthalten - jeweils für Süd/West-Deutschland und Gesamt-Deutschland.
	

### Das PHP-Script ausführbar machen und als Cronjob hinterlegen

1. Das konfigurierte Scripte startfähig machen

	```sh
	chmod +x genRainRadarBW.php
	```
	
2. Cronjob anlegen 

	```sh
	crontab -e
	```
	
	Als Update-Frequenz für die Videos hat sich alle 15 Minuten herausgestellt, auch wenn der DWD alle 5 Minuten neue Bilder hinterlegt. Bei der gewünschten Update-Frequenz sollte beachtet werden, dass das erzeugen der Videos je nach System einige Zeit beansprucht (insbesondere die animierte GIF Datei). Für ein ausführen des Cronjob alle 15 Minuten würde die Cronjob-Zeile wie folgt aussehen:
	```*/15 * * * * /pfad/zum/script/getRainRadarBW.php```
	

--
##### Lizenz-Information:

Copyright Jens Dutzi 2015 / Stand: 08.09.2015 / Dieses Werk ist lizenziert unter einer [MIT Lizenz](http://opensource.org/licenses/mit-license.php)

