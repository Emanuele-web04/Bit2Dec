//
//  TestView.swift
//  Bit2Dec
//
//  Created by Emanuele Di Pietro on 22/06/24.
//

import SwiftUI
import StoreKit

struct TestView: View {
    @State private var myProduct: Product?
    var body: some View {
        VStack {
            Text("Product Info")
            Text(myProduct?.displayName ?? "")
            Text(myProduct?.description ?? "")
            Text(myProduct?.displayPrice ?? "")
            Text(myProduct?.price.description ?? "")
        }
        .task {
            myProduct = try? await Product.products(for: ["com.emanueledipietro.Bit2Dec.TinyTip"]).first
        }
    }
}

#Preview {
    TestView()
}
