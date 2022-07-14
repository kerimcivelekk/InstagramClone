//
//  AuthViewModel.swift
//  SwiftUIInstagramTutorial
//
//  Created by Kerim Civelek on 19.06.2022.
//

import SwiftUI
import Firebase

class AuthViewModel:ObservableObject{    // Dinleme yaptığımız kısım Observe
    
    @Published var userSession : FirebaseAuth.User? // Anlık değişim takibi Published
    
    @Published var currentUser : User?
    
    static let shared = AuthViewModel()
    
    init(){
        
        userSession = Auth.auth().currentUser
        
        fetchUser()
        
    }
    
    func login(withEmail email : String, password : String){
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Debug: Login Failed \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {return}
            print("************************************************************Succesfully loginned user...")
            self.userSession = user

            self.fetchUser()
            
        }
    }
    
    
    func register(withEmail email : String, password : String, image: UIImage?, fullname: String, username: String){
        
        guard let image = image else { return }

        
        ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in   //API klasöründen firebase storage kaydetme alanı
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                
                guard let user = result?.user else{return}
                print("Succesfully registered user...")
                
                
                let data = ["email": email,
                            "username": username,
                            "fullname": fullname,
                            "profileImageUrl":imageUrl,
                            "uid": user.uid]
                
                Firestore.firestore().collection("users").document(user.uid).setData(data) { _ in
                    
                    print("Succesfully uploaded user data....")
                    self.userSession = user
                    
                    self.fetchUser()

                }
            }
        }
    }
    
    func signOut(){
        self.userSession = nil
        try? Auth.auth().signOut()
    }
    
    func resetPassword(){
        
    }
    
    func fetchUser(){ // Mevcut Kullanıcıyı alma
        
        guard let uid = userSession?.uid else {return}
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, _ in
            
            guard let user = try? snapshot?.data(as: User.self) else {return}
            
            self.currentUser = user
        }
    }
}
