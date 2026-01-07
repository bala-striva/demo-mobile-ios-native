import SwiftUI
import SdkMobileIOSNative

struct MfaEnrollStartView: View {
    @EnvironmentObject var loginScreenModel: LoginScreenModel

    @State var email: Bool = false
    @State var phone: Bool = false

    var identifier: String {
       loginScreenModel
            .screen?
            .forms?
            .first(where: { $0.id == "reset" })?
            .widgets
            .first(where: { $0.id == "identifier" })?
            .title ?? ""
    }

    var body: some View {
        VStack {
            Text("Enroll the following authentication methods")
                .multilineTextAlignment(.center)
                .font(.title.bold())

            HStack {
                Text(identifier)
                Button("Not you?") {
                    Task {
                        await loginScreenModel.headlessAdapter.submit(formId: "reset", data: [:])
                    }
                }
            }

            Text("Choose at least one method")

            Toggle("Email address", isOn: $email)
            Toggle("Phone number", isOn: $phone)

            Button("Continue") {
                Task {
                    var selected: [String] = []

                    if email {
                        selected.append("email")
                    }
                    if phone {
                        selected.append("phone")
                    }

                    await loginScreenModel.headlessAdapter.submit(formId: "mfaEnrollStart", data: ["optional": selected])
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.primaryAction)


            Button("Back to login") {
                Task {
                    await loginScreenModel.headlessAdapter.submit(formId: "reset", data: [:])
                }
            }

        }
    }
}
