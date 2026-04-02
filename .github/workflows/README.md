# GitHub Actions Deployment

Diese GitHub Action baut automatisch die Anwendung und lädt sie per FTP auf deinen Webserver hoch.

## Einrichtung

Um die Action zu nutzen, musst du folgende Secrets in deinem GitHub Repository einrichten:

1. Gehe zu deinem GitHub Repository
2. Klicke auf "Settings" → "Secrets and variables" → "Actions"
3. Klicke auf "New repository secret" und füge folgende Secrets hinzu:

### Erforderliche Secrets

- **FTP_SERVER**: Die Adresse deines FTP-Servers (z.B. `ftp.example.com`)
- **FTP_USERNAME**: Dein FTP-Benutzername
- **FTP_PASSWORD**: Dein FTP-Passwort
- **FTP_SERVER_DIR**: Das Zielverzeichnis auf dem Server (z.B. `/public_html/` oder `/htdocs/`)
- **VITE_SUPABASE_URL**: Deine Supabase URL (aus `.env`)
- **VITE_SUPABASE_ANON_KEY**: Dein Supabase Anon Key (aus `.env`)

## Funktionsweise

Die Action wird automatisch ausgeführt bei:
- Jedem Push in den `main` Branch
- Jedem Merge eines Pull Requests in den `main` Branch

Die Action führt folgende Schritte aus:
1. Code auschecken
2. Node.js 20 installieren
3. Dependencies installieren (`npm ci`)
4. Projekt bauen (`npm run generate`)
5. Gebaute Dateien per FTP hochladen

## Wichtige Hinweise

- Die Action lädt nur neue und geänderte Dateien hoch
- Der Build-Output befindet sich in `.output/public/`
- Stelle sicher, dass alle Secrets korrekt eingerichtet sind, bevor du pushst
