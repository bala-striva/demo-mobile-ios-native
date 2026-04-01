import SdkMobileIOSNative
import SwiftUI

struct WebauthnEnrollView: View {
    @EnvironmentObject var loginController: LoginController
    @EnvironmentObject var scrollManager: ScrollManager
    @EnvironmentObject var focusManager: FocusManager

    @State var handler = WebauthnHandler()
    @State var errorMessage: String?
    @State var running = false

    let formId: String
    let widgetId: String

    let widget: WebauthnEnrollWidget

    var body: some View {
        VStack {
            let button = Button {
                running = true
                scrollManager.errorFieldIds.removeAll()
                handler.enroll(enrollOptions: widget.enrollOptions) { result in
                    loginController.setWidgetData(formId: formId, widgetId: widgetId, value: result)
                    await loginController.submit(formId: formId)
                    running = false
                } onError: { err in
                    errorMessage = err?.localizedDescription
                    running = false
                }
                focusManager.clearFocus()

            } label: { Text(widget.label)
                // this frame modifier is needed so that the whole button can be clickable
                .frame(maxWidth: widget.render?.type == "button" ? .infinity : nil)
                .font(widget.render?.type == "button" ? .body.bold() : .body)
                .padding(.vertical, widget.render?.type == "button" ? Typography.paddingMd : 0)
            }

            switch widget.render?.type {
            case "button":
                button
                    .foregroundColor((widget.render?.hint?.variant == "primary" ? .white : Colors
                            .styPrimary))
                    .background((widget.render?.hint?.variant == "primary" ? Colors
                            .styPrimary : .white))
                    .cornerRadius(Typography.borderRadius)
                    .border(Colors.borderGray, width: 1)
                    .padding(.horizontal, Typography.paddingMd)
                    .padding(.bottom, Typography.errorFrameHeight)

            case "link":
                button
                    .foregroundColor(Colors.styPrimary)
                    .padding(.bottom, Typography.errorFrameHeight)

            default:
                FallbackTriggerView()
            }

            ErrorView(formId: formId, widgetId: widgetId, error: errorMessage ?? "")
        }
        .disabled(running)
    }
}
