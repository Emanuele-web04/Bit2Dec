//
//  ContentView.swift
//  Bit2Dec
//
//  Created by Emanuele Di Pietro on 21/06/24.
//

import SwiftUI
import WidgetKit

enum FocusableField: Hashable {
    case dec
    case bit
}

extension StringProtocol  {
    var digits: [Int] { compactMap(\.wholeNumberValue) }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension Numeric where Self: LosslessStringConvertible {
    var digits: [Int] { string.digits }
}

struct MainView: View {
    @State var decNumber = 0
    @State var bitNumber = 0
    @State var outcome = [Int]()
    @State var converted = [Int]()
    @State var isTapped = false
    @State private var showToast = false
    @AppStorage("conversionType", store: UserDefaults(suiteName: "group.com.emanueledipietro.Bit2Dec")) var conversionType: ConversionType = .dec2Bit
    
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isFocused: FocusableField?
    
    #if os(iOS)
    private var pasteboard = UIPasteboard.general
    #endif
    
    private var bitString: String {
        outcome.reversed()
            .map { String($0) }
            .joined()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    HStack {
                        Text("Choose a conversion")
                        Spacer()
                        Picker("", selection: $conversionType) {
                            ForEach(ConversionType.allCases, id: \.id) { convType in
                                Text(convType.rawValue).tag(convType)
                            }
                        }.tint(.cyan)
                    }
                    switch conversionType {
                    case .bit2dec:
                        VStack(alignment: .leading) {
                            Text("Bit Value").font(.caption).padding(.top)
                            TextField("Enter Bit", value: $bitNumber, formatter: NumberFormatter())
#if os(iOS)
                                .padding()
                                .keyboardType(.numberPad).font(.title3)
                                .focused($isFocused, equals: .bit)
                        
                             
                                .background {
                                    RoundedRectangle(cornerRadius: 15.0).fill(Color.clear)
                                        .stroke(.primary, lineWidth: 1)
                                }
#endif
                            if isTapped {
                                Text("Decimal Value").font(.caption)
                                HStack {
                                    Text(String(decNumber)).font(.title3).bold()
                                    Spacer()
                                    button(from: String(decNumber))
                                }
                               
#if os(iOS)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 15.0).fill(Color.clear)
                                        .stroke(.primary, lineWidth: 1)
                                }
#endif
                            }
                        }
                    case .dec2Bit:
                        VStack(alignment: .leading) {
                            Text("Decimal Value").font(.caption)
                            TextField("Enter Dec", value: $decNumber, formatter: NumberFormatter())
#if os(iOS)
                              
                                .keyboardType(.numberPad).padding().font(.title3)
                                .focused($isFocused, equals: .dec)
                           
                                .background {
                                    RoundedRectangle(cornerRadius: 15.0).fill(Color.clear)
                                        .stroke(.primary, lineWidth: 1)
                                }
#endif
                            
                            if isTapped {
                                Text("Bit Value").font(.caption).padding(.top)
                                HStack {
                                    Text(bitString).font(.title3).bold()
                                    Spacer()
                                    button(from: bitString)
                                }
                               
#if os(iOS)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 15.0).fill(Color.clear)
                                        .stroke(.primary, lineWidth: 1)
                                }
                                #endif
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .navigationTitle("Conversion")
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Spacer()
                    }
                    ToolbarItem(placement: .keyboard) {
                        Button {
                            isFocused = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down").foregroundStyle(.cyan)
                        }
                    }
                }
                .onChange(of: conversionType) {
                #if os(iOS)
                    HapticFeedback.shared.triggerImpactFeedback(.soft)
                    #endif
                    decNumber = 0
                    bitNumber = 0
                    isTapped = false
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    conversionButton {
                        switch conversionType {
                        case .bit2dec:
                            convertBit2Dec()
                        case .dec2Bit:
                            convertDec2Bit()
                        }
                    }.disabled(decNumber == 0 && bitNumber == 0)
                    
                    if isTapped {
                        Spacer()
                        Button {
                            decNumber = 0
                            bitNumber = 0
                            isTapped = false
#if os(iOS)
                            HapticFeedback.shared.triggerImpactFeedback()
                            #endif
                        } label: {
                            Label("Reset", systemImage: "minus.circle.fill")
#if os(iOS)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 21).padding(.vertical, 15)
                                .background(Color.red)
                                .cornerRadius(150)
                            #endif
                        }
                        .padding()
                    }
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    if showToast {
                        ToastView(message: "Copied to Clipboard")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        showToast = false
                                    }
                                }
                            }
                    }
                    Spacer()
                }
            )
            #if os(macOS)
            .background(.thinMaterial)
            #endif
        }
    }
    
    func conversionButton(_ action: @escaping () -> Void) -> some View {
        Button {
#if os(iOS)
            HapticFeedback.shared.triggerImpactFeedback()
            #endif
            action()
            isTapped = true
        } label: {
            Label("Convert", systemImage: "arrow.up.arrow.down.circle.fill")
#if os(iOS)
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .padding(.horizontal, 21).padding(.vertical, 15)
                .background((decNumber == 0 && bitNumber == 0) ? Color.secondary : Color.primary)
                .cornerRadius(150)
            #else
                .foregroundStyle(.white)
            #endif
        }.padding()
    }
    
    func button(from string: String) -> some View {
        Button {
#if os(iOS)
            HapticFeedback.shared.triggerImpactFeedback(.light)
            
            pasteboard.string = string
            #endif
            withAnimation {
                showToast = true
            }
        } label: {
            Image(systemName: "doc.on.doc.fill").foregroundStyle(colorScheme == .dark ? .black : .white).padding(5)
#if os(iOS)
                .background {
                    RoundedRectangle(cornerRadius: 8).fill(.cyan)
                }
            #endif
        }
    }
    
    func convertDec2Bit() {
        var temp = decNumber
        outcome = [] // Reset the outcome array before starting the conversion
        while (temp != 0) {
            outcome.append(temp % 2)
            temp = temp / 2
        }
    }
    
    func convertBit2Dec() {
        let temp = bitNumber.digits
        var result = 0
        for (index, bit) in temp.reversed().enumerated() {
            result += bit * Int(truncating: NSDecimalNumber(decimal: pow(2, index)))
        }
        decNumber = result
    }
}

#Preview {
    MainView()
}
