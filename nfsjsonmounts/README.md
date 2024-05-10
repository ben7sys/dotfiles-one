# mounts

Dieses Skript ist ein Bash-Skript, das zum Einbinden von NFS-Shares (Network File System) aus einer JSON-Datei verwendet wird. Es wird zuerst die Existenz einer JSON-Datei überprüft und dann die darin enthaltenen Informationen verwendet, um die NFS-Shares einzubinden.

Zu Beginn des Skripts wird eine Variable JSON_FILE definiert, die den Namen der JSON-Datei enthält, die die Informationen über die NFS-Shares enthält.

Das Skript überprüft dann, ob die JSON-Datei existiert. Wenn die Datei nicht existiert, gibt das Skript eine Fehlermeldung aus und beendet sich mit einem Exit-Status von 1, was auf einen Fehler hinweist.

Wenn die JSON-Datei existiert, liest das Skript die Datei und verwendet das jq-Tool, um jedes Element in der JSON-Datei zu verarbeiten. jq ist ein Befehlslinien-JSON-Prozessor. Es nimmt JSON-Daten als Eingabe und kann sie in verschiedene Formate umwandeln.

Für jedes Element in der JSON-Datei extrahiert das Skript die Werte der NFS_SERVER, NFS_EXPORT, NFS_OPTIONS und LOCAL_NFS_MOUNT Felder und speichert sie in entsprechenden Variablen.

Das Skript erstellt dann das lokale Mount-Verzeichnis, falls es noch nicht existiert, mit dem mkdir -p Befehl. Der -p Schalter sorgt dafür, dass das Verzeichnis erstellt wird, wenn es noch nicht existiert.

Schließlich verwendet das Skript den mount-Befehl, um das NFS-Share einzubinden. Es verwendet die zuvor extrahierten Werte für den NFS-Server, den NFS-Export, die NFS-Optionen und das lokale NFS-Mount-Verzeichnis, um den mount-Befehl zu konstruieren und auszuführen.


**Projektentwurf**

Erstelle ein Script das sich mit Variablen anpassen lässt um ein NFS share zu mounten: 
Variablen:
NFS_SERVER:
NFS_EXPORT:
NFS_OPTIONS:hard,nolock,anonuid=1000,anongid=1000,vers=4
LOCAL_NFS_MOUNT:

Die Variablen sollen in einer json gespeichert werden damit mehrere Ziele hinzugefügt werden können.


**NFS Optionen**

hard: Diese Option gibt an, dass das System mehrere Versuche unternehmen soll, um eine Verbindung zu einem NFS-Server herzustellen, bevor es aufgibt. 
Wenn die Verbindung unterbrochen wird, wartet das System auf die Wiederherstellung der Verbindung, anstatt den Vorgang sofort abzubrechen.

nolock: Diese Option deaktiviert die Verwendung von NFS-Locks. 
NFS-Locks werden normalerweise verwendet, um sicherzustellen, dass Dateien nicht gleichzeitig von mehreren Clients geändert werden können. 
Durch das Deaktivieren dieser Option können mehrere Clients gleichzeitig auf dieselbe Datei zugreifen, was jedoch zu Inkonsistenzen führen kann, 
wenn mehrere Clients gleichzeitig Änderungen vornehmen.

anonuid=1000: Diese Option legt die Benutzer-ID (UID) fest, die für anonyme (nicht authentifizierte) Zugriffe auf den NFS-Server verwendet wird. 
In diesem Fall wird die UID 1000 verwendet.

anongid=1000: Diese Option legt die Gruppen-ID (GID) fest, die für anonyme Zugriffe auf den NFS-Server verwendet wird. 
In diesem Fall wird die GID 1000 verwendet.

vers=4: Diese Option gibt die Version des NFS-Protokolls an, 
das verwendet werden soll. In diesem Fall wird die Version 4 verwendet.