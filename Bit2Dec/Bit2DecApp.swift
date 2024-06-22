//
//  Bit2DecApp.swift
//  Bit2Dec
//
//  Created by Emanuele Di Pietro on 21/06/24.
//

import SwiftUI

@main
struct Bit2DecApp: App {
    @StateObject private var store = TipStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
                .environmentObject(store)
        }
    }
}
