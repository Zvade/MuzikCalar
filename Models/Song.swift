import Foundation

/// Tek bir şarkıyı temsil eden model.
/// Codable değil çünkü disk üzerinden her seferinde taranıyor (persist etmiyoruz).
struct Song: Identifiable, Equatable {
    let id: String          // dosya adını id olarak kullanıyoruz (unique)
    let title: String       // uzantısız dosya adı
    let fileURL: URL
    var duration: TimeInterval = 0

    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}
