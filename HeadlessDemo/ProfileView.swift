import SwiftUI
import SdkMobileIOSNative

struct ProfileView: View {
    @State var nativeSDK: NativeSDK

    @State var accessToken: String?

    var body: some View {
        VStack {
            Text("Welcome \(nativeSDK.session.profile?.claims["email"] ?? "N\\A")")
                .font(.title)

            ScrollView {
                Text("accessToken")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let accessToken = accessToken {
                    Text(accessToken)
                }

                Text("claims")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)

                if let jsonData = try? JSONSerialization.data(withJSONObject: nativeSDK.session.profile?.claims ?? [:], options: [.prettyPrinted]),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    Text(jsonString)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                accessToken = try? await nativeSDK.getAccessToken()
            }
        }

        Button("Revoke") {
            Task {
                try await nativeSDK.revoke()
            }
        }
        
        Button("Logout") {
            Task {
                do {
                    try await nativeSDK.logout()
                } catch is CancellationError {
                    fatalError("Logout cancelled before completion")
                } catch {
                    print("\(error)")
                }
            }
        }
        .tint(.primaryAction)
    }
}
