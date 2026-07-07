import SwiftUI

/// Tam ekran "Şimdi Çalıyor" görünümü.
/// Mini player'dan matchedGeometryEffect ile büyüyerek açılır.
struct NowPlayingView: View {
    @ObservedObject var player: AudioPlayerViewModel
    var namespace: Namespace.ID

    /// Kullanıcı slider'ı sürüklerken gerçek zamanlı player güncellemesini durdurmak için.
    @State private var isSeeking = false
    @State private var seekValue: Double = 0

    var body: some View {
        ZStack {
            // Arka plan: koyu gradyan, tam siyahtan biraz daha yumuşak.
            LinearGradient(
                colors: [Color.surfaceDark, Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 20)

                artworkSection

                Spacer(minLength: 30)

                songInfoSection
                    .padding(.horizontal, 28)

                sliderSection
                    .padding(.horizontal, 28)
                    .padding(.top, 18)

                controlsSection
                    .padding(.top, 34)

                Spacer(minLength: 40)
            }
        }
        // Aşağıdan yukarı akıcı kart geçişi
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Header (kapatma tutamacı)

    private var header: some View {
        VStack(spacing: 6) {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            HStack {
                Spacer()
                Text("ŞİMDİ ÇALIYOR")
                    .font(.caption.bold())
                    .foregroundStyle(Color.textSecondary)
                    .tracking(1.2)
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        player.isNowPlayingPresented = false
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(8)
                }
                .pressableStyle()
                .padding(.trailing, 16)
            }
        }
        // Sürükleyerek kapatma (aşağı swipe)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 80 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            player.isNowPlayingPresented = false
                        }
                    }
                }
        )
    }

    // MARK: - Albüm kapağı (büyüyen/küçülen + matchedGeometryEffect)

    private var artworkSection: some View {
        VinylArtworkView(isPlaying: player.isPlaying)
            .matchedGeometryEffect(id: "artwork", in: namespace)
            // Şarkı değiştiğinde sağa/sola kayma animasyonu
            .id(player.currentSong?.id)
            .transition(
                .asymmetric(
                    insertion: .move(edge: player.playbackDirection == .backward ? .leading : .trailing).combined(with: .opacity),
                    removal: .move(edge: player.playbackDirection == .backward ? .trailing : .leading).combined(with: .opacity)
                )
            )
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: player.currentSong)
    }

    // MARK: - Şarkı adı

    private var songInfoSection: some View {
        VStack(spacing: 6) {
            Text(player.currentSong?.title ?? "-")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .id("title-\(player.currentSong?.id ?? "")")
                .transition(
                    .asymmetric(
                        insertion: .move(edge: player.playbackDirection == .backward ? .leading : .trailing).combined(with: .opacity),
                        removal: .move(edge: player.playbackDirection == .backward ? .trailing : .leading).combined(with: .opacity)
                    )
                )

            Text("Yerel Dosya · MP3")
                .font(.system(size: 14))
                .foregroundStyle(Color.textSecondary)
        }
        .animation(.easeInOut(duration: 0.3), value: player.currentSong)
        .frame(maxWidth: .infinity)
    }

    // MARK: - İlerleme çubuğu

    private var sliderSection: some View {
        VStack(spacing: 6) {
            Slider(
                value: Binding(
                    get: { isSeeking ? seekValue : player.currentTime },
                    set: { newValue in
                        isSeeking = true
                        seekValue = newValue
                    }
                ),
                in: 0...(max(player.duration, 1)),
                onEditingChanged: { editing in
                    if !editing {
                        player.seek(to: seekValue)
                        isSeeking = false
                    }
                }
            )
            .tint(Color.spotifyGreen)

            HStack {
                Text(formattedTime(isSeeking ? seekValue : player.currentTime))
                Spacer()
                Text(formattedTime(player.duration))
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Kontrol butonları

    private var controlsSection: some View {
        HStack(spacing: 46) {
            Button {
                player.skip(seconds: -10)
            } label: {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
            }
            .pressableStyle()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    player.playPrevious()
                }
            } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
            }
            .pressableStyle()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    player.togglePlayPause()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 72, height: 72)

                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.black)
                        .offset(x: player.isPlaying ? 0 : 2)
                }
            }
            .pressableStyle(scale: 0.88)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    player.playNext()
                }
            } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
            }
            .pressableStyle()

            Button {
                player.skip(seconds: 10)
            } label: {
                Image(systemName: "goforward.10")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
            }
            .pressableStyle()
        }
    }

    // MARK: - Yardımcılar

    private func formattedTime(_ time: TimeInterval) -> String {
        guard time.isFinite, time >= 0 else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
