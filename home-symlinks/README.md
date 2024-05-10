# NFS Home Symlinks

Dieses Bash-Skript erstellt symbolische Links von bestimmten Verzeichnissen in einem NFS-Freigabeverzeichnis zu entsprechenden Verzeichnissen im Home-Verzeichnis eines Benutzers.

Hier ist eine Schritt-für-Schritt-Beschreibung des Skripts:

Zwei Pfadvariablen werden definiert: USER_HOME, das das Home-Verzeichnis des Benutzers darstellt, und NFS_SHARE, das das NFS-Freigabeverzeichnis darstellt.

Ein assoziatives Array LINK_DIRS wird deklariert, das die Namen der zu verlinkenden Verzeichnisse enthält. Der Schlüssel jedes Elements ist der Name des Verzeichnisses in der NFS-Freigabe, und der Wert ist der Name des entsprechenden Verzeichnisses im Home-Verzeichnis des Benutzers.

Eine Funktion namens link_directory wird definiert. Diese Funktion nimmt zwei Argumente: source_dir und target_dir. Sie überprüft, ob das Zielverzeichnis existiert und ein Verzeichnis ist. Wenn ja, wird es entfernt. Dann erstellt die Funktion einen symbolischen Link vom Quellverzeichnis zum Zielverzeichnis.

Schließlich durchläuft das Skript jedes Element im LINK_DIRS-Array und ruft die link_directory-Funktion auf, um einen symbolischen Link vom entsprechenden Verzeichnis in der NFS-Freigabe zum entsprechenden Verzeichnis im Home-Verzeichnis des Benutzers zu erstellen.

Am Ende des Skripts wird eine Nachricht ausgegeben, die anzeigt, dass das Setup abgeschlossen ist.