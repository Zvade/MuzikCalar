import SwiftUI

/// Şarkı listesindeki tek bir satır.
/// Şu an çalan şarkı ise vurgulanır (yeşil ikon + kalın font).
struct SongRowView: View {
    let song: Song
    let isCurrent: Bool
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.surfaceElevated)
                    .frame(width: 48, height: 48)

                Image(systemName: isCurrent && isPlaying ? "waveform" : "music.note")
                    .foregroundStyle(isCurrent ? Color.spotifyGreen : Color.white.opacity(0.6))
                    .font(.system(size: 18, weight: .medium))
                    .symbolEffect(.variableColor.iterative, isActive: isCurrent && isPlaying)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(song.title)
                    .font(.system(size: 16, weight: isCurrent ? .semibold : .regular))
                    .foregroundStyle(isCurrent ? Color.spotifyGreen : Color.white)
                    .lineLimit(1)

                Text(formattedDuration)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        // Satır seçildiğinde hafif opaklık/scale mikro animasyonu
        .scaleEffect(isCurrent ? 1.0 : 1.0)
        .animation(.easeInOut(duration: 0.25), value: isCurrent)
    }

    private var formattedDuration: String {
        guard song.duration.isFinite, song.duration > 0 else { return "--:--" }
        let minutes = Int(song.duration) / 60
        let seconds = Int(song.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SongRowView(
            song: Song(id: "1", title: "Örnek Şarkı Adı", fileURL: URL(fileURLWithPath: "/"), duration: 213),
            isCurrent: true,
            isPlaying: true
        )
    }
}
