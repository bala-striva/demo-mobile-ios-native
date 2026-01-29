import SwiftUI
import SdkMobileIOSNative

struct ContentView: View {

    var nativeSDK: NativeSDK

    @State var loading: Bool = true
    @ObservedObject var session: Session
    @State var error: String?
    @State var accessToken: String?
    
    @State var entryUrl: URL?

    init() {
        nativeSDK = NativeSDK(
            issuer: URL(string: "https://example.org")!,
            clientId: "",
            redirectURI: URL(string: "strivacity.DemoMobileIOS://native-flow")!,
            postLogoutURI: URL(string: "strivacity.DemoMobileIOS://native-flow")!,
            mode: .iosMinimal
        )

        session = nativeSDK.session
    }

    var body: some View {
        VStack {
            if loading {
                Text("loading...")
            } else {
                if session.profile != nil {
                    ProfileView(nativeSDK: nativeSDK)
                } else if session.loginInProgress {
                    VStack {
                        Spacer()
                        LoginScreen(nativeSDK: nativeSDK)
                        Spacer()

                        Button("Cancel") {
                            Task {
                                nativeSDK.cancelFlow(error: .oidcError(error: "cancel", errorDescription: "Canceled by the user"))
                            }
                        }
                    }
                } else {
                    Button("Login") {
                        Task {
                            self.error = nil

                            do {
                                let _ = try await nativeSDK.login(
                                    parameters: LoginParameters(
                                        acrValue: "hu",
                                        scopes: ["openid", "profile", "email", "offline"],
                                        prefersEphemeralWebBrowserSession: true
                                    )
                                )
                            } catch {
                                print("error \(error, default: "nil")")
                                switch error {
                                case let NativeSDKError.oidcError(error: _, errorDescription: errorDescription):
                                    self.error = errorDescription
                                case NativeSDKError.hostedFlowCanceled:
                                    self.error = "Hosted login canceled"
                                case NativeSDKError.sessionExpired:
                                    self.error = "Session expired"
                                default:
                                    self.error = "N/A"
                                }
                            }
                        }
                    }
                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                    }

                }
            }
        }
        .onAppear {
            Task {
                try await nativeSDK.initializeSession()
                loading = false
            }
        }
        .task(id: entryUrl) {
            guard let entryUrl = entryUrl else { return }
            do {
                try await nativeSDK.entry(entryUrl: entryUrl)
            } catch {
                self.error = error.localizedDescription
            }
        }
        .onOpenURL { url in
            entryUrl = url
        }
    }
}
