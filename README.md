# BodyArtApp

Application iOS pour coachs sportifs et adhérents d'associations sportives.

## Fonctionnalités

### Pour les coachs
- **Créer des programmes** d'entraînement personnalisés
- **Ajouter des exercices** avec durée, temps de repos et nombre de tours
- **Partager** les programmes en les rendant publics

### Pour les adhérents
- **Consulter** les programmes publics disponibles
- **Exécuter** les programmes avec un timer interactif
- **Suivre** le déroulement (travail/repos) avec retour haptique

---

## Captures d'écran des fonctionnalités

### 1. Liste des programmes (Tab "Programmes")

```
┌─────────────────────────────────┐
│  Programmes publics             │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │ HIIT Débutant             │  │
│  │ Programme d'initiation... │  │
│  │ 5 exos · 15 min           │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ Cardio Intense            │  │
│  │ Travail cardiovasculaire  │  │
│  │ 4 exos · 20 min           │  │
│  └───────────────────────────┘  │
│                                 │
├─────────────────────────────────┤
│ [Programmes] [Créer] [Profil]   │
└─────────────────────────────────┘
```

**Navigation :** Appuyer sur un programme → voir les détails → démarrer l'entraînement

---

### 2. Détails d'un programme

```
┌─────────────────────────────────┐
│  ← HIIT Débutant                │
├─────────────────────────────────┤
│  Description                    │
│  Programme d'initiation au HIIT │
│                                 │
│  Exercices                      │
│  ┌───────────────────────────┐  │
│  │ Jumping Jacks             │  │
│  │ ⏱ 30s · ⏸ 15s · 🔄 3x    │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ Squats                    │  │
│  │ ⏱ 45s · ⏸ 15s · 🔄 3x    │  │
│  └───────────────────────────┘  │
│                                 │
│  Informations                   │
│  Durée totale: 15 min           │
│  Nombre d'exercices: 5          │
│                                 │
│  ┌───────────────────────────┐  │
│  │ ▶ Démarrer l'entraînement │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

---

### 3. Exécution du programme (Timer)

```
┌─────────────────────────────────┐
│  Jumping Jacks        [Terminer]│
├─────────────────────────────────┤
│                                 │
│        Jumping Jacks            │
│      Exercice 1/5               │
│        Tour 2/3                 │
│                                 │
│         ╭───────────╮           │
│        ╱    ╲        │           │
│       │  00:25  │               │
│       │ TRAVAIL │               │
│        ╲       ╱                │
│         ╰─────╯                 │
│                                 │
│    [⏹]    [⏸/▶]    [⏭]        │
│    Stop   Pause    Suivant      │
│                                 │
│   [Vibrations]  [Sons]          │
└─────────────────────────────────┘
```

**Phases du timer :**
- 🟢 **Travail** : Exercice en cours (vert)
- 🟠 **Repos** : Temps de pause (orange)
- 🔵 **Terminé** : Programme fini (bleu)

**Contrôles :**
- ▶/⏸ : Démarrer/Pause
- ⏹ : Arrêter et revenir au début
- ⏭ : Passer à l'exercice suivant

---

### 4. Création de programme (Tab "Créer")

```
┌─────────────────────────────────┐
│  Nouveau programme              │
├─────────────────────────────────┤
│  Informations                   │
│  ┌───────────────────────────┐  │
│  │ Nom du programme          │  │
│  │ [Mon programme HIIT    ]  │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ Description (optionnel)   │  │
│  │ [                      ]  │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ Programme public  [ ON ]  │  │
│  └───────────────────────────┘  │
│                                 │
│  Exercices (3)                  │
│  ┌───────────────────────────┐  │
│  │ Pompes                    │  │
│  │ ⏱ 30s · ⏸ 15s · 🔄 3x    │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ ➕ Ajouter un exercice    │  │
│  └───────────────────────────┘  │
│                                 │
│  Résumé                         │
│  Nombre d'exercices: 3          │
│  Durée totale: 6 min 45 s       │
│                                 │
│  [  Enregistrer le programme  ] │
└─────────────────────────────────┘
```

---

### 5. Ajout d'exercice

```
┌─────────────────────────────────┐
│ Annuler  Nouvel exercice Ajouter│
├─────────────────────────────────┤
│  Nom de l'exercice              │
│  [Pompes                     ]  │
│  [Pompes][Squats][Burpees]...   │
│                                 │
│  Durée                          │
│  Travail         [−] 30 sec [+] │
│  Repos           [−] 15 sec [+] │
│                                 │
│  Répétitions                    │
│  Nombre de tours    [−] 3 [+]   │
│                                 │
│  Notes (optionnel)              │
│  [Conseils, variantes...     ]  │
│                                 │
│  Aperçu                         │
│  ┌───────────────────────────┐  │
│  │ Pompes                    │  │
│  │ ⏱ 30s · ⏸ 15s · 🔄 3x    │  │
│  │ Durée totale: 2 min 15 s  │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

**Suggestions rapides** : Pompes, Squats, Burpees, Planche, Crunchs, Fentes...

---

## Architecture technique

```
BodyArtApp/
├── App/
│   ├── BodyArtAppApp.swift      # Point d'entrée + SwiftData
│   └── ContentView.swift         # TabView principal
├── Core/
│   ├── Models/
│   │   ├── Program.swift         # @Model SwiftData
│   │   ├── ExerciseSet.swift     # @Model SwiftData
│   │   └── WorkoutSession.swift  # État runtime du timer
│   ├── PreviewHelper/            # Helpers pour les previews Xcode
│   └── SampleData/               # Données de démonstration
└── Features/
    ├── Programs/
    │   └── Views/
    │       ├── ProgramListView.swift    # Liste des programmes
    │       ├── CreateProgramView.swift  # Création de programme
    │       └── AddExerciseView.swift    # Ajout d'exercice
    └── Workout/
        ├── ViewModels/
        │   └── ExecuteProgramViewModel.swift  # Logique du timer
        └── Views/
            └── ExecuteProgramView.swift       # UI du timer
```

### Technologies utilisées

| Technologie | Usage |
|-------------|-------|
| **SwiftUI** | Interface utilisateur |
| **SwiftData** | Persistance des données |
| **@Observable** | Pattern MVVM moderne (Swift 6) |
| **async/await** | Timer et opérations asynchrones |

---

## Données de démonstration

L'app inclut des programmes de démonstration au premier lancement :

1. **HIIT Débutant** - 5 exercices, ~15 min
2. **Cardio Intense** - 4 exercices, ~20 min
3. **Core Training** - Renforcement abdominaux
4. **Full Body Express** - Entraînement complet rapide
5. **Stretching Détente** - Étirements et relaxation

---

## Prérequis

- iOS 17.0+
- Xcode 15.0+
- iPhone 11 ou plus récent

## Build

```bash
# Compiler
xcodebuild -scheme BodyArtApp -destination 'platform=iOS Simulator,name=iPhone 17' build

# Lancer sur simulateur
xcrun simctl boot "iPhone 17"
open -a Simulator
```

---

## TODO

- [ ] Authentification utilisateur (AuthService)
- [ ] Page Profil
- [ ] Synchronisation cloud
- [ ] Historique des entraînements
- [ ] Statistiques et progression
