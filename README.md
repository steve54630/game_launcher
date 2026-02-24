# 🎮 Game Launcher (2026 Edition)

Un lanceur de jeux vidéo moderne pour Windows, conçu avec **Flutter** en respectant strictement les principes de la **Clean Architecture**. Ce projet privilégie la séparation des responsabilités, l'immuabilité et la sécurité des données utilisateur.

---

## 🏗️ Architecture & Principes

Le projet suit une structure en couches pour garantir l'indépendance du code métier vis-à-vis des outils techniques (BDD, API, OS).

### 1. Domain (Le Coeur)

- **Entities** : Objets métier immuables (ex: `Game`, `DiscoveryResult`). Utilisation systématique du pattern `copyWith`.
- **Repositories** : Interfaces abstraites définissant les contrats de données et de services.
- **Use Cases** : Orchestration de la logique métier (ex: `LaunchGame`, `ScanLibrarySource`).

### 2. Data (L'implémentation)

- **Models** : Extensions des entités gérant le mapping JSON/SQL.
- **DataSources** : Implémentations techniques (SQLite pour la persistance, `Process` pour l'OS, `http` pour IGDB).
- **Mappers** : Conversion entre le `snake_case` (BDD/API) et le `camelCase` (Dart).

### 3. Presentation

- UI construite avec Flutter, pilotée par les Use Cases.

---

## 🛠️ Contraintes de Développement

- **Style de Code** : Aucune utilisation d'underscores (`_`) pour les variables ou paramètres Dart, afin de maintenir une nomenclature cohérente et fluide.
- **Immuabilité** : Les entités sont immuables pour éviter les effets de bord.
- **BYOK (Bring Your Own Key)** : Les clés API IGDB sont fournies par l'utilisateur et stockées de manière chiffrée en base de données.
- **Découplage Système** : Le lancement des exécutables et le scan de fichiers sont isolés dans un `ProcessRepository` pour séparer les interactions OS de la gestion de base de données.

---

## 📂 Structure des Dossiers

```text
lib/
├── core/
│   ├── providers/      # Injection de dépendances (Repository, UseCase, UI)
│   ├── theme/          # Design System (Colors, Spacing, Theme)
│   └── utils/          # DatabaseHelper, Logger, Extensions
├── domain/
│   ├── entities/       # Game, SearchResult, Credentials (Immuables)
│   ├── repositories/   # Interfaces (Contrats)
│   └── usecases/       # Logique métier (SaveGame, SearchGame...)
├── data/
│   ├── models/         # DTO & Mappers (fromMap, toMap)
│   ├── repositories/   # Implémentations (SQL, API, SecureStorage)
│   └── utils/          # ImageDownloader, QueryBuilder
└── presentation/
    ├── notifiers/      # Riverpod Notifiers & States
    ├── pages/          # Écrans principaux (Library, Import, Details)
    └── widgets/        # Composants UI découpés par domaine
```

---

## 🚀 Workflow d'Importation & Enrichissement

Le launcher utilise un pipeline d'importation sécurisé :

### Scan :

Exploration des répertoires via le ProcessRepository.

### Match :

Recherche asynchrone sur l'API IGDB avec gestion du token OAuth2 Twitch.

### Persistance Hybride :

Sauvegarde des données de jeu en SQLite.

Téléchargement parallèle des images vers le stockage local (ApplicationSupportDirectory).

Chiffrement des identifiants API via FlutterSecureStorage.

### Notification :

Mise à jour automatique de la vue via le StreamProvider de la bibliothèque.

---

## 🔑 Installation & Configuration

### Pré-requis

- Flutter SDK (2026+)

- Environnement de développement Windows Desktop

### Clés IGDB

Pour l'enrichissement automatique des métadonnées, vous devez configurer vos identifiants Twitch Developer :

- Client ID

- Client Secret

Ces clés sont chiffrées avant stockage pour garantir la sécurité du BYOK.

---

## 📝 Licence

Projet développé en mode "Dev First" - Clean Architecture & Robustesse.
