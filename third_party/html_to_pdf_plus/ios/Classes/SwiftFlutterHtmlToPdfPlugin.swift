import Flutter
import UIKit
import WebKit

public class SwiftFlutterHtmlToPdfPlugin: NSObject, FlutterPlugin {
    private weak var registrar: FlutterPluginRegistrar?
    private var wkWebView: WKWebView?
    private var urlObservation: NSKeyValueObservation?
    private var isConverting = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_html_to_pdf",
            binaryMessenger: registrar.messenger()
        )
        let instance = SwiftFlutterHtmlToPdfPlugin()
        instance.registrar = registrar
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "convertHtmlToPdf":
            convertHtmlToPdf(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func convertHtmlToPdf(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard !isConverting else {
            result(FlutterError(
                code: "BUSY",
                message: "A PDF conversion is already in progress.",
                details: nil
            ))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let htmlFilePath = args["htmlFilePath"] as? String,
              let width = doubleValue(args["width"]),
              let height = doubleValue(args["height"]) else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "htmlFilePath, width, and height are required.",
                details: nil
            ))
            return
        }

        let linksClickable = boolValue(args["linksClickable"])
        let fitToSinglePage = boolValue(args["fitToSinglePage"])
        let htmlFileContent: String
        do {
            htmlFileContent = try FileHelper.getContent(from: htmlFilePath)
        } catch {
            result(FlutterError(
                code: "HTML_READ_ERROR",
                message: error.localizedDescription,
                details: nil
            ))
            return
        }

        isConverting = true
        let viewController = rootViewController()
        // Off-screen. createPDF still paints here; a snapshot of this view is white.
        let webView = WKWebView(frame: CGRect(x: -width - 80, y: 0, width: width, height: height))
        webView.isHidden = false
        webView.alpha = 1
        webView.isUserInteractionEnabled = false
        webView.tag = 100
        viewController?.view.addSubview(webView)
        wkWebView = webView

        let contentController = webView.configuration.userContentController
        contentController.addUserScript(WKUserScript(
            source: "document.documentElement.style.webkitUserSelect='none';",
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))
        contentController.addUserScript(WKUserScript(
            source: "document.documentElement.style.webkitTouchCallout='none';",
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))
        webView.scrollView.bounces = false
        webView.loadHTMLString(htmlFileContent, baseURL: Bundle.main.bundleURL)

        let formatter: UIPrintFormatter
        if linksClickable {
            formatter = UIMarkupTextPrintFormatter(markupText: htmlFileContent)
        } else {
            formatter = webView.viewPrintFormatter()
        }

        let reply = ReplyGate(result: result)
        let finish: () -> Void = { [weak self] in
            guard reply.claim() else { return }
            guard let self = self else {
                reply.sendFailure(code: "PDF_WRITE_ERROR", message: "PDF conversion was cancelled.")
                return
            }

            if fitToSinglePage {
                self.exportWebViewAsSinglePage(webView) { exportResult in
                    self.cleanupWebView(in: viewController)
                    switch exportResult {
                    case .success(let url):
                        reply.sendSuccess(url.path)
                    case .failure(let error):
                        reply.sendFailure(
                            code: "PDF_WRITE_ERROR",
                            message: error.localizedDescription
                        )
                    }
                }
                return
            }

            do {
                let converted = try PDFCreator.create(
                    printFormatter: formatter,
                    width: width,
                    height: height
                )
                self.cleanupWebView(in: viewController)
                reply.sendSuccess(converted.path)
            } catch {
                self.cleanupWebView(in: viewController)
                reply.sendFailure(code: "PDF_WRITE_ERROR", message: error.localizedDescription)
            }
        }

        urlObservation = webView.observe(\.isLoading, options: [.new]) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                finish()
            }
        }

        // Same PDF output if loading never notifies. Prevents a hung channel.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            finish()
        }
    }

    /// createPDF paints the invoice (a snapshot of this off-screen view is white).
    /// That PDF is paginated, so the pages are stacked onto one sheet.
    private func exportWebViewAsSinglePage(
        _ webView: WKWebView,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        guard #available(iOS 14.0, *) else {
            completion(.failure(PDFCreatorError.writeFailed("This iOS version cannot render the receipt.")))
            return
        }

        webView.createPDF(configuration: WKPDFConfiguration()) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let single = PDFCreator.singlePageData(from: data)
                    do {
                        let url = try PDFCreator.writePDFData(single)
                        completion(.success(url))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    /// Scene-owned window. AppDelegate.window is nil after UIScene adoption.
    private func rootViewController() -> UIViewController? {
        if let controller = registrar?.viewController {
            return controller
        }

        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        if let controller = scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
            ?? scene?.windows.first?.rootViewController {
            return controller
        }

        return UIApplication.shared.delegate?.window??.rootViewController
    }

    private func cleanupWebView(in viewController: UIViewController?) {
        isConverting = false
        viewController?.view.viewWithTag(100)?.removeFromSuperview()
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
        urlObservation = nil
        wkWebView = nil
    }

    private func doubleValue(_ value: Any?) -> Double? {
        (value as? NSNumber)?.doubleValue
    }

    private func boolValue(_ value: Any?) -> Bool {
        if let bool = value as? Bool {
            return bool
        }
        return (value as? NSNumber)?.boolValue ?? false
    }
}

/// Ensures the method-channel result is completed once.
private final class ReplyGate {
    private let result: FlutterResult
    private var replied = false

    init(result: @escaping FlutterResult) {
        self.result = result
    }

    func claim() -> Bool {
        if replied { return false }
        replied = true
        return true
    }

    func sendSuccess(_ value: Any?) {
        result(value)
    }

    func sendFailure(code: String, message: String) {
        result(FlutterError(code: code, message: message, details: nil))
    }
}
