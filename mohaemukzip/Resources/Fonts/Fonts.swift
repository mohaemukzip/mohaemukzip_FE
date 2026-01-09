//
//  Fonts.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/8/26.
//

import Foundation
import SwiftUI

extension Font {
    enum Pretend {
        case bold
        case semiBold
        case medium
        case regular
        
        var value: String {
            switch self {
            case .bold:
                return "Pretendard-Bold"
            case .semiBold:
                return "Pretendard-SemiBold"
            case .medium:
                return "Pretendard-Medium"
            case .regular:
                return "Pretendard-Regular"
            }
        }
    }
    
    static func pretend(type: Pretend, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
    
    static var PretendardBold26: Font {
        return pretend(type: .bold, size: 26)
    }
    
    static var PretendardBod24: Font {
        return pretend(type: .bold, size: 24)
    }
    
    static var PretendardSemibold20: Font {
        return pretend(type: .semiBold, size: 20)
    }
    
    static var PretendardSemibold18: Font {
        return pretend(type: .semiBold, size: 18)
    }
    
    static var PretendardSemibold16: Font {
        return pretend(type: .semiBold, size: 16)
    }
    
    static var PretendardMedium16: Font {
        return pretend(type: .medium, size: 16)
    }
    
    static var PretendardMedium13: Font {
        return pretend(type: .medium, size: 13)
    }
    
    static var PretendardMedium12: Font {
        return pretend(type: .medium, size: 12)
    }
    
    static var PretendardRegular16: Font {
        return pretend(type: .regular, size: 16)
    }
    
    static var PretendardRegular14: Font {
        return pretend(type: .regular, size: 14)
    }
    
    static var PretendardRegular13: Font {
        return pretend(type: .regular, size: 13)
    }
}
