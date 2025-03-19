//
//  MultipeerConnectivity.swift
//  MultipeerConectivityDemo
//
//  Created by Luiz Seibel on 13/03/25.
//

import MultipeerConnectivity

extension String{
    // Plist: Bonjour services
    static var serviceName = "mpc-demo"
}

class MPCManager: NSObject, ObservableObject{
    // Plist: Privacy - Local Network Usage Description
    let serviceType: String = String.serviceName
    
    // Identidate própria do telefone
    let session: MCSession
    let myPeerID: MCPeerID
    
    // Mecanismos de Sinalização e Busca
    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    
    // TODO: Descobrir esse tipo de inicialização de var do availablePeers
    @Published var paired: Bool = false
    @Published var availablePeers = [MCPeerID]()
    @Published var receivedInvite: Bool = false
    @Published var recivedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    // Used Closures
    var onRecieveData: ((Data, MCPeerID) -> Void)?
    var onDisconnectedPeer: ((MCPeerID) -> Void)?
    
    // State variables
    var isAvaibleToAdvertise: Bool = false {
        didSet {
            if isAvaibleToAdvertise {
                startAdvertising()
            } else {
                stopAdvertising()
            }
        }
    }
    
    init(yourName: String){
        let yourName = yourName.isEmpty ? UUID().uuidString : yourName
        
        myPeerID = MCPeerID(displayName: yourName)
        session = MCSession(peer: myPeerID)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        
        super.init()
        session.delegate = self
        nearbyServiceBrowser.delegate = self
        nearbyServiceAdvertiser.delegate = self
    }
    
    deinit{
        stopAdvertising()
        stopBrowsing()
    }
}

// MARK: Start/Stop Advertiser & Browser
extension MPCManager{
    func startAdvertising(){
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising(){
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing(){
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing(){
        nearbyServiceBrowser.stopBrowsingForPeers()
        availablePeers.removeAll()
    }
}

// MARK: Service Browser Delegate
extension MPCManager: MCNearbyServiceBrowserDelegate {
    
    // Método que encontra os peers ao redor
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    // Método acionado caso um peer seja perdido
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = availablePeers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.availablePeers.remove(at: index)
        }
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.recivedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

extension MPCManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
            }
        case .notConnected:
            DispatchQueue.main.async {
                self.paired = false
                
                if let onDisconnectedPeer = self.onDisconnectedPeer {
                    onDisconnectedPeer(peerID)
                }
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let onRecieveData = self.onRecieveData {
            onRecieveData(data, peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
}

// MARK: Conexão
extension MPCManager {
    
    func disconnect() {
        session.disconnect()
        DispatchQueue.main.async {
            self.paired = false
            self.availablePeers.removeAll()
        }
        stopAdvertising()
        stopBrowsing()
    }
    
    func invite(peer: MCPeerID) {
        nearbyServiceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }
}

// MARK: Troca de Mensagens
extension MPCManager {
    
    func send(message: MPCEncoder){
        if !session.connectedPeers.isEmpty {
            do{
                if let data = message.data(){
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}
