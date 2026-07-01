import Foundation

enum CardLayout: String, CaseIterable, Identifiable {
    case single = "1 Photo"
    case dual = "2 Photos"
    case quad = "4 Photos"

    var id: String { rawValue }

    var maxPhotos: Int {
        switch self {
        case .single: return 1
        case .dual: return 2
        case .quad: return 4
        }
    }

    var columns: Int {
        switch self {
        case .single: return 1
        case .dual: return 2
        case .quad: return 2
        }
    }
}
