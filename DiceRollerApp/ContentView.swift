import SwiftUI
import AVFoundation
import CoreHaptics

struct ContentView: View {
    @State private var result: Int = 0
    @State private var rollLog: [String] = []
    @State private var audioPlayer: AVAudioPlayer?
    @State private var backgroundColor: Color = Color(red: 0.14, green: 0.28, blue: 0.30)
    let flashColor: Color = Color(red: 1.0, green: 0.37, blue: 0.36)
    
    let diceTypes: [String: Int] = [
        "d100": 100,
        "d20": 20,
        "d12": 12,
        "d10": 10,
        "d8": 8,
        "d6": 6,
        "d4": 4,
        "d2": 2
    ]
    let orderedDice = ["d2", "d4", "d6", "d8", "d10", "d12", "d20", "d100"]
    
    let textFont: String = "PirataOne-Regular"
    let textSizeResult: CGFloat = 175
    let textSizeButton: CGFloat = 30
    let textSizeLog: CGFloat = 30
    let colorBackground: Color = Color(red: 0.14, green: 0.28, blue: 0.30)
    let colorButton: Color = Color(red: 0.0, green: 0.8, blue: 0.75)
    let colorTextMain: Color = Color(red: 0.92, green: 1.0, blue: 1.0)
    let colorTextSpecial: Color = Color(red: 1.0, green: 0.37, blue: 0.36)
    let colorLogStroke: Color = Color(red: 0.12, green: 0.23, blue: 0.25)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 10) {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(rollLog.reversed(), id: \..self) { log in
                            Text(log)
                                .font(.custom(textFont, size: textSizeLog))
                                .foregroundColor(colorButton)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 320)
                .frame(height: 225) // Ensure at least 7 lines are visible
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorLogStroke, lineWidth: 4)
                )
                
                Text("\(result)")
                    .font(.custom(textFont, size: textSizeResult))
                    .foregroundColor(colorTextSpecial)
                    .scaleEffect(result == 0 ? 0.5 : 1.0)
                    .opacity(result == 0 ? 0 : 1)
                    .animation(.easeOut(duration: 0.3), value: result)
                    .padding()
                
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        ForEach(orderedDice.prefix(4), id: \..self) { dice in
                            diceButton(dice: dice)
                        }
                    }
                    HStack(spacing: 10) {
                        ForEach(orderedDice.suffix(4), id: \..self) { dice in
                            diceButton(dice: dice)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    func diceButton(dice: String) -> some View {
        Button(action: {
            let rollResult = rollDice(sides: diceTypes[dice]!)
            rollLog.append("\(dice): \(rollResult)")
            
            withAnimation(Animation.default.repeatCount(3, autoreverses: true)) {
                if rollResult == diceTypes[dice]! {
                    playSound(resourceName: "thunder-melody")
                    flashBackground()
                } else {
                    playSound(resourceName: "dice-roll")
                }
            }
            provideHapticFeedback()
        }) {
            Text(dice)
                .font(.custom(textFont, size: textSizeButton))
                .padding()
                .frame(maxWidth: .infinity, minHeight: 90)
                .lineLimit(1)
                .background(colorButton)
                .foregroundColor(colorTextMain)
                .cornerRadius(10)
        }
    }
    
    func rollDice(sides: Int) -> Int {
        let rolledValue = Int.random(in: 1...sides)
        result = rolledValue
        return rolledValue
    }
    
    func playSound(resourceName: String) {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func flashBackground() {
        let flashSequence = [
            flashColor, backgroundColor, flashColor, backgroundColor
        ]
        
        var delay: Double = 0
        for color in flashSequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    backgroundColor = color
                }
            }
            delay += 0.1
        }
    }
    
    func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
