import SwiftUI
import SwiftData

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

    // MARK: - Coordinator
final class CustomTabBarCoordinator: NSObject {
    var activeTab: Binding<CustomTab>
    
    init(activeTab: Binding<CustomTab>) {
        self.activeTab = activeTab
        super.init()
    }
    
    @objc func tabSelected(_ control: UISegmentedControl) {
        activeTab.wrappedValue = CustomTab.allCases[control.selectedSegmentIndex]
    }
}

    // MARK: - CustomTabBar
struct CustomTabBar<TabItemView: View>: UIViewRepresentable {
    var size: CGSize
    var activeTint: Color = .teal.opacity(0.7)
    var barTint: Color = .gray.opacity(0.15)
    @Binding var activeTab: CustomTab
    @ViewBuilder var tabItemView: (CustomTab) -> TabItemView
    
    func makeCoordinator() -> CustomTabBarCoordinator {
        CustomTabBarCoordinator(activeTab: $activeTab)
    }
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let items = CustomTab.allCases.map(\.rawValue)
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        
            // Configure appearance
        control.selectedSegmentTintColor = UIColor(barTint)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor(activeTint)
        ], for: .selected)
        
        DispatchQueue.main.async {
            for subview in control.subviews {
                if subview is UIImageView && subview != control.subviews.last {
                    subview.alpha = 0
                }
            }
        }
        
            // Set images
        for (index, tab) in CustomTab.allCases.enumerated() {
            let renderer = ImageRenderer(content: tabItemView(tab))
            renderer.scale = UIScreen.main.scale
            if let image = renderer.uiImage {
                control.setImage(image, forSegmentAt: index)
            }
        }
        
            // Hide dividers - more reliable approach
        DispatchQueue.main.async {
            control.subviews.forEach { subview in
                if String(describing: type(of: subview)).contains("Divider") {
                    subview.isHidden = true
                }
                if subview is UIImageView && subview.frame.width < 10 {
                    subview.isHidden = true
                }
            }
        }
        
        control.addTarget(context.coordinator,
                          action: #selector(context.coordinator.tabSelected(_:)),
                          for: .valueChanged)
        return control
    }
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = activeTab.index
        context.coordinator.activeTab = $activeTab
        
            // Re-render images with updated fill state
        for (index, tab) in CustomTab.allCases.enumerated() {
            let renderer = ImageRenderer(content: tabItemView(tab))
            renderer.scale = UIScreen.main.scale
            if let image = renderer.uiImage {
                uiView.setImage(image, forSegmentAt: index)
            }
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        return size
    }
}

    // MARK: - Extensions
extension View {
    @ViewBuilder
    func blurFade(_ status: Bool) -> some View {
        self
            .compositingGroup()
            .blur(radius: status ? 0 : 10)
            .opacity(status ? 1 : 0)
    }
    
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
    
    @ViewBuilder
    func compatibleGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            self
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
                .clipShape(Capsule())
        }
    }
}

struct ContentView: View {
    @AppStorage("lastSelectedTab") private var lastSelectedTabRawValue: String = CustomTab.student.rawValue
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var versionStore = RoutineVersionStore()
    @State private var isSectionSearchActive: Bool = false
    @State private var isTeacherSearchActive: Bool = false
    @State private var selectedTime: String? = nil
    private let webService = WebService()
    
    @State private var activeTab: CustomTab = .student
    
    private let timeSlots = [
        "08:30 - 10:00",
        "10:00 - 11:30",
        "11:30 - 01:00",
        "01:00 - 02:30",
        "02:30 - 04:00",
        "04:00 - 05:30"
    ]
    
    @State private var updateAppInfo: AppVersionManager.ReturnResult?
    @State private var forcedAppUpdate: Bool = false
    private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
    @Query private var routines: [RoutineDO]
    
    var body: some View {
        Group {
            if versionStore.inMaintenance {
                MaintenanceView()
                    .task {
                        await webService.fetchVersion(versionStore: versionStore, modelContext: modelContext)
                    }
            } else {
                ZStack(alignment: .bottom) {
                    TabView(selection: $activeTab) {
                        Tab(value: .student) {
                            StudentView(isSearchActive: $isSectionSearchActive)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab(value: .faculty) {
                            TeacherView(isSearchActive: $isTeacherSearchActive)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab(value: .emptyRoom) {
                            EmptyRoomView(selectedTime: $selectedTime)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                    
                    CustomTabBarView()
                        .padding(.horizontal, 20)
                }
                .compatibleSafeAreaBar(edge: .bottom, spacing: 0, content: {
                    Text(".")
                        .foregroundStyle(colorScheme == .light ? .white : .black)
                        .frame(height: 0)
                        .blendMode(.destinationOver)
                })
                .tint(Color(hue: 0.5, saturation: 0.8, brightness: colorScheme == .light ? 0.65 : 0.75))
                .refreshable {
                    if routines.isEmpty {
                        versionStore.clearData()
                        await webService.fetchVersion(versionStore: versionStore, modelContext: modelContext)
                    }
                }
                .task {
                    await webService.fetchVersion(versionStore: versionStore, modelContext: modelContext)
                }
                .task {
                    if let result = await AppVersionManager.shared.checkIfAppUpdateAvailable() {
                        updateAppInfo = result
                    }
                }
                .sheet(item: $updateAppInfo) { info in
                    UpdateAvailableSheet(appInfo: info, forceUpdate: forcedAppUpdate)
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
                    // iOS 18 fallback
                HStack(spacing: 10) {
                    TabBarContent()
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
            }
        }
        .frame(height: 65)
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
                .symbolVariant(tab == activeTab ? .fill : .none)
                .frame(maxWidth: .infinity)
                .frame(height: 65)
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
                                .frame(width: 65, height: 65)
                        }
                        .foregroundStyle(.primary)
                    } else {
                        Button {
                            if tab == .student {
                                isSectionSearchActive.toggle()
                            } else if tab == .faculty {
                                isTeacherSearchActive.toggle()
                            }
                        } label: {
                            Image(systemName: (isSectionSearchActive || isTeacherSearchActive) ? "checkmark" : tab.actionSymbol)
                                .font(.system(size: 22, weight: .medium))
                                .frame(width: 65, height: 65)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .blurFade(activeTab == tab)
            }
        }
        .compatibleGlassEffect()
        .animation(.smooth(duration: 0.55, extraBounce: 0), value: activeTab)
    }
}

#Preview {
    ContentView()
}
