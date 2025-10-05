//import SwiftUI
//
//    // Tab Items!
//enum CustomTab: String, CaseIterable, Hashable {
//    case student = "Student"
//    case faculty = "Faculty"
//    case emptyRoom = "EmptyRoom"
//    
//    var symbol: String {
//        switch self {
//            case .student: return "graduationcap"
//            case .faculty: return "person.crop.rectangle.stack"
//            case .emptyRoom: return "square.stack"
//        }
//    }
//    
//    var actionSymbol: String {
//        switch self {
//            case .student: return "magnifyingglass"
//            case .faculty: return "text.magnifyingglass"
//            case .emptyRoom: return "clock.badge.questionmark"
//        }
//    }
//    
//    var index: Int {
//        Self.allCases.firstIndex(of: self) ?? 0
//    }
//}
//
//struct CustomTabBar<TabItemView: View>: UIViewRepresentable {
//    var size: CGSize
//    var activeTint: Color = .teal.opacity(0.7)
//    var barTint: Color = .gray.opacity(0.15)
//    @Binding var activeTab: CustomTab
//    @ViewBuilder var tabItemView: (CustomTab) -> TabItemView
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//    
//    func makeUIView(context: Context) -> UISegmentedControl {
//        let items = CustomTab.allCases.map(\.rawValue)
//        let control = UISegmentedControl(items: items)
//        control.selectedSegmentIndex = 0
//        
//            // Converting Tab Item View into an image!
//        for (index, tab) in CustomTab.allCases.enumerated() {
//            let renderer = ImageRenderer(content: tabItemView(tab))
//                // 2 is enough, but you can change it as per your wish!
//            renderer.scale = 2
//            let image = renderer.uiImage
//            control.setImage(image, forSegmentAt: index)
//        }
//        
//        DispatchQueue.main.async {
//            for subview in control.subviews {
//                if subview is UIImageView && subview != control.subviews.last {
//                        // It's a background Image View!
//                    subview.alpha = 0
//                }
//            }
//        }
//        
//        control.selectedSegmentTintColor = UIColor(barTint)
//        control.setTitleTextAttributes([
//            .foregroundColor: UIColor(activeTint)
//        ], for: .selected)
//        
//        control.addTarget(context.coordinator, action:
//                            #selector(context.coordinator.tabSelected(_:)), for: .valueChanged)
//        return control
//    }
//    
//    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
//        uiView.selectedSegmentIndex = activeTab.index
//    }
//    
//    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
//        return size
//    }
//    
//    class Coordinator: NSObject {
//        var parent: CustomTabBar
//        init(parent: CustomTabBar) {
//            self.parent = parent
//        }
//        
//        @objc func tabSelected(_ control: UISegmentedControl) {
//            parent.activeTab = CustomTab.allCases[control.selectedSegmentIndex]
//        }
//    }
//}
//
//    // Blur Fade In/Out
//extension View {
//    @ViewBuilder
//    func blurFade(_ status: Bool) -> some View {
//        self
//            .compositingGroup()
//            .blur(radius: status ? 0 : 10)
//            .opacity(status ? 1 : 0)
//    }
//}
//
//struct ContentView: View {
//        // Store the raw value (String) in AppStorage
//    @AppStorage("lastSelectedTab") private var lastSelectedTabRawValue: String = CustomTab.student.rawValue
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.colorScheme) private var colorScheme
//    @State private var versionStore = RoutineVersionStore()
//    @State private var isSectionSearchActive: Bool = false
//    @State private var isTeacherSearchActive: Bool = false
//    @State private var selectedTime: String? = nil
//    private let webService = WebService()
//    
//        // State variable for the actual tab
//    @State private var activeTab: CustomTab = .student
//    
//        // Cached time slots to avoid recreation
//    private let timeSlots = [
//        "08:30 - 10:00",
//        "10:00 - 11:30",
//        "11:30 - 01:00",
//        "01:00 - 02:30",
//        "02:30 - 04:00",
//        "04:00 - 05:30"
//    ]
//    
//    var body: some View {
//        Group {
//            if versionStore.inMaintenance {
//                MaintenanceView()
//            } else {
//                TabView(selection: $activeTab) {
//                    Tab(value: .student) {
//                        StudentView(isSearchActive: $isSectionSearchActive)
//                            .safeAreaBar(edge: .bottom, spacing: 0, content: {
//                                Text(".")
//                                    .foregroundStyle(colorScheme == .light ? .white : .black)
//                                    .blendMode(.destinationOver)
//                            })
//                            .toolbarVisibility(.hidden, for: .tabBar)
//                    }
//                    
//                    Tab(value: .faculty) {
//                        TeacherView(isSearchActive: $isTeacherSearchActive)
//                            .safeAreaBar(edge: .bottom, spacing: 0, content: {
//                                Text(".")
//                                    .foregroundStyle(colorScheme == .light ? .white : .black)
//                                    .blendMode(.destinationOver)
//                            })
//                            .toolbarVisibility(.hidden, for: .tabBar)
//                    }
//                    
//                    Tab(value: .emptyRoom) {
//                        EmptyRoomView(selectedTime: $selectedTime)
//                            .safeAreaBar(edge: .bottom, spacing: 0, content: {
//                                Text(".")
//                                    .foregroundStyle(colorScheme == .light ? .white : .black)
//                                    .blendMode(.destinationOver)
//                            })
//                            .toolbarVisibility(.hidden, for: .tabBar)
//                    }
//                }
//                .safeAreaInset(edge: .bottom, spacing: 0) {
//                    CustomTabBarView()
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 32)
//                }
//                .ignoresSafeArea(.all, edges: .bottom)
//                .tint(Color(hue: 0.5, saturation: 0.8, brightness: colorScheme == .light ? 0.65 : 0.75))
//                .task {
//                    await webService.fetchVersion(versionStore: versionStore, modelContext: modelContext)
//                }
//                .onAppear {
//                    if let savedTab = CustomTab(rawValue: lastSelectedTabRawValue) {
//                        activeTab = savedTab
//                    }
//                }
//                .onChange(of: activeTab) { oldValue, newValue in
//                    lastSelectedTabRawValue = newValue.rawValue
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    func CustomTabBarView() -> some View {
//        HStack(spacing: 10) {
//            GlassEffectContainer(spacing: 10) {
//                GeometryReader { geometry in
//                    CustomTabBar(size: geometry.size, activeTab: $activeTab) { tab in
//                        VStack(spacing: 3) {
//                            Image(systemName: tab.symbol)
//                                .font(.title3)
//                            
//                            Text(tab.rawValue)
//                                .font(.system(size: 10))
//                                .fontWeight(.medium)
//                        }
//                        .symbolVariant(.fill)
//                        .frame(maxWidth: .infinity)
//                    }
//                    .glassEffect(.regular.interactive(), in: .capsule)
//                }
//                
//                ZStack {
//                    ForEach(CustomTab.allCases, id: \.rawValue) { tab in
//                        Group {
//                            if tab == .emptyRoom {
//                                Menu {
//                                    ForEach(timeSlots, id: \.self) { time in
//                                        Button {
//                                            selectedTime = time
//                                        } label: {
//                                            Label(time, systemImage: selectedTime == time ? "checkmark" : "")
//                                        }
//                                    }
//                                } label: {
//                                    Image(systemName: tab.actionSymbol)
//                                        .font(.system(size: 22, weight: .medium))
//                                }
//                                .foregroundStyle(.primary)
//                                .frame(width: 60, height: 60)
//                                .contentShape(Rectangle())
//                            } else {
//                                Button {
//                                    if tab == .student {
//                                        isSectionSearchActive.toggle()
//                                    } else if tab == .faculty {
//                                        isTeacherSearchActive.toggle()
//                                    }
//                                } label: {
//                                    Image(systemName: tab.actionSymbol)
//                                        .font(.system(size: 22, weight: .medium))
//                                }
//                                .foregroundStyle(.primary)
//                                .frame(width: 60, height: 60)
//                                .contentShape(Rectangle())
//                            }
//                        }
//                        .blurFade(activeTab == tab)
//                    }
//                }
//                .glassEffect(.regular.interactive(), in: .capsule)
//                .animation(.smooth(duration: 0.55, extraBounce: 0), value: activeTab)
//            }
//        }
//        .frame(height: 60)
//    }
//}
//
//#Preview {
//    ContentView()
//}



import SwiftUI

    // Tab Items!
enum CustomTab: String, CaseIterable, Hashable {
    case student = "Student"
    case faculty = "Faculty"
    case emptyRoom = "EmptyRoom"
    
    var symbol: String {
        switch self {
            case .student: return "graduationcap"
            case .faculty: return "person.crop.rectangle.stack"
            case .emptyRoom: return "square.stack"
        }
    }
    
    var actionSymbol: String {
        switch self {
            case .student: return "magnifyingglass"
            case .faculty: return "text.magnifyingglass"
            case .emptyRoom: return "clock.badge.questionmark"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

struct CustomTabBar<TabItemView: View>: UIViewRepresentable {
    var size: CGSize
    var activeTint: Color = .teal.opacity(0.7)
    var barTint: Color = .gray.opacity(0.15)
    @Binding var activeTab: CustomTab
    @ViewBuilder var tabItemView: (CustomTab) -> TabItemView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let items = CustomTab.allCases.map(\.rawValue)
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        
            // Converting Tab Item View into an image!
        for (index, tab) in CustomTab.allCases.enumerated() {
            let renderer = ImageRenderer(content: tabItemView(tab))
                // 2 is enough, but you can change it as per your wish!
            renderer.scale = 2
            let image = renderer.uiImage
            control.setImage(image, forSegmentAt: index)
        }
        
        DispatchQueue.main.async {
            for subview in control.subviews {
                if subview is UIImageView && subview != control.subviews.last {
                        // It's a background Image View!
                    subview.alpha = 0
                }
            }
        }
        
        control.selectedSegmentTintColor = UIColor(barTint)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor(activeTint)
        ], for: .selected)
        
        control.addTarget(context.coordinator, action:
                            #selector(context.coordinator.tabSelected(_:)), for: .valueChanged)
        return control
    }
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = activeTab.index
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        return size
    }
    
    class Coordinator: NSObject {
        var parent: CustomTabBar
        init(parent: CustomTabBar) {
            self.parent = parent
        }
        
        @objc func tabSelected(_ control: UISegmentedControl) {
            parent.activeTab = CustomTab.allCases[control.selectedSegmentIndex]
        }
    }
}

    // Blur Fade In/Out
extension View {
    @ViewBuilder
    func blurFade(_ status: Bool) -> some View {
        self
            .compositingGroup()
            .blur(radius: status ? 0 : 10)
            .opacity(status ? 1 : 0)
    }
    
        // Fallback for safeAreaBar on iOS versions below 26
    @ViewBuilder
    func compatibleSafeAreaBar<Content: View>(
        edge: VerticalEdge,
        spacing: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.safeAreaBar(edge: edge, spacing: spacing, content: content)
        } else {
            self.overlay(alignment: edge == .bottom ? .bottom : .top) {
                content()
            }
        }
    }
}

