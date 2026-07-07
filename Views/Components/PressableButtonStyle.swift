import SwiftUI

/// Spotify tarzı mikro-etkileşim: basılınca hafifçe küçülür ve opaklığı azalır.
/// Herhangi bir Button'a `.buttonStyle(PressableButtonStyle())` ile uygulanabilir.
struct PressableButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.9

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    /// Kısayol: herhangi bir View'a hızlıca "pressable" davranışı eklemek için.
    func pressableStyle(scale: CGFloat = 0.9) -> some View {
        self.buttonStyle(PressableButtonStyle(scaleAmount: scale))
    }
}
