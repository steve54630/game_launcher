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
├── domain/
│   ├── entities/       # Game, DiscoveryResult, IgdbCredentials...
│   ├── repositories/   # Interfaces (GameRepository, ProcessRepository...)
│   └── usecases/       # Actions (AddGamesToLibrary, LaunchGame...)
├── data/
│   ├── models/         # Mapping SQL/JSON (fromMap, toMap)
│   ├── datasources/    # SQLite Helper, IGDB Client, System Explorer
│   └── repositories/   # Implémentations réelles des contrats
└── presentation/       # Widgets & State Management (BLoC/Provider/Signals)
```

---

## 🚀 Workflow d'Importation

Le launcher ne peuple pas la base de données automatiquement pour éviter les erreurs.

Scan : Le ProcessRepository explore un dossier et retourne des DiscoveryResult.

Review : L'utilisateur visualise les candidats (nom détecté + score de confiance).

Validation : Les jeux sélectionnés sont convertis en entités Game et persistés via le GameRepository.

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