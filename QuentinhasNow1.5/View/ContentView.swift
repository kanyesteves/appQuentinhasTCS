//
//  ContentView.swift
//  QuentinhasNow
//
//  Created by Kanydian Esteves on 12/04/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var login = ""
    @State private var passwd = ""
    @State private var wrongLogin = 0
    @State private var wrongPassword = 0
    @State private var showLoginScreen = false
    
    var body: some View {
        NavigationView {
        
            ZStack {
                
                Circle()
                    .scale(1.7)
                    .foregroundColor(.orange.opacity(0.90))
                    .frame(width: 900, height: 400)
                    .padding(.bottom, 900)
                Circle()
                    .scale(1.8)
                    .foregroundColor(.orange.opacity(0.70))
                    .frame(width: 900, height: 400)
                    .padding(.bottom, 900)
                Circle()
                    .scale(1.9)
                    .foregroundColor(.orange.opacity(0.50))
                    .frame(width: 900, height: 400)
                    .padding(.bottom, 900)
                
                Text("Quentinhas Now")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 500)
                    .foregroundColor(.white)
                
                VStack {
                    
                    TextField("Login", text: $login)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.19))
                        .cornerRadius(5)
                        .padding(.top, 250)
                        .padding(.bottom, 10)
                    
                    SecureField("Senha", text: $passwd)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.19))
                        .cornerRadius(5)
                    
                    Button("Entrar") {
                        authenticateUser(username: login, password: passwd)
                    }
                    .foregroundColor(.white)
                    .frame(width: 100, height: 50)
                    .background(.orange.opacity(0.90))
                    .cornerRadius(10)
                    .padding(.top, 10)

                    NavigationLink(destination: HomeView(), isActive: $showLoginScreen) {}
                }
            }
            .ignoresSafeArea()
        }
    }
    
    func authenticateUser(username: String, password: String) {
        if username.lowercased() == "adm" {
            wrongLogin = 0
            
            if password.lowercased() == "132" {
                wrongPassword = 0
                showLoginScreen = true
            } else {
                wrongPassword = 2
            }
        } else {
            wrongLogin = 2
        }
    }
}

#Preview {
    ContentView()
}
