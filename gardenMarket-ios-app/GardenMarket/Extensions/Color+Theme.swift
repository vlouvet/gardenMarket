import SwiftUI

extension Color {
    static let gardenAccent = Color(red: 215/255, green: 106/255, blue: 77/255)   // #d76a4d
    static let gardenSecondary = Color(red: 45/255, green: 111/255, blue: 101/255) // #2d6f65
    static let gardenBackground = Color(red: 250/255, green: 247/255, blue: 242/255)
}

extension ShapeStyle where Self == Color {
    static var accent: Color { .gardenAccent }
}
