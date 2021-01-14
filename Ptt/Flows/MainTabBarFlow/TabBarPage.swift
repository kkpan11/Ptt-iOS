//
//  TabBarPage.swift
//  Ptt
//
//  Created by 賴彥宇 on 2021/1/9.
//  Copyright © 2021 Ptt. All rights reserved.
//

import UIKit

enum TabBarPage {
    case favorite
    case hotTopic
    case settings
    
    init?(index: Int) {
        switch index {
        case 0:
            self = .favorite
        case 1:
            self = .hotTopic
        case 2:
            self = .settings
        default:
            return nil
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .favorite:
            return 0
        case .hotTopic:
            return 1
        case .settings:
            return 2
        }
    }
    
    
    func pageTitleValue() -> String {
        switch self {
        case .favorite:
            return "Favorite Boards"
        case .hotTopic:
            return "Hot Topics"
        case .settings:
            return "Settings"
        }
    }
    
    func pageIconImage() -> UIImage {
        switch self {
        case .favorite:
            return StyleKit.imageOfFavoriteTabBar()
        case .hotTopic:
            return StyleKit.imageOfHotTopic()
        case .settings:
            // TODO: update design from Zeplin
            if #available(iOS 13.0, *) {
                if let gearImage = UIImage(systemName: "gear") {
                    return gearImage
                }
            }
            return UIImage()
        }
    }
    // Add tab icon selected / deselected color
    // etc
}
