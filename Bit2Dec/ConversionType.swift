//
//  ConversionType.swift
//  Bit2Dec
//
//  Created by Emanuele Di Pietro on 21/06/24.
//

import Foundation
enum ConversionType: String, Identifiable, CaseIterable {
    case bit2dec = "Binary 2 Decimal"
    case dec2Bit = "Decimal 2 Binary"
    case dec2hex = "Decimal 2 Hex"
    
    var id: Self { return self }
}
