//
//  ContentView.swift
//  MultipeerConectivityDemo
//
//  Created by Luiz Seibel on 13/03/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var yourName: String = ""
    @State var showLobby: Bool = false
    @State var imHost: Bool = false
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Chat App Demo")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Your Name:")
                        .font(.headline)
                    
                    TextField("Enter your name", text: $yourName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom)
                    
                    Toggle(isOn: $imHost) {
                        Text("I will be the Host")
                            .font(.subheadline)
                    }
                    .padding(.bottom)
                }
                .padding()
                
                Button(action: {
                    showLobby.toggle()
                }) {
                    Text(imHost ? "Host Lobby" : "Search Lobby")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showLobby) {
                if showLobby {
                    LobbyView(connectionManager: MPCManager(yourName: yourName), isHost: imHost)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
