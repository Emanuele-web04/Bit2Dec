//
//  TipsView.swift
//  Bit2Dec
//
//  Created by Emanuele Di Pietro on 22/06/24.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showTips = false
    @EnvironmentObject private var store: TipStore
    @State private var showThanks = false
    
    var body: some View {
        VStack {
            
            Button("Tip Me") {
                showTips.toggle()
            }
            .tint(.blue)
            .buttonStyle(.bordered)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            
            if showTips {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        showTips.toggle()
                        
                    }
                OptionsTipsView {
                    showTips.toggle()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(alignment: .bottom) {
            
            if showThanks {
                ThanksView {
                    showThanks = false
                    store.reset()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: showTips)
        .animation(.spring(), value: showThanks)
        .onChange(of: store.action) { _, action in
            if action == .successful {
                showTips = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showThanks = true
                }
            }
        }
        .alert(isPresented: $store.hasError, error: store.error) {
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
