//
//  ToastView.swift
//  Bit2Dec
//
//  Created by Emanuele Di Pietro on 22/06/24.
//

import SwiftUI
struct ToastView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.cyan)
            .foregroundColor(.black)
            .cornerRadius(8)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
    }
}


