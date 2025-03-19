//
//  StartView.swift
//  MultipeerConectivityDemo
//
//  Created by Luiz Seibel on 17/03/25.
//

import SwiftUI
import MultipeerConnectivity

struct LobbyView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: LobbyViewModel
    @State private var navigateToChat = false
    private var isHost: Bool

    init(connectionManager: MPCManager, isHost: Bool) {
        _viewModel = StateObject(wrappedValue: LobbyViewModel(connectionManager: connectionManager))
        self.isHost = isHost
    }

    var body: some View {
        NavigationView {
            VStack {
                if isHost {
                    hostView()
                } else {
                    guestView()
                }

            }
            .navigationTitle("Lobby")
            .toolbarTitleDisplayMode(.inlineLarge)
            
            .onAppear {
                if isHost {
                    viewModel.startAdvertising()
                } else {
                    viewModel.startBrowsing()
                }
            }
            .onDisappear {
                viewModel.stopBrowsing()
                
                if isHost{
                    viewModel.stopAdvertising()
                }
            }
            
            .onChange(of: presentationMode.wrappedValue.isPresented) { oldValue, isPresented in
                if !isPresented && !navigateToChat {
                    viewModel.disconnect()
                }
            }
            
            .navigationDestination(isPresented: $navigateToChat) {
                ChatView(connectionManager: viewModel.connectionManager)
            }
            
            .alert(isPresented: $viewModel.receivedInvite) {
                Alert(
                    title: Text("Connection request"),
                    message: Text("\(viewModel.receivedInviteFrom?.displayName ?? "Anonymous") wants to connect."),
                    primaryButton: .default(Text("Accept"), action: {
                        viewModel.acceptInvitation()
                    }),
                    secondaryButton: .cancel(Text("Reject"), action: {
                        viewModel.rejectInvitation()
                    })
                )
            }
            .onChange(of: viewModel.canGoToChat) { _, newValue in
                if newValue {
                    navigateToChat = true
                }
            }
        }
    }
    
    
}

// MARK: Containers
extension LobbyView {
    func hostView() -> some View {
        VStack{
            Text("Connected Peers:")
                .font(.headline)
                .padding(.top)
            
            List(viewModel.connectedPeers, id: \.self) { peer in
                Text(peer.displayName)
            }
            
            if viewModel.isConnected {
                Button("Start Chat") {
                    viewModel.sendMessage()
                    navigateToChat = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }

    func guestView() -> some View {
        VStack{
            if !viewModel.isConnected {
                List(viewModel.availablePeers, id: \.self) { peer in
                    HStack{
                        Text(peer.displayName)
                        Spacer()
                        Button(action: {
                            viewModel.invitePeer(peer)
                        }, label: {
                            Text("Send Invite")
                                .foregroundStyle(.blue)
                        })
                    }
                    .padding(.horizontal)
                }
            }
            else{
                Text("Waiting for the host to start the chat…")
                    .italic()
                    .padding()
                
                if viewModel.canGoToChat {
                    GoToChat()
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: Container Components
extension LobbyView{
    func GoToChat() -> some View {
        Button(action: {
            navigateToChat = true
        }) {
            HStack {
                Image(systemName: "message.fill")
                    .font(.headline)
                Text("Back to chat")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}
