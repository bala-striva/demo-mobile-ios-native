import SdkMobileIOSNative
import SwiftUI

struct ContentView: View {
    var nativeSDK: NativeSDK

    @State var loading: Bool = true
    @State var error: String?
    @ObservedObject var session: Session
    @ObservedObject var scrollManager = ScrollManager()
    @ObservedObject var focusManager = FocusManager()
    
    @State private var entryUrl: URL?

    init() {
        nativeSDK = NativeSDK(
            issuer: URL(string: "https://example.org")!,
            clientId: "",
            redirectURI: URL(string: "strivacity.DemoMobileIOS://native-flow")!,
            postLogoutURI: URL(string: "strivacity.DemoMobileIOS://native-flow")!
        )

        session = nativeSDK.session
    }

    var body: some View {
        VStack {
            if loading {
                Text("loading...")
            } else {
                Text("Strivacity")
                    .padding(.top, 24)

                Login(nativeSDK: nativeSDK, error: error)
                    .environmentObject(session)
                    .environmentObject(scrollManager)
                    .environmentObject(focusManager)

                Text("Footer")
            }
        }
        .onAppear {
            Task {
                try await nativeSDK.initializeSession()
                loading = false
            }
        }
        .task(id: entryUrl) {
            // when URL changes by onOpenURL, start entry flow, unless it's nil
            guard let entryUrl = entryUrl else {
                return
            }
            
            defer {
                // reset entryUrl once entry flow has completed
                // needed if the user wants to reenter the same flow after manual cancellation
                self.entryUrl = nil
            }
            
            do {
                print("Invoking entry")
                try await nativeSDK.entry(entryUrl: entryUrl)
                print("entry completed")
            } catch is CancellationError {
                // cancellation is error normal if entry tasks are lifecycle bound by .task()
                // entry can also be manually cancelled by invoking `NativeSDK.cancelFlow()`
                print("Entry was replaced or view went out of scope - this is normal")
            } catch {
                self.error = error.localizedDescription
            }
        }
        .onOpenURL { url in
            if entryUrl == url {
                print("Opened the same entry URL")
            }
            // update state when app receives an URL - if the same URL is opened
            // multiple time, .task(id:) will return early. Workflow won't get restarted
            entryUrl = url
        }
    }
}

#Preview {
    ContentView()
}
