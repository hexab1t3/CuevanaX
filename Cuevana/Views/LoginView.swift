//
//  LoginView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var viewModel = LoginViewModel()
    @State private var isPasswordVisible = false
    @State private var failedAttempts = 0
    @FocusState private var focusedField: Field?

    private enum Field {
        case mail
        case password
    }

    var body: some View {
        ZStack {
            AmbientBackground(animated: true)

            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 14) {
                        AppLogoView(size: 88)

                        HStack(spacing: 0) {
                            Text("Cuevana")
                                .foregroundStyle(.white)
                            Text("X")
                                .foregroundStyle(Theme.brandGradient)
                        }
                        .font(.system(size: 42, weight: .black, design: .rounded))

                        Text("Tu cine favorito, siempre contigo")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 72)

                    GlassEffectContainer(spacing: 14) {
                        VStack(spacing: 14) {
                            inputField(icon: "envelope.fill") {
                                TextField("Correo electrónico", text: $viewModel.mail)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .mail)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                            }

                            inputField(icon: "lock.fill") {
                                Group {
                                    if isPasswordVisible {
                                        TextField("Contraseña", text: $viewModel.password)
                                    } else {
                                        SecureField("Contraseña", text: $viewModel.password)
                                    }
                                }
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .password)
                                .submitLabel(.go)
                                .onSubmit(login)

                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .contentTransition(.symbolEffect(.replace))
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityLabel(isPasswordVisible ? "Ocultar contraseña" : "Mostrar contraseña")
                            }
                        }
                    }
                    .keyframeAnimator(initialValue: CGFloat.zero, trigger: failedAttempts) { content, offset in
                        content.offset(x: offset)
                    } keyframes: { _ in
                        KeyframeTrack {
                            LinearKeyframe(-12, duration: 0.07)
                            LinearKeyframe(12, duration: 0.07)
                            LinearKeyframe(-8, duration: 0.07)
                            LinearKeyframe(8, duration: 0.07)
                            SpringKeyframe(0, duration: 0.2)
                        }
                    }

                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(Theme.coral)
                            .multilineTextAlignment(.center)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Button(action: login) {
                        Text("Iniciar Sesión")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.amber)
                    .sensoryFeedback(.error, trigger: failedAttempts)
                }
                .padding(.horizontal, 24)
                .animation(.smooth, value: viewModel.errorMessage)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    private func inputField<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.amber)
                .frame(width: 22)

            content()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
    }

    private func login() {
        withAnimation(.smooth) {
            viewModel.login(isAuthenticated: &isAuthenticated)
        }
        if !isAuthenticated {
            failedAttempts += 1
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
}
