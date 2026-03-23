import SwiftUI
import Combine
import SdkMobileIOSNative

struct LoginScreen: View {
    @ObservedObject var loginScreenModel: LoginScreenModel

    @State var showAlert: Bool = false

    var alertText: String {
        return switch loginScreenModel.screen?.messages {
        case let .global(message):
            message.text
        default:
            ""
        }
    }

    init(nativeSDK: NativeSDK) {
        loginScreenModel = LoginScreenModel(nativeSDK: nativeSDK)
        loginScreenModel.headlessAdapter.initialize()
    }

    var body: some View {
        ZStack {
            if loginScreenModel.screen == nil {
                Text("Loading")
            } else {
                switch loginScreenModel.screen?.screen {
                case "identification":
                    IdentificationView()
                case "password":
                    PasswordView()
                case "registration":
                    RegistrationView()
                case "mfaMethod":
                    MfaMethodView()
                case "mfaPasscode":
                    MfaPasscodedView()
                case "mfaEnrollStart":
                    MfaEnrollStartView()
                case "mfaEnrollTargetSelect":
                    MfaEnrollTargetSelectView()
                case "mfaEnrollChallenge":
                    MfaEnrollChallengeView()
                case "genericResult":
                    GenericResultView()
                case "passwordReset":
                    PasswordResetView()
                default:
                    Text("Unkown screen: \(loginScreenModel.screen?.screen ?? "N/A")")
                    .onAppear {
                        print(loginScreenModel.screen)
                    }
                    // Uncomment the following for unkown screen handling with SDK based renderer (not supported using minimal mode)
//                    HeadlessAdapterLoginView(headlessAdapter: loginScreenModel.headlessAdapter)
                }
            }
        }
        .padding()
        .onReceive(loginScreenModel.$screen) { screen in
            showAlert = switch screen?.messages {
            case .global:
                true
            default:
                false
            }
        }
        .environmentObject(loginScreenModel)
        .alert(
            alertText,
            isPresented: $showAlert
        ) {
            Button("OK", role: .cancel) {
                showAlert = false
            }
        }
    }
}

class LoginScreenModel: ObservableObject, HeadlessAdapterDelegate {
    var headlessAdapter: HeadlessAdapter!

    @Published var screen: Screen?

    init(nativeSDK: NativeSDK) {
        self.headlessAdapter = HeadlessAdapter(nativeSDK: nativeSDK, delegate: self)
    }

    public func renderScreen(screen: Screen) {
        if Thread.isMainThread {
            self.screen = screen
        } else {
            DispatchQueue.main.async {
                self.screen = screen
            }
        }
    }

    public func refreshScreen(screen: Screen) {
        if Thread.isMainThread {
            self.screen = screen
        } else {
            DispatchQueue.main.async {
                self.screen = screen
            }
        }
    }
}

extension SdkMobileIOSNative.Widget {
    var title: String? {
        switch self {
        case .staticWidget(let widget):
            return widget.value
        default:
            return nil
        }
    }
}
