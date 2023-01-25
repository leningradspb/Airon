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
}
