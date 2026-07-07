import SwiftUI

/// Varsayılan müzik ikonunu, hafif parlama (glow) efektiyle gösteren albüm kapağı.
/// `isPlaying` true olduğunda hafifçe büyür, false olduğunda küçülür.
struct VinylArtworkView: View {
    let isPlaying: Bool
    var size: CGFloat = 280

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.16), Color(white: 0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Color.spotifyGreen.opacity(isPlaying ? 0.35 : 0.0),
                        radius: isPlaying ? 30 : 0,
                        x: 0, y: 12)

            Image(systemName: "music.note")
                .font(.system(size: size * 0.32, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.85))
        }
        // Çalarken hafifçe büyüyor, duraklayınca küçülüyor.
        .scaleEffect(isPlaying ? 1.0 : 0.92)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isPlaying)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VinylArtworkView(isPlaying: true)
    }
}
