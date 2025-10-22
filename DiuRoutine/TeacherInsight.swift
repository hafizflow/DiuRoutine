import SwiftUI
import Toast

struct TeacherData {
    let name: String
    let initial: String
    let designation: String
    let phone: String
    let email: String
    let room: String
    let imageUrl: String
}

struct TeacherInsights: View {
    let searchedTeacher: String
    let sections: [String]
    let totalCoursesEnrolled: Int
    let totalWeeklyClasses: Int
    let totalWeeklyHours: String
    let courses: [(title: String, code: String)]
    let teacher: TeacherData
    let mergedRoutines: [MergedRoutine]
    
    init(
        searchedTeacher: String = "",
        sections: [String] = [],
        totalCoursesEnrolled: Int = 0,
        totalWeeklyClasses: Int = 0,
        totalWeeklyHours: String = "0h 0m",
        courses: [(title: String, code: String)],
        teacher: TeacherData,
        mergedRoutines: [MergedRoutine] = []
    ) {
        self.searchedTeacher = searchedTeacher
        self.sections = sections
        self.totalCoursesEnrolled = totalCoursesEnrolled
        self.totalWeeklyClasses = totalWeeklyClasses
        self.totalWeeklyHours = totalWeeklyHours
        self.courses = courses
        self.teacher = teacher
        self.mergedRoutines = mergedRoutines
    }
    
    
        // ✅ Fallback values declared once
    private var teacherName: String { teacher.name.isEmpty ? "Unknown" : teacher.name }
    private var teacherDesignation: String { teacher.designation.isEmpty ? "Lecturer" : teacher.designation }
    private var teacherEmail: String { teacher.email.isEmpty || teacher.email == "N/A" ? "N/A" : teacher.email }
    private var teacherPhone: String { teacher.phone.isEmpty || teacher.phone == "N/A" ? "N/A" : teacher.phone }
    private var teacherRoom: String { teacher.room.isEmpty || teacher.room == "N/A" ? "N/A" : teacher.room }
    private var teacherImageUrl: String { teacher.imageUrl.isEmpty ? "https://via.placeholder.com/55" : teacher.imageUrl }
    
        // Helper computed properties
    private var hasValidPhone: Bool { teacherPhone != "N/A" }
    private var hasValidEmail: Bool { teacherEmail != "N/A" }
    
    @Environment(\.dismiss) var dismiss
    @State private var versionStore = RoutineVersionStore()
    @State private var pdfURL: URL?
    @State private var showPDF = false
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Initial:")
                                    .font(.headline.bold())
                                    .foregroundStyle(.gray)
                                
                                Text(searchedTeacher)
                                    .font(.headline.bold())
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                            
                            HStack {
                                Text("Sections:")
                                    .font(.headline.bold())
                                    .foregroundStyle(.gray)
                                Text(sections.joined(separator: ", "))
                                    .font(.headline.bold())
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                        }
                        Spacer()
                        
