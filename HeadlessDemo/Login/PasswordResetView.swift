import SwiftUI
import SdkMobileIOSNative

struct PasswordResetView: View {
    @EnvironmentObject var loginScreenModel: LoginScreenModel

    var body: some View {
        VStack {
            Text("Password reset is not supported by this demo app")

            Button("Close") {
                Task {
                    await try loginScreenModel.headlessAdapter.closeEntryFlow()
                }
            }

        }
    }
}
