import SwiftUI

struct TeacherInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let initial: String
    let imageUrl: String
    let designation: String
}

struct StudentInsight: View {
    let searchedSection: String
    let totalCoursesEnrolled: Int
    let totalWeeklyClasses: Int
    let totalWeeklyHours: String
    let courses: [(title: String, code: String)]
    let teachers: [TeacherInfo]
    let mergedRoutines: [MergedRoutine]
    
    @State private var versionStore = RoutineVersionStore()
    @State private var pdfURL: URL?
    @State private var showPDF = false
    
    init(
        searchedSection: String = "",
        totalCoursesEnrolled: Int = 0,
        totalWeeklyClasses: Int = 0,
        totalWeeklyHours: String = "0h 0m",
        courses: [(title: String, code: String)],
        teachers: [TeacherInfo],
        mergedRoutines: [MergedRoutine] = []
    ) {
        self.searchedSection = searchedSection
        self.totalCoursesEnrolled = totalCoursesEnrolled
        self.totalWeeklyClasses = totalWeeklyClasses
        self.totalWeeklyHours = totalWeeklyHours
        self.courses = courses
        self.teachers = teachers
        self.mergedRoutines = mergedRoutines
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
//        let _ = {
//            print("=== StudentInsight Received Data ===")
//            print("Section: \(searchedSection)")
//            print("Total Merged Routines: \(mergedRoutines.count)")
//            print("\nMerged Routines Details:")
//            for (index, routine) in mergedRoutines.enumerated() {
//                print("\n[\(index + 1)]")
//                print("  Course: \(routine.courseCode) - \(routine.courseTitle)")
//                print("  Teacher: \(routine.teacherInitial)")
//                print("  Time: \(routine.startTime) - \(routine.endTime)")
//                print("  Room: \(routine.room)")
//                print("  Section: \(routine.section)")
//                print("  Original routines count: \(routine.routines.count)")
//                if let firstRoutine = routine.routines.first {
//                    print("  Day from first routine: \(firstRoutine.day ?? "nil")")
//                }
//            }
//            print("====================================\n")
//        }()
        
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Section: ")
                                    .font(.headline.bold())
                                    .foregroundStyle(.gray)
                                
                                Text(searchedSection)
                                    .font(.headline.bold())
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                            
                            HStack {
                                Text("Version: ")
                                    .font(.headline.bold())
                                    .foregroundStyle(.gray)
                                Text(versionStore.routineVersion)
                                    .font(.headline.bold())
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                        }
                        
                        Spacer()
                        
                        
                        Button(action: {
                            if pdfURL != nil {
                                showPDF = true
                            }
                        }) {
                            ZStack(alignment: .center) {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.teal.opacity(0.1))
                                    .frame(height: 60)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(.gray.opacity(0.45), lineWidth: 1)
                                    )
                                
                                VStack(alignment: .center, spacing: 4) {
                                    Image(systemName: "arrow.down.app.fill")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.teal)
                                        .brightness(-0.1)
                                    
                                    Text("PDF")
                                        .lineLimit(1)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.teal)
                                        .fontWeight(.bold)
                                        .brightness(-0.1)
                                }
                            }
                        }
                        .frame(maxWidth: 70)
                    }
                    
                        
                    Divider()
                        .frame(height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Appointed Teachers")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.1)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        ForEach(teachers) { teacher in
                            HStack(spacing: 12) {
                                if let url = URL(string: teacher.imageUrl), !teacher.imageUrl.isEmpty {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                            case .empty:
                                                Circle()
                                                    .fill(.gray.opacity(0.3))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(ProgressView())
                                                
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                                    .transition(.opacity.combined(with: .scale))
                                                    .animation(.easeInOut, value: UUID())
                                                
                                            case .failure(_):
                                                Circle()
                                                    .fill(.gray.opacity(0.2))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(
                                                        Text(teacher.initial.prefix(2))
                                                            .font(.headline)
                                                            .foregroundColor(.primary)
                                                    )
                                                
                                            @unknown default:
                                                EmptyView()
                                        }
                                    }
                                } else {
                                    Circle()
                                        .fill(.gray.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(teacher.initial.prefix(2))
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        )
                                }
                                
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(teacher.name) - \(teacher.initial)")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(teacher.designation)
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.vertical)
                    
                    VStack(spacing: 10) {
                        Text("Enrolled Courses")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.1)
                            .padding(.bottom, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        ForEach(courses, id: \.code) { course in
                            HStack(alignment: .center) {
                                Text(course.title)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text(course.code)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                        }
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.vertical)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ], spacing: 16) {
                        
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            Text("Total Course Enrolled: \(totalCoursesEnrolled)")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 12))
                                .foregroundStyle(.primary.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .lineSpacing(4)
                        }
                        
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            Text("Total Weekly Classes: \(totalWeeklyClasses)")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 12))
                                .foregroundStyle(.primary.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .lineSpacing(4)
                        }
                        
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            Text("Weekly Class Hours: \(totalWeeklyHours)")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 12))
                                .foregroundStyle(.primary.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
            }
            
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("Insights").font(.title2.bold())
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if let url = pdfURL {
                        ShareLink(item: url) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .tint(.primary).contentShape(Rectangle())
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "multiply") {
                        dismiss()
                    }.tint(.primary).contentShape(Rectangle())
                }
            }
            .sheet(isPresented: $showPDF) {
                if let url = pdfURL {
                    PDFViewerView(url: url)
                }
            }
            .onAppear {
                generatePDF()
            }
        }
    }
    
    func generatePDF() {
        guard !mergedRoutines.isEmpty else { return }
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Class Routine App",
            kCGPDFContextTitle: "Class Routine - \(searchedSection)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let subtitleFont = UIFont.systemFont(ofSize: 14)
            let headerFont = UIFont.boldSystemFont(ofSize: 12)
            let bodyFont = UIFont.systemFont(ofSize: 11)
            
                // Title
            let title = "Class Routine - \(searchedSection)"
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2, y: 40, width: titleSize.width, height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
                // Version
            let subtitle = "Version: \(versionStore.routineVersion)"
            let subtitleAttributes: [NSAttributedString.Key: Any] = [.font: subtitleFont, .foregroundColor: UIColor.gray]
            let subtitleSize = subtitle.size(withAttributes: subtitleAttributes)
            let subtitleRect = CGRect(x: (pageRect.width - subtitleSize.width) / 2, y: 70, width: subtitleSize.width, height: subtitleSize.height)
            subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
            
                // Table setup
            let tableTop: CGFloat = 110
            let tableLeft: CGFloat = 40
            let colWidths: [CGFloat] = [80, 125, 75, 60, 60, 115] // Day, Time, Course, Section, Teacher, Room
            let rowHeight: CGFloat = 30
            let headers = ["Day", "Time", "Course", "Section", "Teacher", "Room"]
            
                // Draw table header (centered)
            var xPos = tableLeft
            let headerRect = CGRect(x: tableLeft, y: tableTop, width: colWidths.reduce(0, +), height: rowHeight)
            context.cgContext.setFillColor(UIColor.systemTeal.withAlphaComponent(0.2).cgColor)
            context.cgContext.fill(headerRect)
            
            for (i, header) in headers.enumerated() {
                let rect = CGRect(x: xPos, y: tableTop + 7, width: colWidths[i], height: rowHeight)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                let attr: [NSAttributedString.Key: Any] = [.font: headerFont, .paragraphStyle: paragraphStyle]
                header.draw(in: rect, withAttributes: attr)
                xPos += colWidths[i]
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(1.5)
            context.cgContext.stroke(headerRect)
            
                // Draw vertical lines between header columns
            xPos = tableLeft
            for i in 0..<colWidths.count {
                xPos += colWidths[i]
                if i < colWidths.count - 1 {
                    context.cgContext.move(to: CGPoint(x: xPos, y: tableTop))
                    context.cgContext.addLine(to: CGPoint(x: xPos, y: tableTop + rowHeight))
                    context.cgContext.strokePath()
                }
            }
            
                // Draw table rows with merged Day cells and dynamic row height
            var yPos = tableTop + rowHeight
            var index = 0
            while index < mergedRoutines.count {
                let routine = mergedRoutines[index]
                let day = routine.routines.first?.day ?? "-"
                
                    // Count how many consecutive routines have the same day
                var span = 1
                for nextIndex in (index + 1)..<mergedRoutines.count {
                    let nextRoutine = mergedRoutines[nextIndex]
                    if nextRoutine.routines.first?.day == day {
                        span += 1
                    } else {
                        break
                    }
                }
                
                    // Calculate maximum row height for this span
                var maxRowHeight: CGFloat = rowHeight
                for row in 0..<span {
                    let r = mergedRoutines[index + row]
                    let values = [
                        "", // Day column will be drawn separately
                        "\(format12Hour(r.startTime)) - \(format12Hour(r.endTime))",
                        r.courseCode,
                        r.section,
                        r.teacherInitial,
                        r.room
                    ]
                    
                    for (i, value) in values.enumerated() {
                        let maxWidth = colWidths[i] - 10
                        let size = NSString(string: value).boundingRect(
                            with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                            attributes: [.font: bodyFont],
                            context: nil
                        )
                        maxRowHeight = max(maxRowHeight, size.height + 14) // 7 top + 7 bottom inset
                    }
                }
                
                    // Draw Day cell once for 'span' rows
                let dayRect = CGRect(x: tableLeft, y: yPos, width: colWidths[0], height: maxRowHeight * CGFloat(span))
                context.cgContext.stroke(dayRect)
                
                    // Vertically center the Day text
                let dayTextSize = day.size(withAttributes: [.font: bodyFont])
                let dayTextY = yPos + (maxRowHeight * CGFloat(span) - dayTextSize.height) / 2
                let centeredDayRect = CGRect(x: tableLeft, y: dayTextY, width: colWidths[0], height: dayTextSize.height)
                let dayPara = NSMutableParagraphStyle()
                dayPara.alignment = .center
                let dayAttr: [NSAttributedString.Key: Any] = [.font: bodyFont, .paragraphStyle: dayPara]
                day.draw(in: centeredDayRect, withAttributes: dayAttr)
                
                    // Draw the rest columns for each routine in the span
                for row in 0..<span {
                    let r = mergedRoutines[index + row]
                    let values = [
                        "", // Day is already drawn
                        "\(format12Hour(r.startTime)) - \(format12Hour(r.endTime))",
                        r.courseCode,
                        r.section,
                        r.teacherInitial,
                        r.room
                    ]
                    
                    var xCell = tableLeft
                    for (i, value) in values.enumerated() {
                        let cellRect = CGRect(x: xCell, y: yPos + CGFloat(row) * maxRowHeight, width: colWidths[i], height: maxRowHeight)
                        
                            // Draw vertical lines only for columns other than Day
                        if i != 0 {
                            context.cgContext.stroke(cellRect)
                        }
                        
                            // Text alignment - center all content
                        let para = NSMutableParagraphStyle()
                        para.alignment = .center
                        value.draw(in: cellRect.insetBy(dx: 5, dy: 7), withAttributes: [.font: bodyFont, .paragraphStyle: para])
                        
                        xCell += colWidths[i]
                    }
                }
                
                yPos += maxRowHeight * CGFloat(span)
                index += span
            }
            
            
                // Draw footer with logo and text at the bottom of the page
            let footerY = pageRect.height - 50 // 50 points from bottom
            let logoSize: CGFloat = 30
            let paddingBetweenLogoAndText: CGFloat = 10 // Padding between logo and text
            
                // Calculate total width of logo + padding + text for proper centering
            let footerText = "Made With DIU Routine"
            let footerFont = UIFont.systemFont(ofSize: 12, weight: .medium)
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: footerFont,
                .foregroundColor: UIColor.gray
            ]
            let footerTextSize = footerText.size(withAttributes: footerAttributes)
            let totalWidth = logoSize + paddingBetweenLogoAndText + footerTextSize.width
            
                // Calculate starting X position to center everything
            let startX = (pageRect.width - totalWidth) / 2
            
                // Draw logo from Assets catalog
            if let logoImage = UIImage(named: "app") {
                let logoRect = CGRect(x: startX, y: footerY, width: logoSize, height: logoSize)
                logoImage.draw(in: logoRect)
            }
            
                // Draw "Made With DIU Routine" text
            let footerTextX = startX + logoSize + paddingBetweenLogoAndText
            let footerTextRect = CGRect(
                x: footerTextX,
                y: footerY + (logoSize - footerTextSize.height) / 2, // Vertically center with logo
                width: footerTextSize.width,
                height: footerTextSize.height
            )
            footerText.draw(in: footerTextRect, withAttributes: footerAttributes)
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ClassRoutine - \(searchedSection).pdf")
        try? data.write(to: tempURL)
        pdfURL = tempURL
    }

}

