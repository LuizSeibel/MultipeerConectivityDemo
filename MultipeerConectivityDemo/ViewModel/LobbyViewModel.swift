import SwiftUI
import MultipeerConnectivity

class LobbyViewModel: Connectable, ObservableObject {
    
    @Published var messages: [String] = []
    @Published var availablePeers: [MCPeerID] = []
    @Published var connectedPeers: [MCPeerID] = []
    @Published var isConnected: Bool = false
    @Published var canGoToChat: Bool = false
    @Published var receivedInvite: Bool = false
    @Published var receivedInviteFrom: MCPeerID?

    var connectionManager: MPCManager

    init(connectionManager: MPCManager) {
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
        self.connectionManager.onDisconnectedPeer = onDisconnected
        setupBindings()
    }
}

// MARK: - Connection Handling
extension LobbyViewModel {
    func disconnect() {
        connectionManager.disconnect()
    }
    
    func acceptInvitation() {
        if let handler = connectionManager.invitationHandler {
            handler(true, connectionManager.session)

            // Restart advertising if still the host
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.startAdvertising()
            }

            self.connectedPeers.append(receivedInviteFrom!)
        }
    }
    
    func rejectInvitation() {
        if let handler = connectionManager.invitationHandler {
            handler(false, nil)
        }
    }
    
    func invitePeer(_ peer: MCPeerID) {
        connectionManager.invite(peer: peer)
    }
}

// MARK: - Advertising & Browsing
extension LobbyViewModel {
    func startAdvertising() {
        connectionManager.startAdvertising()
    }

    func stopAdvertising() {
        connectionManager.stopAdvertising()
    }

    func startBrowsing() {
        connectionManager.startBrowsing()
    }

    func stopBrowsing() {
        connectionManager.stopBrowsing()
    }
}

// MARK: - Message Handling
extension LobbyViewModel {
    func sendMessage() {
        let message = StartGameEncoder(playerName: connectionManager.myPeerID.displayName)
        connectionManager.send(message: message)
    }
    
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        if (try? JSONDecoder().decode(StartGameEncoder.self, from: data)) != nil {
            DispatchQueue.main.async {
                self.canGoToChat = true
            }
        }
    }
}

// MARK: - Peer Management
extension LobbyViewModel {
    private func setupBindings() {
        connectionManager.$availablePeers.assign(to: &$availablePeers)
        connectionManager.$paired.assign(to: &$isConnected)
        connectionManager.$receivedInvite.assign(to: &$receivedInvite)
        connectionManager.$recivedInviteFrom.assign(to: &$receivedInviteFrom)
    }

    func onDisconnected(peerID: MCPeerID) {
        connectedPeers.removeAll { $0.displayName == peerID.displayName }
    }
}
