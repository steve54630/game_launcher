# 📜 Cahier des Charges : Game Launcher Flutter (Windows)

## 1. Objectif du Projet
Développer un lanceur de jeux vidéo léger et performant pour Windows, permettant de centraliser des jeux locaux, de suivre les statistiques de jeu et d'enrichir la bibliothèque via des métadonnées externes.

## 2. Principes de Développement (Hard Rules)
* **Architecture** : Clean Architecture stricte (Domain, Data, Presentation).
* **Style de Code** : 
    * **Zéro Underscore** : Aucune variable ou paramètre en Dart ne doit comporter d'underscore (`_`).
    * **Immuabilité** : Utilisation de classes immuables avec le pattern `copyWith`.
* **Sécurité** : Approche **BYOK** (Bring Your Own Key). Les clés API IGDB sont fournies par l'utilisateur et stockées de manière chiffrée en base de données.
* **Performance** : Découplage total entre la gestion de la base de données et les appels système (OS).

## 3. Spécifications Fonctionnelles

### A. Découverte & Bibliothèque
* **Scan Intelligent** : Exploration des dossiers locaux via une heuristique pour détecter les exécutables (`.exe`).
* **Validation Manuelle** : Les résultats du scan sont présentés à l'utilisateur avec un score de confiance avant tout ajout en base de données.
* **CRUD Bibliothèque** : Ajout, suppression et édition des jeux.

### B. Gestion du Temps de Jeu
* **Tracking** : Enregistrement du temps de jeu total (`playtimeSeconds`).
* **Historique** : Suivi de la date et de l'heure du dernier lancement (`lastPlayedAt`).
* **Exécution** : Lancement des jeux de manière asynchrone via le système d'exploitation sans blocage de l'UI.

### C. Métadonnées (Enrichissement)
* **API IGDB** : Recherche et récupération des jaquettes (Covers), synopsis, screenshots et trailers (YouTube ID).
* **Mise en cache** : Stockage local des informations pour permettre une navigation hors-ligne fluide.

## 4. Spécifications Techniques (Domain Layer)

### Entités
- `Game` : Propriétés du jeu (ID, chemin, temps de jeu).
- `DiscoveryResult` : Candidat trouvé lors d'un scan (nom brut, score).
- `LibrarySource` : Dossiers configurés pour le scan.
- `IgdbSearchResult` : Données brutes issues de la recherche API.
- `IgdbCredentials` : Clés API Client ID et Secret.

### Contrats (Repositories)
- **GameRepository** : CRUD SQLite pour les jeux.
- **LibrarySourceRepository** : Gestion des dossiers sources.
- **ProcessRepository** : Interaction OS (Scan FS, `Process.run`).
- **IgdbRepository** : Communication avec l'API externe.
- **CredentialsRepository** : Gestion du stockage chiffré des clés.

## 5. Flux de Travail (Workflow)
1. **Source** : L'utilisateur définit un dossier de recherche.
2. **Scan** : Le `ScanLibrarySource` parcourt le disque via le `ProcessRepository`.
3. **Review** : L'utilisateur sélectionne les jeux valides dans une liste filtrée par score.
4. **Import** : Le `AddGamesToLibrary` crée les entités `Game` et les persiste.
5. **Jeu** : Le `LaunchGame` ouvre l'exécutable et met à jour les stats en BDD.