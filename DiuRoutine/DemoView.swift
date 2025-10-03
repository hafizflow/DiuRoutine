import SwiftUI
import PDFKit

struct DemoPDFView: View {
    @State private var pdfURL: URL?
    @State private var showPDF = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Generate Demo PDF") {
                generateDemoPDF()
            }
            .padding()
            
            if pdfURL != nil {
                Button("Show PDF") {
                    showPDF = true
                }
                .padding()
            }
        }
        .sheet(isPresented: $showPDF) {
            if let url = pdfURL {
                PDFKitView2(url: url)
            }
        }
    }
    
    func generateDemoPDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "Class Routine App",
            kCGPDFContextTitle: "Class Routine Demo"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
                // Fonts
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let headerFont = UIFont.boldSystemFont(ofSize: 14)
            let bodyFont = UIFont.systemFont(ofSize: 12)
            
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.black
            ]
            
                // Title
            let title = "Demo Class Routine"
            title.draw(at: CGPoint(x: 150, y: 40),
                       withAttributes: [.font: titleFont, .foregroundColor: UIColor.black])
            
                // Table headers
            let headers = ["Day", "Time", "Course", "Teacher", "Room"]
            let columnWidths = [80, 100, 150, 100, 80]
            let startX: CGFloat = 40
            var currentX = startX
            var currentY: CGFloat = 100
            
            for (i, header) in headers.enumerated() {
                let rect = CGRect(x: currentX, y: currentY,
                                  width: CGFloat(columnWidths[i]), height: 30)
                header.draw(in: rect, withAttributes: [.font: headerFont])
                currentX += rect.width
            }
            
                // Demo rows
            let demoData = [
                ["Sunday", "09:00 - 10:30", "CSE101", "Dr. Rahman", "Room 201"],
                ["Sunday", "10:45 - 12:15", "MAT202", "Prof. Karim", "Room 305"],
                ["Monday", "09:00 - 10:30", "PHY303", "Dr. Ali", "Room 101"]
            ]
            
            currentY += 40
            
            for row in demoData {
                currentX = startX
                for (index, text) in row.enumerated() {
                    let rect = CGRect(x: currentX, y: currentY,
                                      width: CGFloat(columnWidths[index]), height: 25)
                    text.draw(in: rect, withAttributes: bodyAttrs)
                    currentX += rect.width
                }
                currentY += 30
            }
        }
        
            // Save to temporary directory
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("DemoRoutine.pdf")
        do {
            try data.write(to: tempURL)
            self.pdfURL = tempURL
            print("PDF saved at: \(tempURL)")
        } catch {
            print("Error writing PDF: \(error)")
        }
    }
}

struct PDFKitView2: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

#Preview {
    DemoPDFView()
}
