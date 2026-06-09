import SwiftUI

struct SynthwaveBackgroundView: View {
    var body: some View {
        ZStack {
            Color(red: 0.018, green: 0.027, blue: 0.043)

            LinearGradient(
                colors: [
                    Color(red: 0.035, green: 0.066, blue: 0.096),
                    Color(red: 0.015, green: 0.023, blue: 0.037),
                    Color(red: 0.050, green: 0.036, blue: 0.024)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Canvas { context, size in
                let fineLine = StrokeStyle(lineWidth: 0.6)
                let gridColor = Color.cyan.opacity(0.075)
                let amber = Color.orange.opacity(0.13)
                let majorSpacing: CGFloat = 72
                let minorSpacing: CGFloat = 24

                var minorGrid = Path()
                var x: CGFloat = 0
                while x <= size.width {
                    minorGrid.move(to: CGPoint(x: x, y: 0))
                    minorGrid.addLine(to: CGPoint(x: x, y: size.height))
                    x += minorSpacing
                }

                var y: CGFloat = 0
                while y <= size.height {
                    minorGrid.move(to: CGPoint(x: 0, y: y))
                    minorGrid.addLine(to: CGPoint(x: size.width, y: y))
                    y += minorSpacing
                }
                context.stroke(minorGrid, with: .color(gridColor), style: fineLine)

                var majorGrid = Path()
                x = 0
                while x <= size.width {
                    majorGrid.move(to: CGPoint(x: x, y: 0))
                    majorGrid.addLine(to: CGPoint(x: x, y: size.height))
                    x += majorSpacing
                }

                y = 0
                while y <= size.height {
                    majorGrid.move(to: CGPoint(x: 0, y: y))
                    majorGrid.addLine(to: CGPoint(x: size.width, y: y))
                    y += majorSpacing
                }
                context.stroke(majorGrid, with: .color(Color.cyan.opacity(0.12)), style: StrokeStyle(lineWidth: 1))

                var scanner = Path()
                scanner.move(to: CGPoint(x: 0, y: size.height * 0.18))
                scanner.addLine(to: CGPoint(x: size.width * 0.64, y: size.height * 0.08))
                scanner.addLine(to: CGPoint(x: size.width, y: size.height * 0.16))
                scanner.move(to: CGPoint(x: size.width * 0.18, y: size.height))
                scanner.addLine(to: CGPoint(x: size.width, y: size.height * 0.74))
                context.stroke(scanner, with: .color(amber), style: StrokeStyle(lineWidth: 1.2, dash: [12, 10]))

                var frame = Path()
                frame.addRoundedRect(
                    in: CGRect(x: 18, y: 18, width: size.width - 36, height: size.height - 36),
                    cornerSize: CGSize(width: 28, height: 28)
                )
                context.stroke(frame, with: .color(Color.white.opacity(0.055)), style: StrokeStyle(lineWidth: 1))
            }
            .blendMode(.screen)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.38)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

#Preview {
    SynthwaveBackgroundView()
}
