# Configuration du projet Xcode - CoachApp

## 1. Créer le projet

1. Ouvre **Xcode**
2. `File` → `New` → `Project...` (⇧⌘N)
3. Choisis **iOS** → **App**
4. Configure :
   - **Product Name** : `CoachApp`
   - **Organization Identifier** : `com.tonnom` (ou ton identifiant)
   - **Interface** : SwiftUI
   - **Language** : Swift
   - **Storage** : None (on ajoutera SwiftData plus tard)
   - **Testing System** : Swift Testing
5. **Enregistre dans** : `/Users/johan/Documents/code/BodyArtApp/`

## 2. Supprimer les fichiers générés par défaut

Xcode va créer ses propres `ContentView.swift` et `CoachAppApp.swift`.
Supprime-les du projet : clic droit → Delete → Move to Trash

## 3. Ajouter les fichiers sources

1. Clic droit sur le dossier `CoachApp` dans le navigateur Xcode
2. `Add Files to "CoachApp"...`
3. Navigue vers `/Users/johan/Documents/code/BodyArtApp/CoachApp/`
4. Sélectionne les dossiers :
   - `App/`
   - `Core/`
   - `Features/`
5. Options :
   - **Copy items if needed** : ❌ NON (décoché)
   - **Create groups** : ✅ OUI
6. Clique **Add**

## 4. Ajouter les tests

1. Sélectionne le target **CoachAppTests** dans le navigateur
2. `Add Files to "CoachAppTests"...`
3. Ajoute le dossier `Tests/`
4. Options :
   - **Copy items if needed** : ❌ NON
   - **Create groups** : ✅ OUI

## 5. Configurer iOS 17 minimum

1. Sélectionne le projet dans le navigateur (icône bleue en haut)
2. Sélectionne le target `CoachApp`
3. Onglet **General**
4. **Minimum Deployments** : `iOS 17.0`

## 6. Lancer l'app

1. Sélectionne un simulateur : **iPhone 15** (ou autre)
2. Appuie sur **▶** ou `⌘R`

## Structure des fichiers

```
CoachApp/
├── App/
│   ├── CoachAppApp.swift      # Point d'entrée @main
│   └── ContentView.swift      # TabView principal
├── Core/
│   ├── Models/
│   │   ├── ExerciseSet.swift
│   │   ├── Program.swift
│   │   └── WorkoutSession.swift
│   └── Services/
│       └── ProgramService.swift
├── Features/
│   ├── Programs/
│   │   ├── ViewModels/
│   │   │   └── ProgramListViewModel.swift
│   │   └── Views/
│   │       └── ProgramListView.swift
│   └── Workout/
│       ├── ViewModels/
│       │   └── ExecuteProgramViewModel.swift
│       └── Views/
│           └── ExecuteProgramView.swift
└── Tests/
    ├── ProgramListViewModelTests.swift
    └── ExecuteProgramViewModelTests.swift
```

## Dépannage

### "No such module" error
→ Vérifie que tous les fichiers sont bien ajoutés au target `CoachApp`

### Tests ne compilent pas
→ Vérifie que les fichiers Tests sont ajoutés au target `CoachAppTests` et non `CoachApp`

### iOS 17 APIs not available
→ Vérifie que le Minimum Deployment est bien iOS 17.0
