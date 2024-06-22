//
//  TipItemView.swift
//  Bit2Dec
//
//  Created by Emanuele Di Pietro on 22/06/24.
//

import SwiftUI
import StoreKit

struct TipsItemView: View {
    
    let item: Product?
    @EnvironmentObject private var store: TipStore
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading,
                   spacing: 3) {
                Text(item?.displayName ?? "")
                    .font(.system(.title3, design: .rounded).bold())
                Text(item?.displayPrice ?? "")
                    .font(.system(.callout, design: .rounded).weight(.regular))
            }
            
            Spacer()
            
            Button(item?.displayPrice ?? "") {
                
                if let item = item {
                    Task {
                        await store.purchase(item)
                    }
                }
            }
            .tint(.blue)
            .buttonStyle(.bordered)
            .font(.callout.bold())
        }
        .padding(16)
        .background(Color(.black),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}


