import SwiftUI
import WebKit

// 1. Le "moteur" de la WebView (équivalent à ta classe MainActivity)
struct WebViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true // Activation JavaScript
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        // Stockage local (DOM Storage) est activé par défaut sur iOS
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator // Gestion des événements
        
        // Chargement initial du Splash Screen (index.html dans les assets)
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // 2. Le coordinateur (équivalent à ton WebViewClient)
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer

        init(_ parent: WebViewContainer) {
            self.parent = parent
        }

        // Gestion des erreurs de navigation (équivalent à onReceivedError)
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            if let offlineURL = Bundle.main.url(forResource: "offline", withExtension: "html") {
                webView.loadFileURL(offlineURL, allowingReadAccessTo: offlineURL.deletingLastPathComponent())
            }
        }

        // Gestion SSL (équivalent à onReceivedSslError / handler.proceed())
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                // On accepte le certificat même s'il y a une erreur (comme ton handler.proceed)
                completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }
    }
}

// 3. L'interface utilisateur
struct ContentView: View {
    var body: some View {
        WebViewContainer()
            .edgesIgnoringSafeArea(.all) // Plein écran pour ton iPhone X
    }
}
