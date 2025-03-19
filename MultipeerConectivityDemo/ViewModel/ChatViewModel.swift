//
//  ChatViewModel.swift
//  MultipeerConectivityDemo
//
//  Created by Luiz Seibel on 18/03/25.
//

import Foundation
import MultipeerConnectivity

class ChatViewModel: Connectable, ObservableObject {
    
    @Published var messages: [String] = []
    @Published var inputMessage: String = ""
    
    var connectionManager: MPCManager
    
    init(connectionManager: MPCManager) {
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
    }
}

// MARK: - Message Control
extension ChatViewModel {
    func sendMessage() {
        guard !inputMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let playerName = connectionManager.myPeerID.displayName
        
        let message = SendMessageEncoder(message: inputMessage, playerName: playerName)
        
        connectionManager.send(message: message)
        messages.append("Me: \(inputMessage)")
        inputMessage = ""
    }
    
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        if let message = try? JSONDecoder().decode(SendMessageEncoder.self, from: data){
            DispatchQueue.main.async {
                self.messages.append("\(message.playerName): \(message.message)")
            }
        }
    }
}
