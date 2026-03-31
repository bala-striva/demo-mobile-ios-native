import SdkMobileIOSNative
import SwiftUI

struct WidgetHandler: View {
    let screen: String
    let forms: [FormWidget]
    let layout: SdkMobileIOSNative.Layout

    public var body: some View {
        LoginLayoutView(screen: screen, forms: forms, layout: layout) { screen, formId, widgetId, widget in

            VStack(alignment: .leading, spacing: 0) {
                let fieldId = formId + "-" + widgetId

                if case let .staticWidget(staticWidget) = widget {
                    StaticView(widgetId: widgetId, widget: staticWidget)
                } else if case let .submit(submitWidget) = widget {
                    SubmitView(formId: formId, widget: submitWidget)
                } else if case let .input(inputWidget) = widget {
                    InputView(formId: formId, widgetId: widgetId, widget: inputWidget, fieldId: fieldId)
                } else if case let .password(passwordWidget) = widget {
                    PasswordWiew(formId: formId, widgetId: widgetId, widget: passwordWidget, fieldId: fieldId)
                } else if case let .checkbox(checkboxWidget) = widget {
                    CheckboxView(formId: formId, widgetId: widgetId, widget: checkboxWidget, fieldId: fieldId)
                } else if case let .passcode(passcodeWidget) = widget {
                    PasscodeView(formId: formId, widgetId: widgetId, widget: passcodeWidget, fieldId: fieldId)
                } else if case let .phone(phoneWidget) = widget {
                    PhoneView(formId: formId, widgetId: widgetId, widget: phoneWidget, fieldId: fieldId)
                } else if case let .select(selectWidget) = widget {
                    SelectView(formId: formId, widgetId: widgetId, widget: selectWidget, fieldId: fieldId)
                } else if case let .multiselect(multiSelectWidget) = widget {
                    MultiSelectView(formId: formId, widgetId: widgetId, widget: multiSelectWidget, fieldId: fieldId)
                } else if case let .date(dateWidget) = widget {
                    DateView(formId: formId, widgetId: widgetId, widget: dateWidget, fieldId: fieldId)
                } else if case let .passkeyLogin(widget) = widget {
                    PasskeyLoginView(formId: formId, widgetId: widgetId, widget: widget)
                } else if case let .passkeyEnroll(widget) = widget {
                    PasskeyEnrollView(formId: formId, widgetId: widgetId, widget: widget)
                } else if case let .webauthnLogin(widget) = widget {
                    WebauthnLoginView(formId: formId, widgetId: widgetId, widget: widget)
                } else if case let .webauthnEnroll(widget) = widget {
                    WebauthnEnrollView(formId: formId, widgetId: widgetId, widget: widget)
                } else {
                    LoginWidgetView(screen: screen, formId: formId, widgetId: widgetId, widget: widget)
                }
            }
        }
    }
}
