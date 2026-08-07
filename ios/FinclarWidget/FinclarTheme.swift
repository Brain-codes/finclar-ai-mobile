import SwiftUI

/// Mirrors the Dart design tokens in `lib/core/theme/app_colors.dart`.
/// WidgetKit cannot read Flutter's theme, so these are duplicated here on
/// purpose — keep them in sync when the Dart tokens change.
enum FinclarTheme {
    static let primary = Color(red: 1.0, green: 0.459, blue: 0.122)          // 0xFFFF751F
    static let error = Color(red: 0.831, green: 0.239, blue: 0.239)
    static let textSecondary = Color(red: 0.573, green: 0.561, blue: 0.545)  // 0xFF928F8B

    /// Adapts to light/dark automatically, matching textPrimary / darkTextPrimary.
    static let textPrimary = Color(uiColor: .label)
    static let background = Color("WidgetBackground")
    static let track = Color.gray.opacity(0.18)
}
