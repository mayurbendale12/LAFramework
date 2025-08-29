import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var secretMessageLabel: UILabel!

    @IBAction private func authenticate(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?

        //You can use .deviceOwnerAuthentication to allow fallback to the device passcode
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                print("Face ID is available.")
            case .touchID:
                print("Touch ID is available.")
            case .none:
                print("No biometric authentication is available.")
            default:
                print("Unknown biometric type.")
            }

            let reason = "Authenticate to access secure data"
            context.localizedFallbackTitle = "Enter Passcode"
            context.localizedCancelTitle = "Cancel Authentication"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticateError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let message: String
                        switch authenticateError {
                        case LAError.authenticationFailed?:
                          message = "There was a problem verifying your identity."
                        case LAError.userCancel?:
                          message = "You pressed cancel."
                        case LAError.userFallback?:
                          message = "You pressed password."
                        case LAError.biometryNotAvailable?:
                          message = "Face ID/Touch ID is not available."
                        case LAError.biometryNotEnrolled?:
                          message = "Face ID/Touch ID is not set up."
                        case LAError.biometryLockout?:
                          message = "Face ID/Touch ID is locked."
                        default:
                          message = "Face ID/Touch ID may not be configured"
                        }

                        self?.showAlert(title: "Authentication failed",
                                        message: message)
                    }
                }
            }
        } else {
            showAlert(title: "Biometry unavailable",
                      message: "Your device is not configured for biometric authentication.")
        }
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

    private func unlockSecretMessage() {
        secretMessageLabel.text = "Hello"
    }
}
