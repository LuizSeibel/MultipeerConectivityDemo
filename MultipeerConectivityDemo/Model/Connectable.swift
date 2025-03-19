//
//  ServiceHandler.swift
//  MultipeerConectivityDemo
//
//  Created by Luiz Seibel on 17/03/25.
//

import Foundation
import MultipeerConnectivity

protocol Connectable{
    func onReceiveMessage(data: Data, peerID: MCPeerID)
    func sendMessage()
}
