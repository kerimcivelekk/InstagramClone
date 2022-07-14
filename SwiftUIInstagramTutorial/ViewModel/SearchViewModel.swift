//
//  SearchViewModel.swift
//  SwiftUIInstagramTutorial
//
//  Created by Kerim Civelek on 21.06.2022.
//

import SwiftUI
import FirebaseFirestore

class SearchViewModel:ObservableObject{ //UserlistView e gönderiyoruz
    
    @Published var users = [User]()
    
    init(){
        
        fetchUsers()
    }
    
    func fetchUsers(){ // bütün kullanıcıları alma
        
        Firestore.firestore().collection("users").getDocuments { snapshot, _ in
            
            guard let documents = snapshot?.documents else {return}
            
            self.users = documents.compactMap({ try? $0.data(as: User.self)})      //yada bunu kullan
            
            
//            documents.forEach { snapshot in
//                guard let user = try? snapshot.data(as: User.self) else {return}    //ister bunu kullan
//                self.users.append(user)
//            }
        }
    }
    
    
    func filteredUsers(_ query:String) -> [User]{
        let lowercasedQuery = query.lowercased()
        return users.filter({ $0.fullname.lowercased().contains(lowercasedQuery) || $0.username.contains(lowercasedQuery)})
    }
}
