import SwiftUI
import WidgetKit
#if os(macOS)
import AppKit
#endif

enum FocusableField: Hashable {
    case dec
    case bit
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // default to clear
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
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
    @State var outcome = [Character]()
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
    
    private var hexString: String {
        // Ensure the hex string is at least 6 characters long, padding with zeros if necessary
        let hex = String(outcome)
        let paddedHex = String(repeating: "0", count: max(0, 6 - hex.count)) + hex
        return paddedHex.uppercased()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.cyan.opacity(0.4), .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
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
                        case .dec2hex:
                            VStack(alignment: .leading) {
                                Text("Decimal Value").font(.caption)
                                HStack {
                                    TextField("Enter Dec", value: $decNumber, formatter: NumberFormatter())
#if os(iOS)
                                    
                                        .keyboardType(.numberPad).font(.title3)
                                        .focused($isFocused, equals: .dec)
#endif
                                    Spacer()
                                    randomButton
                                }
                                #if os(iOS)
                                .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 15.0).fill(Color.clear)
                                            .stroke(.primary, lineWidth: 1)
                                    }
#endif
                                
                                if isTapped {
                                    Text("Hexadecimal Value").font(.caption).padding(.top)
                                    HStack {
                                        Text("#\(hexString)").font(.title3).bold()
                                        Spacer()
                                        button(from: "#\(hexString)")
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
                        if conversionType == .dec2hex && isTapped {
                            Button {
#if os(iOS)
                                HapticFeedback.shared.triggerImpactFeedback(.light)
                                
                                pasteboard.string = ("#" + hexString)
#else
                                copyToClipboard("#" + hexString)
#endif
                                withAnimation {
                                    showToast = true
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 15).stroke(Color.cyan, lineWidth: 4.0).fill(Color(hex: hexString)).frame(width: 70, height: 70)
                            }.buttonStyle(.plain)
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
                        outcome = []
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
                            case .dec2hex:
                                convertDec2Hex()
                            }
                        }.disabled(decNumber == 0 && bitNumber == 0)
                            .disabled(decNumber > 16777215)
                        
                        if isTapped {
                            Spacer()
                            Button {
                                decNumber = 0
                                bitNumber = 0
                                outcome = []
                                isTapped = false
                                isFocused = nil
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
            }
        }
    }
    
    func generateRandomDec() {
        let random = Int.random(in: 0...16777215)
        decNumber = random
    }
    
    private var randomButton: some View {
        Button {
            generateRandomDec()
            #if os(iOS)
            HapticFeedback.shared.triggerImpactFeedback(.soft)
            #endif
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                convertDec2Hex()
                isTapped = true
                isFocused = nil
            }
        } label: {
            Image(systemName: "shuffle").foregroundStyle(.cyan).padding(5)
#if os(iOS)
                .background {
                    RoundedRectangle(cornerRadius: 8).fill(.black)
                }
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
            isFocused = nil
        } label: {
            Label(decNumber > 16777215 ? "Number out of range" : "Convert", systemImage: "arrow.up.arrow.down.circle.fill")
#if os(iOS)
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .padding(.horizontal, 21).padding(.vertical, 15)
                .background(((decNumber == 0 && bitNumber == 0) || decNumber > 16777215) ? Color.secondary : Color.primary)
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
#else
            copyToClipboard(string)
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
    
    #if os(macOS)
    func copyToClipboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(string, forType: .string)
    }#endif
    
    
    func convertDec2Bit() {
        var temp = decNumber
        outcome = [] // Reset the outcome array before starting the conversion
        while (temp != 0) {
            outcome.append(Character("\(temp % 2)"))
            temp = temp / 2
        }
        outcome.reverse()
    }
    
    func convertDec2Hex() {
        var temp = decNumber
        outcome = []
        let hexDigits = "0123456789ABCDEF"
        
        // Ensure the number is within the valid range for RGB values
        temp = min(max(temp, 0), 0xFFFFFF)
        
        while(temp != 0) {
            let remainder = temp % 16
            outcome.append(hexDigits[hexDigits.index(hexDigits.startIndex, offsetBy: remainder)])
            temp /= 16
        }
        
        // Ensure the hex string is 6 characters long
        while outcome.count < 6 {
            outcome.append("0")
        }
        
        outcome.reverse()
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
