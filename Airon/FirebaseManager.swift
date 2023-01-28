//
//  FirebaseManager.swift
//  Airon
//
//  Created by Eduard Kanevskii on 18.01.2023.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

final class FirebaseManager {
//    let auth: Auth
    let storage: StorageReference
    let firestore: Firestore
    let auth: Auth
    var isAdmin = false
    
    var model = "text-davinci-003"
    var temperature = 0.5
    var max_tokens: Double = 500
    var top_p: Double = 1
    var frequency_penalty = 0.5
    var presence_penalty = 0.0
    
    static let shared = FirebaseManager()
    
    init() {
//        FirebaseApp.configure()
        auth = Auth.auth()
        storage = Storage.storage().reference()
        firestore = Firestore.firestore()
        
    }
}

struct ReferenceKeys {
    static let topics = "topics"
    static let isActive = "isActive"
    static let position = "position"
    static let meSender = "meSender"
    static let aiSender = "aiSender"
    static let ForceUpdate = "ForceUpdate"
    static let AIauth = "AIauth"
    static let AIRequestSettings = "AIRequestSettings"
}


struct AIToken: Codable {
    let token: String
}
