# Firebase Authentication Setup

Ce guide explique les etapes manuelles necessaires pour finaliser l'integration de Firebase Auth avec Sign in with Apple et Facebook Login.

## 1. Configuration Firebase Console

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Creer un nouveau projet ou en selectionner un existant
3. Ajouter une app iOS:
   - Bundle ID: `com.johanchapelain.BodyArtApp`
   - Telecharger `GoogleService-Info.plist`
4. Aller dans **Authentication > Sign-in method**:
   - Activer **Apple**
   - Activer **Facebook** (necessera les IDs Facebook)

### GoogleService-Info.plist

Placer le fichier telecharge dans:
```
BodyArtApp/BodyArtApp/BodyArtApp/GoogleService-Info.plist
```

## 2. Configuration Facebook Developer

1. Aller sur [Facebook Developers](https://developers.facebook.com/)
2. Creer une nouvelle app ou en selectionner une existante
3. Ajouter le produit **Facebook Login**
4. Dans Settings > Basic, noter:
   - **App ID**
   - **Client Token** (dans Settings > Advanced)

### Variables de build Xcode

Dans Xcode, aller dans **BodyArtApp target > Build Settings** et ajouter:

| Variable | Valeur |
|----------|--------|
| `FACEBOOK_APP_ID` | Votre App ID Facebook |
| `FACEBOOK_CLIENT_TOKEN` | Votre Client Token |

Ou modifier directement `Info.plist`:
```xml
<key>FacebookAppID</key>
<string>VOTRE_APP_ID</string>
<key>FacebookClientToken</key>
<string>VOTRE_CLIENT_TOKEN</string>
```

Et mettre a jour le CFBundleURLSchemes:
```xml
<string>fbVOTRE_APP_ID</string>
```

## 3. Capability Sign in with Apple

Dans Xcode:
1. Selectionner le target **BodyArtApp**
2. Aller dans **Signing & Capabilities**
3. Cliquer sur **+ Capability**
4. Ajouter **Sign in with Apple**

## 4. Verifications

- [ ] `GoogleService-Info.plist` est dans le dossier BodyArtApp
- [ ] Capability "Sign in with Apple" est ajoutee
- [ ] Variables `FACEBOOK_APP_ID` et `FACEBOOK_CLIENT_TOKEN` sont configurees
- [ ] Firebase Console a Apple et Facebook actives dans Authentication

## Architecture du code

```
Core/Auth/
├── AuthState.swift           # Enum: unknown, unauthenticated, authenticated
├── UserProfile.swift         # Struct utilisateur
├── AuthService.swift         # @Observable service principal
└── AuthServiceKey.swift      # EnvironmentKey pour injection

Features/Profile/Views/
├── ProfileView.swift         # Vue principale (switch sur auth state)
└── LoginView.swift           # Boutons Apple + Facebook
```

## Test

Sign in with Apple ne fonctionne que sur un **device physique** (pas sur simulateur).

Facebook Login peut etre teste sur simulateur si l'app Facebook n'est pas installee (utilise le web flow).
