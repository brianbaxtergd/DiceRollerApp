import SwiftUI
import AVFoundation
import CoreHaptics

struct ContentView: View {
    @State private var isRolling: Bool = false // I don't believe this is used anymore..
    @State private var pressed: Bool = false
    @State private var result: Int = 0
    @State private var selectedDice: String = "Let's Roll"
    @State private var audioPlayer: AVAudioPlayer?
    @State private var backgroundColor: Color = Color(red: 0.14, green: 0.28, blue: 0.30) // Original Color. See "colorBackground" above.
    let flashColor: Color = Color(red: 1.0, green: 0.37, blue: 0.36) // Flash Color. See "colorTextSpecial" above.

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
    let textSizeSelectedDice: CGFloat = 40
    let textSizeResult: CGFloat = 200
    let textSizeButton: CGFloat = 30
    let colorBackground: Color = Color(red: 0.14, green: 0.28, blue: 0.30)
    let colorButton: Color = Color(red: 0.0, green: 0.8, blue: 0.75)
    let colorTextMain: Color = Color(red: 0.92, green: 1.0, blue: 1.0)
    let colorTextSpecial: Color = Color(red: 1.0, green: 0.37, blue: 0.36)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(selectedDice)
                    .font(.custom(textFont, size: textSizeSelectedDice))
                    .foregroundColor(colorTextMain)
                    .padding()
                
                Text("\(result)")
                    .font(.custom(textFont, size: textSizeResult))
                    .foregroundColor(colorTextSpecial)
                    .scaleEffect(result == 0 ? 0.5 : 1.0)
                    .opacity(result == 0 ? 0 : 1)
                    .animation(.easeOut(duration: 0.3), value: result)
                    .font(.custom(textFont, size: textSizeResult))
                    .foregroundColor(colorTextSpecial)
                    .padding()
                    .frame(maxHeight: .infinity)
                    .padding()
                
                Spacer()
                
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        ForEach(orderedDice.prefix(4), id: \.self) { dice in
                            diceButton(dice: dice)
                        }
                    }
                    HStack(spacing: 10) {
                        ForEach(orderedDice.suffix(4), id: \.self) { dice in
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
            pressed = true
            selectedDice = dice
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { pressed = false }
            withAnimation(Animation.default.repeatCount(3, autoreverses: true)) {
                if rollDice(sides: diceTypes[dice]!) {
                    playSound(resourceName: "thunder-melody")
                    flashBackground() // Trigger the flashing effect on critical rolls
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
                .scaleEffect(pressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressed)
        }
    }
    
    func rollDice(sides: Int) -> Bool {
        result = Int.random(in: 1...sides)
        let isCritical = result == sides
        return isCritical
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
            delay += 0.1 // Adjust timing between flashes
        }
    }
    
    func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
