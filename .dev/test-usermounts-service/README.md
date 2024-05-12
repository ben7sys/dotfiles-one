# usermounts-service

warning: CAUTION IN DEVELOPMENT!!

warning: NON WORKING VERSION

Dieses Bash-Skript dient dazu, bestimmte Verzeichnisse und Dateien für einen Service einzurichten. Es beginnt mit der Überprüfung, ob das Paket "findutils" installiert ist. Wenn es nicht installiert ist, gibt das Skript eine Fehlermeldung aus und beendet sich selbst.

Das Skript definiert dann einige Variablen, indem es eine Konfigurationsdatei namens ".conf" aus dem gleichen Verzeichnis wie das Skript selbst einliest. Es überprüft dann, ob die Variablen korrekt gesetzt sind, indem es sie auf der Konsole ausgibt und den Benutzer fragt, ob sie korrekt sind. Wenn der Benutzer mit "Nein" antwortet, fordert das Skript den Benutzer auf, die ".conf"-Datei zu bearbeiten und das Skript erneut auszuführen, und beendet sich dann.

Das Skript definiert dann eine Funktion namens "link_directory", die dazu dient, Verzeichnisse, einschließlich versteckter Dateien, von einem Quellverzeichnis zu einem Zielverzeichnis zu verlinken. Diese Funktion überprüft zunächst, ob das Zielverzeichnis existiert und erstellt es, wenn es nicht existiert. Dann verwendet es das "find"-Kommando, um durch alle Dateien und Verzeichnisse im Quellverzeichnis zu iterieren und für jedes Element einen symbolischen Link im Zielverzeichnis zu erstellen.

Das Skript ruft dann die "link_directory"-Funktion für jedes Verzeichnis in der "TARGET_DIRS"-Variable auf, wobei das Quellverzeichnis das entsprechende Verzeichnis im "dotfiles"-Verzeichnis und das Zielverzeichnis das entsprechende Verzeichnis im Home-Verzeichnis des Benutzers ist.

Schließlich überprüft das Skript, ob eine bestimmte systemd-Service-Datei existiert, und wenn ja, registriert es den Service, aktiviert ihn und startet ihn. Wenn die Datei nicht gefunden wird, gibt das Skript eine Fehlermeldung aus und beendet sich. Am Ende gibt das Skript eine Meldung aus, dass die Einrichtung abgeschlossen ist.