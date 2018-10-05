//
//  Utility.swift
//  RingLabel
//
//  Created by 解 磊 on 2017/5/15.
//  Copyright © 2017年 AppLeg Corp. All rights reserved.
//

import Foundation

extension String {
    /// 获取字符下标
    ///
    /// - Parameter index: 字符索引
    subscript (index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

extension CGRect {
    /// 中心
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
