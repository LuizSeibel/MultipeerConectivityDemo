//
//  MPCEncoder.swift
//  MultipeerConectivityDemo
//
//  Created by Luiz Seibel on 17/03/25.
//

import Foundation
import MultipeerConnectivity

enum Action: Int, Codable {
    case start, sendMessage
}

protocol MPCEncoder: Codable {
    var playerName: String {get set}
}

extension MPCEncoder {
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

struct StartGameEncoder: MPCEncoder {
    var playerName: String
    var action: Action.RawValue = Action.start.rawValue
    
    init(playerName: String){
        self.playerName = playerName
    }
}

struct SendMessageEncoder: MPCEncoder {
    var playerName: String
    var action: Action.RawValue = Action.sendMessage.rawValue
    var message: String = ""
    
    init(message: String, playerName: String){
        self.playerName = playerName
        self.message = message
    }
}
