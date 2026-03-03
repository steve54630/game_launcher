# 📜 Cahier des Charges : Game Launcher (Windows)

## 1. Objectif du Projet

Développer un lanceur de jeux vidéo léger et performant pour Windows, permettant de centraliser des jeux locaux, de suivre les statistiques de jeu et d'enrichir la bibliothèque via des métadonnées externes (IGDB).

## 2. Principes de Développement (Hard Rules)

- **Architecture** : Clean Architecture stricte (**Domain**, **Data**, **Presentation**).
- **Style de Code** :
  - **Zéro Underscore** : Aucune variable ou paramètre en Dart ne doit comporter d'underscore (`_`).
  - **Immuabilité** : Utilisation systématique de classes immuables avec le pattern `copyWith`.
- **Sécurité (BYOK)** : Approche "Bring Your Own Key". Les clés API IGDB sont fournies par l'utilisateur et gérées de manière isolée.
- **Performance** : Découplage total entre la gestion SQLite et les appels système (OS). Utilisation de sélecteurs Riverpod pour optimiser le rendu des listes.

## 3. Architecture de la Base de Données (SQLite)

_Note : Les underscores sont autorisés exclusivement au sein du schéma SQL._

```sql
-- 1. Référentiel des Genres
CREATE TABLE genres (
    id INTEGER PRIMARY KEY, -- ID officiel IGDB
    name TEXT NOT NULL UNIQUE
);

-- 2. Cache des métadonnées IGDB
CREATE TABLE igdb_cache (
    igdb_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    cover_url TEXT,
    summary TEXT,
    screenshot_urls TEXT, -- Liste JSON des URLs
    video_id TEXT,        -- YouTube ID
    release_date TEXT,    -- ISO8601 String
    genre_id INTEGER,     -- FK vers genres
    updated_at TEXT NOT NULL,
    FOREIGN KEY (genre_id) REFERENCES genres (id) ON DELETE SET NULL
);

-- 3. Bibliothèque des jeux locaux
CREATE TABLE games (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    igdb_id INTEGER,
    executable_path TEXT NOT NULL UNIQUE,
    playtime_seconds INTEGER DEFAULT 0,
    last_played_at TEXT,
    is_favorite INTEGER DEFAULT 0,
    FOREIGN KEY (igdb_id) REFERENCES igdb_cache (igdb_id) ON DELETE SET NULL
);

-- 4. Configuration du Scan
CREATE TABLE library_sources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT NOT NULL UNIQUE,
    last_scan_at TEXT NOT NULL
);

-- 5. Paramètres généraux
CREATE TABLE app_settings (
    key TEXT PRIMARY KEY,
    value TEXT
);
```

## 4. Spécifications Fonctionnelles

### A. Scan & Découverte

- **Analyse asynchrone** : Parcours des dossiers sources pour identifier les exécutables (`.exe`).
- **Pattern Discovery** : Utilisation de l'entité `DiscoveryResult` pour gérer l'état intermédiaire (statuts : `pending`, `searching`, `matched`).
- **Matching Auto** : Association automatique au premier résultat IGDB basé sur le nom du fichier nettoyé (`effectiveSearchTerm`).

### B. Bibliothèque & Statistiques

- **Tracking** : Enregistrement du temps de jeu total en secondes.
- **Lancement** : Exécution asynchrone via le système d'exploitation sans blocage de l'UI (ShellExecute).

### C. Métadonnées (IGDB)

- **Enrichissement** : Récupération des jaquettes, synopsis, screenshots et vidéos via l'API IGDB.
- **Navigation Offline** : Priorité au `igdb_cache` pour garantir une interface instantanée même sans connexion internet.

## 5. Workflow Technique (Architecture Flux)

1.  **Scan** : `LibraryScanUseCase` génère une liste de `DiscoveryResult` à partir du système de fichiers.
2.  **Auth** : Récupération des credentials IGDB depuis le stockage sécurisé (système BYOK).
3.  **Matching** : `IgdbRepository.search(credentials, term)` enrichit les résultats en arrière-plan sans bloquer l'UI.
4.  **Validation** : L'utilisateur confirme la sélection et la correspondance IGDB dans la vue d'import.
5.  **Persistance** : Transformation des entités en `GameModel` et exécution d'un `batch` SQLite pour sauvegarder le jeu et mettre en cache ses métadonnées.