                        Button(action: {
                            generateTeacherPDF()
                            impactFeedback.impactOccurred()
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
                        .onChange(of: pdfURL) { _, newURL in if newURL != nil { showPDF = true } }
                    }
                    .padding(.bottom, 32)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(teacherName)
                            .lineLimit(1)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                            .padding(.bottom, 0)
                        
                        Divider()
                            .frame(width: 150, height: 1)
                            .background(.gray.opacity(0.45))
                            .padding(.bottom, 4)
                        
                        HStack(spacing: 16) {
                            if let url = URL(string: teacherImageUrl), !teacherImageUrl.isEmpty {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                        case .empty:
                                            Circle()
                                                .fill(.gray.opacity(0.3))
                                                .frame(width: 55, height: 55)
                                                .overlay(ProgressView())
                                            
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 55, height: 55)
                                                .clipShape(Circle())
                                                .transition(.opacity.combined(with: .scale))
                                                .animation(.easeInOut, value: UUID())
                                            
                                        case .failure(_):
                                            Circle()
                                                .fill(.gray.opacity(0.3))
                                                .frame(width: 55, height: 55)
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
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 55, height: 55)
                                    .overlay(Image(systemName: "person.fill").foregroundStyle(.gray))
                            }
                            
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("Desig: ")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.gray)
                                    
                                    Text(teacherDesignation)
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary.opacity(0.8))
                                }
                                
                                HStack(alignment: .center, spacing: 0) {
                                    Text("Phone: ")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.gray)
                                    
                                    if hasValidPhone {
                                        Link(teacherPhone, destination: URL(string: "tel:\(teacherPhone)")!)
                                            .font(.system(size: 16))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.teal.opacity(0.9))
                                            .brightness(-0.2)
                                    } else {
                                        Text(teacherPhone)
                                            .font(.system(size: 16))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.primary.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    if hasValidPhone {
                                        Button(action: {
                                            UIPasteboard.general.string = teacherPhone
                                            impactFeedback.impactOccurred()
                                            
                                            
                                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                               let window = windowScene.windows.first {
                                                
                                                let config = ToastConfiguration(
                                                    direction: .top,
                                                    dismissBy: [.time(time: 3.0), .swipe(direction: .natural), .longPress],
                                                    animationTime: 0.2,
                                                    attachTo: window
                                                )
                                                
                                                let toast = Toast.default(
                                                    image: UIImage(systemName: "square.on.square.fill")!,
                                                    title: "Copyed to Clipboard",
                                                    subtitle: teacherPhone,
                                                    config: config
                                                )
                                                toast.show()
                                            }
                                        }) {
                                            Image(systemName: "square.on.square")
                                                .foregroundStyle(.teal.opacity(0.9))
                                                .brightness(-0.2)
                                                .font(.system(size: 16))
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack (alignment: .center, spacing: 0){
                            Text("Email: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            if hasValidEmail {
                                Text(teacherEmail)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary.opacity(0.8))
                                    .textSelection(.enabled)
                            } else {
                                Text(teacherEmail)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            if hasValidEmail {
                                Button(action: {
                                    UIPasteboard.general.string = teacherEmail
                                    impactFeedback.impactOccurred()
                                    
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first {
                                        
                                        let config = ToastConfiguration(
                                            direction: .top,
                                            dismissBy: [.time(time: 3.0), .swipe(direction: .natural), .longPress],
                                            animationTime: 0.2,
                                            attachTo: window
                                        )
                                        
                                        let toast = Toast.default(
                                            image: UIImage(systemName: "square.on.square.fill")!,
                                            title: "Copyed to Clipboard",
                                            subtitle: teacherEmail,
                                            config: config
                                        )
                                        toast.show()
                                    }
                                    
                                }) {
                                    Image(systemName: "square.on.square")
                                        .foregroundStyle(.teal.opacity(0.9))
                                        .brightness(-0.2)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        
                        HStack (alignment: .center, spacing: 0){
                            Text("Room: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text(teacherRoom)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    
                    Divider()
                        .frame(height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.vertical)
                    
                    VStack(spacing: 8) {
                        Text("Provided Courses")
                            .lineLimit(1)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
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
                            
                            Text("Total Course Provided: \(totalCoursesEnrolled)")
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
                    Button("Settings", systemImage: "magnifyingglass") {
                        
                    }.tint(.primary).contentShape(Rectangle())
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

        }
    }
    
    func generateTeacherPDF() {
        guard !mergedRoutines.isEmpty else { return }
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Class Routine App",
            kCGPDFContextTitle: "Class Routine - \(searchedTeacher)"
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
            let title = "Class Routine - \(searchedTeacher)"
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
            let colWidths: [CGFloat] = [85, 130, 80, 70, 140] // Day, Time, Course, Section, Room (Teacher REMOVED)
            let rowHeight: CGFloat = 30
            let headers = ["Day", "Time", "Course", "Section", "Room"]
            
                // Draw table header
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
            
                // Draw table rows with merged Day cells
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
                        "", // Day column drawn separately
                        "\(format12Hour(r.startTime)) - \(format12Hour(r.endTime))",
                        r.courseCode,
                        r.section,
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
                        maxRowHeight = max(maxRowHeight, size.height + 14)
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
                
                    // Draw the rest columns for each routine
                for row in 0..<span {
                    let r = mergedRoutines[index + row]
                    let values = [
                        "", // Day already drawn
                        "\(format12Hour(r.startTime)) - \(format12Hour(r.endTime))",
                        r.courseCode,
                        r.section,
                        r.room
                    ]
                    
                    var xCell = tableLeft
                    for (i, value) in values.enumerated() {
                        let cellRect = CGRect(x: xCell, y: yPos + CGFloat(row) * maxRowHeight, width: colWidths[i], height: maxRowHeight)
                        
                        if i != 0 {
                            context.cgContext.stroke(cellRect)
                        }
                        
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
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ClassRoutine - \(searchedTeacher).pdf")
        try? data.write(to: tempURL)
        pdfURL = tempURL
        showPDF = true
    }
}
