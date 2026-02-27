import SwiftUI

struct ProfilePhotoView: View {
    let url: URL?
    let displayName: String?
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.gradient)
            Text(initials)
                .font(.system(size: size * 0.35, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var initials: String {
        guard let name = displayName, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

#Preview("With URL") {
    ProfilePhotoView(url: nil, displayName: "Johan Chapelain", size: 80)
}

#Preview("Initials only") {
    ProfilePhotoView(url: nil, displayName: "Marie Dupont", size: 80)
}
