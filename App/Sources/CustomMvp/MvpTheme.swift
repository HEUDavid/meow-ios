import SwiftUI

/// MvpTheme defines the clean, light design system colors and styling tokens
/// for the Block Ad MVP UI on iOS, strictly matching the Android (FlClash) palette.
enum MvpTheme {
    // Backgrounds & Surface Card Colors
    static let bgPrimary = Color(red: 0xF8 / 255.0, green: 0xFA / 255.0, blue: 0xFC / 255.0) // #F8FAFC
    static let cardBg = Color.white // #FFFFFF
    static let borderColor = Color(red: 0xE2 / 255.0, green: 0xE8 / 255.0, blue: 0xF0 / 255.0) // #E2E8F0
    
    // Primary Active & Accent Colors
    static let activeColor = Color(red: 0x6B / 255.0, green: 0x6B / 255.0, blue: 0xEE / 255.0) // #6B6BEE
    static let activeColorLight = Color(red: 0x5C / 255.0, green: 0xA8 / 255.0, blue: 0xE9 / 255.0) // #5CA8E9
    static let activeColorDark = Color(red: 0x33 / 255.0, green: 0x6A / 255.0, blue: 0xB6 / 255.0) // #336AB6
    
    // Inactive & Disabled Colors
    static let inactiveGray = Color(red: 0xCB / 255.0, green: 0xD5 / 255.0, blue: 0xE1 / 255.0) // #CBD5E1
    static let offBgColor = Color(red: 0xCB / 255.0, green: 0xD5 / 255.0, blue: 0xE1 / 255.0)
    static let offBorderColor = Color(red: 0x94 / 255.0, green: 0xA3 / 255.0, blue: 0xB8 / 255.0)
    
    // Typography Colors
    static let textPrimary = Color(red: 0x0F / 255.0, green: 0x17 / 255.0, blue: 0x2A / 255.0) // #0F172A
    static let textSecondary = Color(red: 0x64 / 255.0, green: 0x74 / 255.0, blue: 0x8B / 255.0) // #64748B
    static let textMuted = Color(red: 0x94 / 255.0, green: 0xA3 / 255.0, blue: 0xB8 / 255.0) // #94A3B8
    
    // Toast & Warning Colors
    static let toastBg = Color(red: 0x1E / 255.0, green: 0x29 / 255.0, blue: 0x3B / 255.0) // #1E293B
    static let warningBg = Color(red: 0xF5 / 255.0, green: 0x9E / 255.0, blue: 0x0B / 255.0) // #F59E0B
}
