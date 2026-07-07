import SwiftUI

/// Uygulamanın kök görünümü.
/// SongListView + MiniPlayerView'ı bir arada tutar ve NowPlayingView'ı
/// matchedGeometryEffect kullanarak tam ekran kart olarak üstüne açar.
struct RootView: View {
    @StateObject private var library = SongLibraryViewModel()
    @StateObject private var player = AudioPlayerViewModel()
    @Namespace private var playerNamespace

    var body: some View {
        ZStack(alignment: .bottom) {
            SongListView(library: library, player: player)

            MiniPlayerView(player: player, namespace: playerNamespace)
                .padding(.bottom, 8)
        }
        .overlay {
            if player.isNowPlayingPresented {
                NowPlayingView(player: player, namespace: playerNamespace)
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: player.isNowPlayingPresented)
    }
}

#Preview {
    RootView()
}
