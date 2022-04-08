//
//  GaranteeMainQueue.swift
//  Bible
//
//  Created by Bogdan Grozian on 05.04.2022.
//

import Foundation

func garanteeMainThread(_ task: @escaping (() -> ())) {
    if Thread.isMainThread {
        task()
    } else {
        DispatchQueue.main.async(execute: task)
    }
}
