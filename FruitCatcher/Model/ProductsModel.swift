//
//  ProductsModel.swift
//  FruitCatcher
//
//  Created by Nathan on 20/03/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import UIKit

class ProductsModel: NSObject {
    var product_img_url: String?
    var product_name: String?
    var product_points: Int?
    
    init(json : [[String:Any]]) {
        for products in json{
            self.product_img_url = products["product_img_url"] as? String
            self.product_name = products["product_name"] as? String
            self.product_points = products["product_points"] as? Int
        }
    }
}
