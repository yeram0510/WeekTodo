////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import UIKit

typealias Color = UIColor

enum ListColor: String {
    case Default = "Default"
    case ClearRed = "ClearRed"
    case Blue = "Blue"
    case Beach = "Beach"
    case Celestial = "Celestial"
    case PacificDream = "PacificDream"
    case CanYouFeelTheLoveTonight = "CanYouFeelTheLoveTonight"
    case TheBlueLagoon = "TheBlueLagoon"
    case RoseColoredLenses = "RoseColoredLenses"
    case ViceCity = "ViceCity"
    case Mild = "Mild"
    case Nimvelo = "Nimvelo"
    case LemonTwist = "LemonTwist"
    
    func get() -> [Color] {
        switch self {
        case .Default:
            return Color.Default()
        case .ClearRed:
            return Color.ClearRed()
        case .Blue:
            return Color.Blue()
        case .Beach:
            return Color.Beach()
        case .Celestial:
            return Color.Celestial()
        case .PacificDream:
            return Color.PacificDream()
        case .CanYouFeelTheLoveTonight:
            return Color.CanYouFeelTheLoveTonight()
        case .TheBlueLagoon:
            return Color.TheBlueLagoon()
        case .RoseColoredLenses:
            return Color.RoseColoredLenses()
        case .ViceCity:
            return Color.ViceCity()
        case .Mild:
            return Color.Mild()
        case .Nimvelo:
            return Color.Nimvelo()
        case .LemonTwist:
            return Color.LemonTwist()
        }
    }
}

func listEnum<T: Hashable>(_: T.Type) -> Array<T> {
    var i = 0
    return Array(AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    })
}


extension Color {
    
    static func Default() -> [Color] {
        return [
            Color(red: 231/255, green: 167/255, blue: 118/255, alpha: 1),
            Color(red: 228/255, green: 125/255, blue: 114/255, alpha: 1),
            Color(red: 233/255, green: 99/255, blue: 111/255, alpha: 1),
            Color(red: 242/255, green: 81/255, blue: 145/255, alpha: 1),
            Color(red: 154/255, green: 80/255, blue: 164/255, alpha: 1),
            Color(red: 88/255, green: 86/255, blue: 157/255, alpha: 1),
            Color(red: 56/255, green: 71/255, blue: 126/255, alpha: 1)
        ]
    }
    
    static func Blue() -> [Color] {
        return [
            Color(red: 6/255, green: 147/255, blue: 251/255, alpha: 1),
            Color(red: 16/255, green: 158/255, blue: 251/255, alpha: 1),
            Color(red: 26/255, green: 169/255, blue: 251/255, alpha: 1),
            Color(red: 33/255, green: 180/255, blue: 251/255, alpha: 1),
            Color(red: 40/255, green: 190/255, blue: 251/255, alpha: 1),
            Color(red: 46/255, green: 198/255, blue: 251/255, alpha: 1),
            Color(red: 54/255, green: 207/255, blue: 251/255, alpha: 1)
        ]
    }
    
    static func ClearRed() -> [Color] {
        return [
            Color(red: 216/255, green: 0/255, blue: 21/255, alpha: 1),
            Color(red: 221/255, green: 50/255, blue: 24/255, alpha: 1),
            Color(red: 225/255, green: 75/255, blue: 25/255, alpha: 1),
            Color(red: 227/255, green: 100/255, blue: 24/255, alpha: 1),
            Color(red: 229/255, green: 125/255, blue: 26/255, alpha: 1),
            Color(red: 232/255, green: 150/255, blue: 27/255, alpha: 1),
            Color(red: 234/255, green: 175/255, blue: 28/255, alpha: 1),
            Color(red: 246/255, green: 207/255, blue: 82/255, alpha: 1)
        ]
    }
    
    static func Beach() -> [Color] {
        return [
            Color(red: 38/255, green: 122/255, blue: 138/255, alpha: 1),
            //Color(red: 106/255, green: 200/255, blue: 210/255, alpha: 1),
            //Color(red: 247/255, green: 226/255, blue: 194/255, alpha: 1),
            Color(red: 239/255, green: 190/255, blue: 155/255, alpha: 1)
        ]
    }
    
    static func Celestial() -> [Color] {
        return [
            Color("#C33764"),
            Color("#1D2671")
        ]
    }
    
    static func PacificDream() -> [Color] {
        return [
            Color("#34e89e"),
            Color("#0f3443")
        ]
    }
    
    static func CanYouFeelTheLoveTonight() -> [Color] {
        return [
            Color("#4568DC"),
            Color("#B06AB3")
        ]
    }
    
    static func TheBlueLagoon() -> [Color] {
        return [
            Color("#43C6AC"),
            Color("#191654")
        ]
    }
    
    static func RoseColoredLenses() -> [Color] {
        return [
            Color("#E8CBC0"),
            Color("#636FA4")
        ]
    }
    
    static func ViceCity() -> [Color] {
        return [
            Color("#3494E6"),
            Color("#EC6EAD")
        ]
    }
    
    static func Mild() -> [Color] {
        return [
            Color("#67B26F"),
            Color("#4ca2cd")
        ]
    }
    
    static func Nimvelo() -> [Color] {
        return [
            Color("#314755"),
            Color("#26a0da")
        ]
    }
    
    static func LemonTwist() -> [Color] {
        return [
            Color("#3CA55C"),
            Color("#B5AC49")
        ]
    }
}

extension Collection where Iterator.Element == Color, Index == Int {
    func gradientColor(atFraction fraction: Double) -> Color {
        // Ensure offset is normalized to 1
        let normalizedOffset = Swift.max(Swift.min(fraction, 1.0), 0.0)
        
        // Work out the 'size' that each color stop spans
        let colorStopRange = 1.0 / (Double(self.endIndex) - 1.0)
        
        // Determine the base stop our offset is within
        let colorRangeIndex = Int(floor(normalizedOffset / colorStopRange))
        
        // Get the initial color which will serve as the origin
        let topColor = self[colorRangeIndex]
        var fromColors: [CGFloat] = [0, 0, 0]
        topColor.getRed(&fromColors[0], green: &fromColors[1], blue: &fromColors[2], alpha: nil)
        
        // Get the destination color we will lerp to
        let bottomColor = self[colorRangeIndex + 1]
        var toColors: [CGFloat] = [0, 0, 0]
        bottomColor.getRed(&toColors[0], green: &toColors[1], blue: &toColors[2], alpha: nil)
        
        // Work out the actual percentage we need to lerp, inside just that stop range
        let stopOffset = CGFloat((normalizedOffset - (Double(colorRangeIndex) * colorStopRange)) / colorStopRange)
        
        // Perform the interpolation
        let finalColors = zip(fromColors, toColors).map { from, to in
            return from + stopOffset * (to - from)
        }
        return Color(red: finalColors[0], green: finalColors[1], blue: finalColors[2], alpha: 1)
    }
}

extension Color {
    class var completeDimBackground: Color {
        return Color(white: 0.2, alpha: 1)
    }
    
    class var completeBackground: Color {
        return Color(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
    }
}

extension Date {
    func getDay() -> Int {
        let cal = Calendar.current.dateComponents([.weekday], from: self).weekday ?? 1
        return cal
    }
}

extension UIColor {
    convenience init(_ hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: h).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch h.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
}