struct ContentView: View {
        // Store the raw value (String) in AppStorage
    @AppStorage("lastSelectedTab") private var lastSelectedTabRawValue: String = CustomTab.student.rawValue
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var versionStore = RoutineVersionStore()
    @State private var isSectionSearchActive: Bool = false
    @State private var isTeacherSearchActive: Bool = false
    @State private var selectedTime: String? = nil
    private let webService = WebService()
    
        // State variable for the actual tab
    @State private var activeTab: CustomTab = .student
    
        // Cached time slots to avoid recreation
    private let timeSlots = [
        "08:30 - 10:00",
        "10:00 - 11:30",
        "11:30 - 01:00",
        "01:00 - 02:30",
        "02:30 - 04:00",
        "04:00 - 05:30"
    ]
    
    var body: some View {
        Group {
            if versionStore.inMaintenance {
                MaintenanceView()
            } else {
                TabView(selection: $activeTab) {
                    Tab(value: .student) {
                        StudentView(isSearchActive: $isSectionSearchActive)
                            .compatibleSafeAreaBar(edge: .bottom, spacing: 0, content: {
                                Text(".")
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                                    .blendMode(.destinationOver)
                            })
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                    
                    Tab(value: .faculty) {
                        TeacherView(isSearchActive: $isTeacherSearchActive)
                            .compatibleSafeAreaBar(edge: .bottom, spacing: 0, content: {
                                Text(".")
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                                    .blendMode(.destinationOver)
                            })
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                    
                    Tab(value: .emptyRoom) {
                        EmptyRoomView(selectedTime: $selectedTime)
                            .compatibleSafeAreaBar(edge: .bottom, spacing: 0, content: {
                                Text(".")
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                                    .blendMode(.destinationOver)
                            })
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    CustomTabBarView()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
                .ignoresSafeArea(.all, edges: .bottom)
                .tint(Color(hue: 0.5, saturation: 0.8, brightness: colorScheme == .light ? 0.65 : 0.75))
                .task {
                    await webService.fetchVersion(versionStore: versionStore, modelContext: modelContext)
                }
                .onAppear {
                    if let savedTab = CustomTab(rawValue: lastSelectedTabRawValue) {
                        activeTab = savedTab
                    }
                }
                .onChange(of: activeTab) { oldValue, newValue in
                    lastSelectedTabRawValue = newValue.rawValue
                }
            }
        }
    }
    
    @ViewBuilder
    func CustomTabBarView() -> some View {
        HStack(spacing: 10) {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 10) {
                    TabBarContent()
                }
            } else {
                    // Fallback for iOS < 26
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    HStack(spacing: 10) {
                        TabBarContent()
                    }
                    .padding(10)
                }
            }
        }
        .frame(height: 60)
    }
    
    @ViewBuilder
    func TabBarContent() -> some View {
        GeometryReader { geometry in
            CustomTabBar(size: geometry.size, activeTab: $activeTab) { tab in
                VStack(spacing: 3) {
                    Image(systemName: tab.symbol)
                        .font(.title3)
                    
                    Text(tab.rawValue)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                }
                .symbolVariant(.fill)
                .frame(maxWidth: .infinity)
            }
            .compatibleGlassEffect()
        }
        
        ZStack {
            ForEach(CustomTab.allCases, id: \.rawValue) { tab in
                Group {
                    if tab == .emptyRoom {
                        Menu {
                            ForEach(timeSlots, id: \.self) { time in
                                Button {
                                    selectedTime = time
                                } label: {
                                    Label(time, systemImage: selectedTime == time ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Image(systemName: tab.actionSymbol)
                                .font(.system(size: 22, weight: .medium))
                        }
                        .foregroundStyle(.primary)
                        .frame(width: 60, height: 60)
                        .contentShape(Rectangle())
                    } else {
                        Button {
                            if tab == .student {
                                isSectionSearchActive.toggle()
                            } else if tab == .faculty {
                                isTeacherSearchActive.toggle()
                            }
                        } label: {
                            Image(systemName: tab.actionSymbol)
                                .font(.system(size: 22, weight: .medium))
                        }
                        .foregroundStyle(.primary)
                        .frame(width: 60, height: 60)
                        .contentShape(Rectangle())
                    }
                }
                .blurFade(activeTab == tab)
            }
        }
        .compatibleGlassEffect()
        .animation(.smooth(duration: 0.55, extraBounce: 0), value: activeTab)
    }
}

    // Extension for compatible glass effect
extension View {
    @ViewBuilder
    func compatibleGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            self
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ContentView()
}
