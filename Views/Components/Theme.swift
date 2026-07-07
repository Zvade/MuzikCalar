import SwiftUI

/// Uygulama genelinde kullanılan renk paleti.
/// Tek bir yerden yönetildiği için tema değişikliği kolayca yapılabilir.
extension Color {
    /// True Black - AMOLED ekranlarda piksel kapatan tam siyah.
    static let appBackground = Color.black

    /// Kartlar, satırlar ve yükseltilmiş yüzeyler için koyu gri.
    static let surfaceDark = Color(white: 0.10)

    /// Daha da açık bir gri katman (mini player, now playing arkaplanı vs.)
    static let surfaceElevated = Color(white: 0.14)

    /// Spotify'ın ikonik vurgu yeşili.
    static let spotifyGreen = Color(red: 30/255, green: 215/255, blue: 96/255)

    /// İkincil metinler için soluk gri.
    static let textSecondary = Color(white: 0.65)
}

/// Kartlar için ortak bir arka plan modifier'ı (yuvarlatılmış köşe + hafif parlama).
struct GlowCardBackground: ViewModifier {
    var cornerRadius: CGFloat = 16
    var isHighlighted: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.surfaceDark)
                    .shadow(color: Color.spotifyGreen.opacity(isHighlighted ? 0.25 : 0),
                            radius: isHighlighted ? 12 : 0)
            )
    }
}

extension View {
    func glowCard(cornerRadius: CGFloat = 16, isHighlighted: Bool = false) -> some View {
        self.modifier(GlowCardBackground(cornerRadius: cornerRadius, isHighlighted: isHighlighted))
    }
}
