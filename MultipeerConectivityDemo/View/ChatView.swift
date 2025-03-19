//
//  StartView.swift
//  MultipeerConectivityDemo
//
//  Created by Luiz Seibel on 17/03/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel

    init(connectionManager: MPCManager) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        NavigationView{
            VStack {
                List(viewModel.messages, id: \.self) { msg in
                    Text(msg)
                }
                
                HStack {
                    TextField("Type your message", text: $viewModel.inputMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled(true)
                    
                    Button("Send") {
                        viewModel.sendMessage()
                    }
                }
                .padding()
            }
            .navigationTitle("Chat")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}
