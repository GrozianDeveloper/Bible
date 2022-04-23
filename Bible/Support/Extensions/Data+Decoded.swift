//
//  Data.swift
//  Bible
//
//  Created by Bogdan Grozian on 28.02.2022.
//

import Foundation

extension Data {
    func decoded<T: Decodable>(as type: T.Type, completion: @escaping (Result<T,Error>) -> ()) {
        let decodingQueue = DispatchQueue(label: "com.bible.decoding", attributes: .concurrent)
        decodingQueue.async {
            let result = Result {
                try JSONDecoder().decode(T.self, from: self)
            }
            completion(result)
        }
    }
}
