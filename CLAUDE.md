# CLAUDE.md – BodyArtApp (iOS 17+)

## 📚 Documentation Apple (OBLIGATOIRE)

**AVANT d'écrire du code, TOUJOURS consulter le serveur MCP `cupertino` pour :**
- Vérifier les APIs et patterns recommandés par Apple
- Trouver des exemples de code officiels
- S'assurer d'utiliser les bonnes pratiques iOS/SwiftUI/SwiftData

**Outils disponibles :**
- `mcp__cupertino__search_docs` - Rechercher dans la documentation Apple
- `mcp__cupertino__search_samples` - Trouver des exemples de code Apple
- `mcp__cupertino__read_document` - Lire un article de documentation
- `mcp__cupertino__read_sample` - Lire le README d'un projet exemple
- `mcp__cupertino__read_sample_file` - Lire un fichier source d'exemple
- `mcp__cupertino__list_frameworks` - Lister les frameworks disponibles

---

## 🎯 Projet
**BodyArtApp** : App iOS pour coachs associatifs + adhérents
**iOS 17+** (iPhone 11+) | SwiftUI | SwiftData | Swift 6

**Fonction** :
- Coachs créent programmes (exos + timer + pause + laps)
- Adhérents consultent programmes publics + les rejouent

## 📁 Structure actuelle
```
BodyArtApp/
├── BodyArtApp.xcodeproj
├── GoogleService-Info.plist
├── Info.plist                          # Facebook/Google URL schemes
└── BodyArtApp/
    ├── App/
    │   ├── CoachAppApp.swift           # @main + Firebase + ModelContainer
    │   ├── RootView.swift              # Auth routing (loading/auth/unauth)
    │   ├── ContentView.swift           # TabView principal
    │   └── ProfileView.swift           # Profil utilisateur + déconnexion
    ├── Core/
    │   ├── Models/
    │   │   ├── Program.swift           # @Model class
    │   │   ├── ExerciseSet.swift       # @Model class
    │   │   ├── User.swift              # @Model class (uid, email, role)
    │   │   └── WorkoutSession.swift    # Runtime state class
    │   └── Services/
    │       └── AuthService.swift       # @Observable Firebase Auth (email/Facebook/Google)
    ├── Features/
    │   ├── Auth/
    │   │   └── Views/
    │   │       ├── AuthenticationView.swift  # Container auth (login/signup toggle)
    │   │       ├── LoginView.swift           # Connexion email + social
    │   │       └── SignUpView.swift          # Inscription email + social
    │   ├── Programs/
    │   │   └── Views/
    │   │       ├── ProgramListView.swift     # @Query pour fetch
    │   │       ├── CreateProgramView.swift   # @Environment(\.modelContext)
    │   │       └── AddExerciseView.swift
    │   └── Workout/
    │       ├── ViewModels/
    │       │   └── ExecuteProgramViewModel.swift  # Timer logic
    │       └── Views/
    │           └── ExecuteProgramView.swift
    └── Assets.xcassets
```

## 💾 SwiftData (Pattern Apple recommandé)

```swift
// Models avec @Model directement
@Model
final class Program {
    var name: String
    var programDescription: String?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.program)
    var exercises: [ExerciseSet] = []
    var isPublic: Bool = false
    var createdAt: Date = Date()
}

@Model
final class ExerciseSet {
    var name: String
    var durationSeconds: Int
    var pauseSeconds: Int
    var laps: Int
    var order: Int = 0
    var program: Program?
}

// App setup simple
@main
struct CoachAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Program.self)
    }
}

// Vue avec @Query (pas de ViewModel pour le fetch)
struct ProgramListView: View {
    @Query(
        filter: #Predicate<Program> { $0.isPublic },
        sort: \Program.createdAt,
        order: .reverse
    ) private var programs: [Program]

    var body: some View {
        List(programs) { program in
            NavigationLink { ... }
        }
    }
}

// Création avec @Environment(\.modelContext)
struct CreateProgramView: View {
    @Environment(\.modelContext) private var modelContext

    func saveProgram() {
        let program = Program(name: name, ...)
        modelContext.insert(program)
    }
}

// @Bindable pour éditer un modèle
struct ProgramDetailView: View {
    @Bindable var program: Program
}
```

## 🎨 Navigation
```swift
// RootView : routing selon authState
RootView
├── .loading → ProgressView
├── .unauthenticated → AuthenticationView (Login / SignUp)
└── .authenticated → ContentView (TabView)
    ├── Tab 1 - ProgramListView (@Query)
    ├── Tab 2 - CreateProgramView (modelContext)
    └── Tab 3 - ProfileView (déconnexion)
```

## ✅ Features implémentées

| # | Feature | Status | Fichiers |
|---|---------|--------|----------|
| 1 | ProgramListView | ✅ Done | ProgramListView.swift (@Query) |
| 2 | ExecuteProgramView + timer | ✅ Done | ExecuteProgramView.swift, ExecuteProgramViewModel.swift |
| 3 | CreateProgramView | ✅ Done | CreateProgramView.swift, AddExerciseView.swift |
| 4 | SwiftData persistance | ✅ Done | Program.swift, ExerciseSet.swift (@Model) |
| 5 | AuthService (Firebase + Facebook + Google) | ✅ Done | AuthService.swift (@Observable) |
| 6 | Auth Views (Login/SignUp/Routing) | ✅ Done | AuthenticationView.swift, LoginView.swift, SignUpView.swift, RootView.swift |
| 7 | ProfileView | ✅ Done | ProfileView.swift |
| 8 | User model | ✅ Done | User.swift (@Model, rôle coach/member) |

## 🧪 Règles STRICTES

```
✅ @Model pour les données persistées
✅ @Query dans les vues pour fetch SwiftData
✅ @Environment(\.modelContext) pour insert/delete
✅ @Bindable pour éditer un @Model
✅ @Observable + @MainActor pour ViewModels complexes (timer, etc.)
✅ NavigationStack (pas NavigationView)
✅ Vues < 120 lignes

❌ Pas de couche service inutile (utiliser @Query directement)
❌ Pas de DTO séparés (utiliser @Model directement)
❌ Pas de ! (force unwrap)
❌ Pas de ObservableObject (ancien)
❌ Pas de singletons
```

## 🚀 Commandes utiles

```bash
# Build
xcodebuild -scheme BodyArtApp -destination 'platform=iOS Simulator,name=iPhone 17' build

# Lancer sur simulateur
xcrun simctl boot "iPhone 17"
xcrun simctl install booted [path/to/BodyArtApp.app]
xcrun simctl launch booted com.johanchapelain.BodyArtApp
```
