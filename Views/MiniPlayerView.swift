import SwiftUI

/// Liste ekranının altında sabit duran küçük oynatıcı çubuğu.
/// Dokununca Now Playing ekranı, matchedGeometryEffect ile aşağıdan yukarı açılır.
struct MiniPlayerView: View {
    @ObservedObject var player: AudioPlayerViewModel
    var namespace: Namespace.ID

    var body: some View {
        if let song = player.currentSong {
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    player.isNowPlayingPresented = true
                }
            } label: {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.surfaceElevated)
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundStyle(.white.opacity(0.8))
                        )
                        .matchedGeometryEffect(id: "artwork", in: namespace)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(player.isPlaying ? "Çalıyor" : "Duraklatıldı")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textSecondary)
                    }
                    // Şarkı değiştiğinde metinlerin kayarak değişmesi
                    .id(song.id)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: player.playbackDirection == .backward ? .leading : .trailing).combined(with: .opacity),
                            removal: .move(edge: player.playbackDirection == .backward ? .trailing : .leading).combined(with: .opacity)
                        )
                    )

                    Spacer()

                    Button {
                        player.togglePlayPause()
                    } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                    }
                    .pressableStyle()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glowCard(cornerRadius: 14, isHighlighted: player.isPlaying)
                .padding(.horizontal, 10)
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: player.currentSong)
        }
    }
}
