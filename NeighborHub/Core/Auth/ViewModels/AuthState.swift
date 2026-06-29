import Foundation
import FirebaseAuth
import Combine

enum AuthState {
    case splash
    case loggedOut
    case loggedIn
}

class AuthViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var authState: AuthState = .splash
    @Published var currentUser: UserModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    // MARK: - Private
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Init
    init() {
        listenToAuthState()
    }
    
    // MARK: - Auth State Listener
    private func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if let user = user {
                    // Check session validity
                    user.getIDTokenForcingRefresh(false) { token, error in
                        if let error = error {
                            print("Session expired: \(error)")
                            DispatchQueue.main.async {
                                self.authState = .loggedOut
                                self.currentUser = nil
                            }
                            return
                        }
                        // Valid session — fetch user data
                        self.fetchCurrentUser(uid: user.uid)
                    }
                } else {
                    self.authState = .loggedOut
                    self.currentUser = nil
                }
            }
        }
    }
    
    // MARK: - Fetch Current User
    private func fetchCurrentUser(uid: String) {
        AuthService.shared.fetchUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.authState = .loggedIn
                case .failure:
                    self.authState = .loggedOut
                }
            }
        }
    }
    
    // MARK: - Register
    func register(name: String, email: String, password: String, area: String) {
        guard validateRegister(name: name, email: email, password: password) else { return }
        isLoading = true
        AuthService.shared.register(
            name: name,
            email: email,
            password: password,
            area: area
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.authState = .loggedIn
                case .failure(let error):
                    self.showErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) {
        guard validateLogin(email: email, password: password) else { return }
        isLoading = true
        AuthService.shared.login(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.authState = .loggedIn
                case .failure(let error):
                    self.showErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        AuthService.shared.signOut { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.currentUser = nil
                    self.authState = .loggedOut
                case .failure(let error):
                    self.showErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    func refreshCurrentUser(uid: String) {
        AuthService.shared.fetchUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .success(let user) = result {
                    self.currentUser = user
                }
            }
        }
    }
    
    // MARK: - Validation
    private func validateLogin(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            showErrorMessage("Email and password are required")
            return false
        }
        guard email.isValidEmail else {
            showErrorMessage("Please enter a valid email")
            return false
        }
        guard password.isValidPassword else {
            showErrorMessage("Password must be at least 6 characters")
            return false
        }
        return true
    }
    
    private func validateRegister(name: String, email: String, password: String) -> Bool {
        guard !name.isEmpty else {
            showErrorMessage("Name is required")
            return false
        }
        return validateLogin(email: email, password: password)
    }
    
    // MARK: - Error Helper
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Deinit
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    
}
