//
//  Hapticfeedback.swift
//  Bit2Dec
//
//  Created by Emanuele Di Pietro on 21/06/24.
//

#if os(iOS)
import UIKit

class HapticFeedback {
    
    static let shared = HapticFeedback()
    
    func triggerImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
#endif

