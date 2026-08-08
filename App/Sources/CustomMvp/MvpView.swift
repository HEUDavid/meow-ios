import MeowModels
import NetworkExtension
import SwiftData
import SwiftUI

// MARK: - AdGuard Custom Shield Shape
struct AdGuardShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.18),
            control1: CGPoint(x: w * 0.82, y: 0),
            control2: CGPoint(x: w, y: h * 0.08)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w, y: h * 0.62),
            control2: CGPoint(x: w * 0.72, y: h * 0.92)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.18),
            control1: CGPoint(x: w * 0.28, y: h * 0.92),
            control2: CGPoint(x: 0, y: h * 0.62)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.08),
            control2: CGPoint(x: w * 0.18, y: 0)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Main MvpView
struct MvpView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [Profile]

    @State private var mvpManager = MvpManager.shared
    @State private var urlInput: String = ""
    @State private var isShieldPressed: Bool = false

    // Tap counter for 5-tap easter egg to switch back to full meow-ios mode
    @State private var minimalTapCount: Int = 0
    @State private var lastTapTime: Date? = nil

    @State private var logExportDocument: MvpLogExportDocument?
    @State private var showingLogExporter = false
    @State private var exportingLogs = false

    private var activeProfile: Profile? {
        profiles.first(where: \.isSelected) ?? profiles.first
    }

    private var hasProfile: Bool {
        activeProfile != nil
    }

    private var isStart: Bool {
        appModel.vpnManager.stage == .connected
    }

    private var coreStatusText: String {
        switch appModel.vpnManager.stage {
        case .connected:
            return "正常"
        case .connecting, .preparing:
            return "启动中"
        default:
            return "停用"
        }
    }

    var body: some View {
        ZStack {
            MvpTheme.bgPrimary
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // 1. Top Header Bar
                    buildHeaderBar()

                    Spacer(minLength: 12)

                    // 2. Central Protection Shield Hero Area
                    buildShieldHero()

                    Spacer(minLength: 12)

                    // 3. Quick Info Cards (防护状态 & 内核状态)
                    buildQuickInfoCards()

                    // 4. Subscription Config Card
                    buildProfileConfigCard()

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            // Toast Notification Overlay
            if let toastMsg = mvpManager.toastMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: toastIconName(for: mvpManager.toastType))
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .semibold))
                        Text(toastMsg)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(MvpTheme.toastBg)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: toastMsg)
            }
        }
        .fileExporter(
            isPresented: $showingLogExporter,
            document: logExportDocument,
            contentType: .plainText,
            defaultFilename: "blockad-log-\(logTimestamp).log",
            onCompletion: { _ in
                logExportDocument = nil
            }
        )
    }

    // MARK: - 1. Header Bar Component
    private func buildHeaderBar() -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                // Shield Logo with 5-Tap Easter Egg
                ZStack {
                    Circle()
                        .fill(MvpTheme.activeColor.opacity(0.12))
                        .frame(width: 36, height: 36)

                    AdGuardShieldShape()
                        .fill(MvpTheme.activeColor)
                        .frame(width: 24, height: 28)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .onTapGesture {
                    handleMinimalTap()
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Block Ad")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(MvpTheme.textPrimary)

                    Text("智能拦截与隐私保护")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(MvpTheme.textSecondary)
                }
            }

            Spacer()

            // Log Export Button
            Button(action: {
                Task { await exportLogs() }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(MvpTheme.borderColor.opacity(0.6))
                        .frame(width: 32, height: 32)

                    if exportingLogs {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "doc.plaintext")
                            .font(.system(size: 15))
                            .foregroundColor(MvpTheme.textPrimary)
                    }
                }
            }
            .disabled(exportingLogs)
        }
    }

    // MARK: - 2. Protection Shield Hero Area
    private func buildShieldHero() -> some View {
        VStack(spacing: 12) {
            ZStack {
                // Outer Ambient Halo Glow
                if isStart {
                    Circle()
                        .fill(MvpTheme.activeColor.opacity(0.25))
                        .frame(width: 140, height: 165)
                        .blur(radius: 16)
                }

                // Canvas 3D Shield Button
                AdGuardShieldShape()
                    .fill(
                        LinearGradient(
                            colors: isStart ? [MvpTheme.activeColorLight, MvpTheme.activeColor, MvpTheme.activeColorDark] : [MvpTheme.offBgColor, MvpTheme.offBorderColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 135, height: 160)
                    .overlay(
                        AdGuardShieldShape()
                            .stroke(isStart ? MvpTheme.activeColorLight : MvpTheme.offBorderColor, lineWidth: 1.5)
                    )
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: isStart ? "checkmark.shield.fill" : "shield")
                                .font(.system(size: 42, weight: .semibold))
                                .foregroundColor(isStart ? .white : MvpTheme.textSecondary)
                                .shadow(color: Color.black.opacity(isStart ? 0.2 : 0.05), radius: 4, x: 0, y: 2)

                            Image(systemName: "power")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(isStart ? .white.opacity(0.9) : MvpTheme.textMuted)
                        }
                    )
                    .scaleEffect(isShieldPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isShieldPressed)
                    .animation(.easeInOut(duration: 0.3), value: isStart)
                    .onTapGesture {
                        mvpManager.toggleShield(appModel: appModel, activeProfile: activeProfile)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isShieldPressed = true }
                            .onEnded { _ in isShieldPressed = false }
                    )
            }

            // Status Title
            Text(isStart ? "广告防护已开启" : "广告防护已暂停")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(MvpTheme.textPrimary)
                .animation(.easeInOut(duration: 0.2), value: isStart)

            // Status Subtitle
            Text(isStart ? "防护运行中 · 智能拦截与隐私保护" : "点击上方盾牌一键开启防护")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(MvpTheme.textSecondary)
                .animation(.easeInOut(duration: 0.2), value: isStart)
        }
    }

    // MARK: - 3. Quick Info Cards (防护状态 & 内核状态)
    private func buildQuickInfoCards() -> some View {
        HStack(spacing: 12) {
            // Card 1: 防护状态
            buildInfoItem(
                iconName: "shield.fill",
                title: "防护状态",
                value: isStart ? "已开启" : "未开启",
                isActive: isStart
            )

            // Card 2: 内核状态
            buildInfoItem(
                iconName: "cpu",
                title: "内核状态",
                value: coreStatusText,
                isActive: isStart
            )
        }
    }

    private func buildInfoItem(iconName: String, title: String, value: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? MvpTheme.activeColor.opacity(0.12) : MvpTheme.borderColor.opacity(0.5))
                    .frame(width: 32, height: 32)

                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isActive ? MvpTheme.activeColor : MvpTheme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(MvpTheme.textSecondary)

                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(MvpTheme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(MvpTheme.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MvpTheme.borderColor, lineWidth: 1)
        )
    }

    // MARK: - 4. Profile / Subscription Config Card
    private func buildProfileConfigCard() -> some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MvpTheme.activeColor)

                    Text("规则配置集")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MvpTheme.textPrimary)
                }

                Spacer()

                // Update Button
                Button(action: {
                    if let profile = activeProfile {
                        Task {
                            await mvpManager.updateSubscription(appModel: appModel, activeProfile: profile)
                        }
                    } else {
                        mvpManager.showToast("请先导入配置文件", type: .info)
                    }
                }) {
                    HStack(spacing: 4) {
                        if mvpManager.isUpdating {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Text("更新规则")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(MvpTheme.activeColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(MvpTheme.activeColor.opacity(0.08))
                    .cornerRadius(8)
                }
            }

            Divider()
                .background(MvpTheme.borderColor)

            // Active Profile Info Row
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(hasProfile ? (activeProfile?.name.isEmpty == false ? activeProfile!.name : "BlockAd MVP 配置包") : "暂无生效配置")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(MvpTheme.textPrimary)

                    if hasProfile, let url = activeProfile?.url, !url.isEmpty {
                        Text(url)
                            .font(.system(size: 11))
                            .foregroundColor(MvpTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Expand / Collapse Import Section Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        mvpManager.showInputArea.toggle()
                    }
                }) {
                    Image(systemName: mvpManager.showInputArea ? "chevron.up.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(MvpTheme.activeColor)
                }
            }

            // Collapsible Import Area
            if mvpManager.showInputArea {
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        TextField("粘贴或输入规则配置链接", text: $urlInput)
                            .font(.system(size: 13))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(MvpTheme.bgPrimary)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(MvpTheme.borderColor, lineWidth: 1)
                            )

                        Button(action: {
                            if let pasted = UIPasteboard.general.string {
                                urlInput = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        }) {
                            Text("粘贴")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(MvpTheme.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(MvpTheme.borderColor.opacity(0.6))
                                .cornerRadius(10)
                        }
                    }

                    Button(action: {
                        Task {
                            await mvpManager.importConfig(url: urlInput, appModel: appModel)
                            if !mvpManager.showInputArea {
                                urlInput = ""
                            }
                        }
                    }) {
                        HStack {
                            if mvpManager.isImporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.system(size: 13))
                                Text("导入配置链接")
                                    .font(.system(size: 13, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(MvpTheme.activeColor)
                        .cornerRadius(10)
                    }
                    .disabled(mvpManager.isImporting)
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(MvpTheme.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MvpTheme.borderColor, lineWidth: 1)
        )
    }

    // MARK: - 5-Tap Minimal Mode Toggle Helper
    private func handleMinimalTap() {
        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) > 2.0 {
            minimalTapCount = 0
        }
        lastTapTime = now
        minimalTapCount += 1

        if minimalTapCount >= 5 {
            minimalTapCount = 0
            withAnimation {
                mvpManager.isMvpMode = false
            }
            mvpManager.showToast("已切换至高级模式", type: .info)
        }
    }

    private func toastIconName(for type: MvpToastType) -> String {
        switch type {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    // MARK: - Log Export
    private var logTimestamp: String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        return df.string(from: Date())
    }

    private func exportLogs() async {
        exportingLogs = true
        defer { exportingLogs = false }
        let text = await Task.detached { MvpLogExporter.collectCombinedLogs() }.value
        logExportDocument = MvpLogExportDocument(text: text)
        showingLogExporter = true
    }
}
