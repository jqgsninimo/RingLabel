//
//  RingLabel.swift
//  RingLabel
//
//  Created by 解 磊 on 2017/5/15.
//  Copyright © 2017年 AppLeg Corp. All rights reserved.
//

import UIKit
import SnapKit

/// 环形标签
@IBDesignable public class RingLabel: UICollectionView {
    /// 文本（默认为空字符串）
    @IBInspectable public var text: String = "" {
        didSet {
            for character in "\n\r\t" {
                self.text = self.text.replacingOccurrences(of: String(character), with: " ")
            }
        }
    }
    
    /// 字体（默认为系统标准字体）
    public var font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    /// 字体尺寸
    @IBInspectable public var fontSize: CGFloat {
        get { return self.font.pointSize }
        set { self.font = self.font.withSize(newValue) }
    }
    
    /// 文本高度因子，占视图半径除去边距部分后的比例，取值范围为[0.1,0.5]（默认为空）
    public var textHeightFactor: CGFloat? = nil {
        didSet {
            if let textHeightFactor = self.textHeightFactor {
                self.textHeightFactor = min(0.5, max(0.1, textHeightFactor))
            }
        }
    }
    /// 字体尺寸因子，文本高度因子的非可选形式，提供给IB使用
    @IBInspectable public var fontSizeFactor: CGFloat {
        get { return self.textHeightFactor ?? 0 }
        set { self.textHeightFactor = newValue > 0.1 ? newValue : nil }
    }
    
    /// 文字颜色（默认黑色）
    @IBInspectable public var textColor: UIColor = UIColor.black
    
    /// 文字对齐方式：居左|居中|居右（默认居中）
    public var textAlignment: NSTextAlignment = .center {
        didSet {
            switch textAlignment {
            case .left, .center, .right:
                break
            default:
                textAlignment = .center
            }
        }
    }
    
    /// 顺时针：为真时文字朝向圆心顺时针排布；为假时文字背向圆心逆时针排布（默认为真）
    @IBInspectable public var clockwise: Bool = true
    
    /// 行中断方式：切断|省略开头|省略中间|省略结尾（默认为省略结尾）
    public var lineBreakMode: NSLineBreakMode = .byTruncatingTail {
        didSet {
            switch self.lineBreakMode {
            case .byClipping, .byTruncatingHead, .byTruncatingMiddle, .byTruncatingTail:
                break
            default:
                self.lineBreakMode = .byTruncatingTail
            }
        }
    }
    
    /// 调整字体适应宽度（默认不调整）
    @IBInspectable public var adjustsFontSizeToFitWidth: Bool = false
    /// 字体最小比例因子，当可调整字体适应宽度时，字体最小不得小于指定尺寸的该因子倍数（默认为0）
    @IBInspectable public var minimumScaleFactor: CGFloat = 0 {
        didSet {
            self.minimumScaleFactor = min(1, max(0, self.minimumScaleFactor))
        }
    }
    
    /// 基准角度，指定绘制文字的基准位置(右:0,下:0.5π,左:π,上:1.5π)，取值范围为[0,2π)（默认为最上方，即1.5π）
    public var baseAngle: CGFloat = CGFloat.pi * 1.5 {
        didSet {
            self.baseAngle = self.baseAngle.truncatingRemainder(dividingBy: 2 * CGFloat.pi)
            if self.baseAngle < 0 {
                self.baseAngle += 2 * CGFloat.pi
            }
        }
    }
    
    /// 位置因子，指定绘制文字的基准位置，为基准角度相对于2π的比例，取值范围为[0,1)
    @IBInspectable public var positionFactor: CGFloat {
        get { return self.baseAngle / (CGFloat.pi * 2) }
        set { self.baseAngle = newValue * (CGFloat.pi * 2) }
    }
    
    /// 边距因子，指定文字边距，占视图半径的比例，取值范围为[0,0.5]（默认为0）
    @IBInspectable public var marginFactor: CGFloat = 0 {
        didSet {
            self.marginFactor = min(0.5, max(0, self.marginFactor))
        }
    }
    
    /// 首尾间距因子，指定文字首位的间距，是相对于绘制圆周的倍数，取值范围为[0,0.75]（默认为0.25）
    @IBInspectable public var spaceFactor: CGFloat = 0.25 {
        didSet {
            self.spaceFactor = min(0.75, max(0, self.spaceFactor))
        }
    }
    
    /// 是否线状显示，而不作环状显示（默认为否）
    @IBInspectable public var lineMode: Bool = false
    
    /// 单元复用识别码
    fileprivate let cellIdentifier = "RingLabelCell"
    
    convenience init() {
        self.init(frame: CGRect.zero, collectionViewLayout: RingLabelLayout())
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: CGRect.zero, collectionViewLayout: RingLabelLayout())
        self.generate()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.collectionViewLayout = RingLabelLayout()
        self.generate()
    }
    
    private func generate() {
        self.dataSource = self
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
    }
    
    /// 更新布局
    ///
    /// - Parameter animated: 是否动画
    public func updateLayout(animated: Bool = true) {
        if animated {
            (self.collectionViewLayout as? RingLabelLayout)?.freezed = true
            let layout = RingLabelLayout()
            self.setCollectionViewLayout(layout, animated: true)
        } else {
            self.collectionViewLayout.invalidateLayout()
        }
    }
}

// MARK: - 履行UICollectionViewDataSource协议
extension RingLabel: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? self.text.count : 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath)
        
        let label: UILabel
        if let view = cell.contentView.subviews.first as? UILabel {
            label = view
        } else {
            label = UILabel()
            label.contentMode = .center
            label.baselineAdjustment = .alignCenters
            label.font = self.font.withSize(100)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.01
//            label.backgroundColor = UIColor.green
            cell.contentView.addSubview(label)
            label.snp.makeConstraints({ $0.edges.equalToSuperview() })
        }
        
        label.text = indexPath.section == 0 ? String(self.text[indexPath.item]) : "."
        
        return cell
    }
}

extension RingLabel {
    /// 边距
    fileprivate var margin: CGFloat {
        return min(self.bounds.width, self.bounds.height) / 2 * self.marginFactor
    }
    
    /// 绘制区域（从视图区域中去除边距）
    fileprivate var drawingRect: CGRect {
        let margin = self.margin
        return self.bounds.insetBy(dx: margin, dy: margin)
    }
    
    /// 绘制半径（绘制区域的内切圆半径）
    fileprivate var drawingRadius: CGFloat {
        let drawingRect = self.drawingRect
        return min(drawingRect.width, drawingRect.height) / 2
    }
    
    /// 绘制字体
    fileprivate var drawingFont: UIFont {
        // 将文本高度因子反映到尺寸中
        var font = self.font
        if let textHeightFactor = self.textHeightFactor {
            let textHeight = self.drawingRadius * textHeightFactor
            var fontSize = textHeight
            var textSize = self.text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font.withSize(fontSize)]))
            if textSize.height > textHeight {
                repeat {
                    fontSize -= 1
                    textSize = self.text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font.withSize(fontSize)]))
                } while textSize.height > textHeight
            } else {
                repeat {
                    fontSize += 1
                    textSize = self.text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font.withSize(fontSize)]))
                } while textSize.height < textHeight
                fontSize -= 1
            }
            font = font.withSize(fontSize)
        }
        // 仅取整数部分，避免连续调整尺寸导致的画面抖动
        font = font.withSize(font.pointSize.rounded(.down))
        return font
    }
}

/// 环形标签布局
private class RingLabelLayout: UICollectionViewLayout {
    var layoutAttributesOfIndexPaths = [IndexPath: UICollectionViewLayoutAttributes]()
    var freezed = false
    
    override func prepare() {
        super.prepare()
        
        guard let ringLabel = self.collectionView as? RingLabel, !ringLabel.text.isEmpty, !self.freezed else { return }
        
        if ringLabel.lineMode {
            self.prepareLineMode(for: ringLabel)
        } else {
            self.prepareRingMode(for: ringLabel)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return self.collectionView?.bounds.size ?? CGSize.zero
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesOfIndexPaths[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return Array(self.layoutAttributesOfIndexPaths.values)
    }
    
    private func prepareRingMode(for ringLabel: RingLabel) {
        // 文本绘制区域半径（除去边距）
        let radius = ringLabel.drawingRadius
        // 显示文本所用字体
        var font = ringLabel.drawingFont
        // 文字内沿半径，从圆心到文字内沿的长度
        var innerRadius: CGFloat
        // 显示文本的最大尺寸
        var maxTextSize = CGSize.zero
        // 单行横向绘制文本所占尺寸
        var textSize: CGSize
        
        // 调整字体尺寸
        repeat {
            // 按照指定字体绘制文本所需的尺寸
            textSize = ringLabel.text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
            // 文字内沿半径，从圆心到文字内沿的长度
            innerRadius = radius - textSize.height
            // 考虑有效因子，文字最多可用的显示宽度
            let maxArcLength = innerRadius * CGFloat.pi * 2 * (1 - ringLabel.spaceFactor)
            maxTextSize.width = ringLabel.text.reduce(0, { (width, character) -> CGFloat in
                let characterWidth = String(character).size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font])).width
                let arcLength = maxArcLength * characterWidth / textSize.width
                return width + 2 * innerRadius * tan(arcLength / innerRadius / 2)
            })
            
            // 考虑合理性，字体高度应不大于半径
            maxTextSize.height = innerRadius
            if textSize.height > maxTextSize.height {
                if font.pointSize > 1 {
                    font = font.withSize(font.pointSize - 1)
                    continue
                }
            }
            
            // 如果适应宽度有效，调整字体适应宽度
            if ringLabel.adjustsFontSizeToFitWidth && textSize.width > maxTextSize.width {
                let minFontSize = max(1, ringLabel.font.pointSize * ringLabel.minimumScaleFactor)
                if font.pointSize > minFontSize {
                    font = font.withSize(font.pointSize - 1)
                    continue
                }
            }
            
            break
        } while true
        
        // 如果文本依然显示不全，对文本进行省略处理
        let (omittedRange, ellipsisHidden, text) = self.omitText(ringLabel.text, withFont: font, andBreakMode: ringLabel.lineBreakMode, toFitWidth: maxTextSize.width)
        
        // 计算文字描绘角度
        let textAngle = text.reduce(0) { (textAngle, character) -> CGFloat in
            let characterWidth = String(character).size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font])).width
            let characterAngle = atan(characterWidth / innerRadius / 2) * 2
            return textAngle + characterAngle
        }
        // 根据基准角度和文字对齐方式调整开始角度
        let clockwiseFactor = CGFloat(ringLabel.clockwise ? 1 : -1)
        var currentAngle: CGFloat
        switch ringLabel.textAlignment {
        case .left:
            currentAngle = ringLabel.baseAngle
        case .right:
            currentAngle = ringLabel.baseAngle - textAngle * clockwiseFactor
        case .center: fallthrough
        default:
            currentAngle = ringLabel.baseAngle - textAngle / 2 * clockwiseFactor
        }
        
        // 重置布局属性字典
        self.layoutAttributesOfIndexPaths.removeAll()
        
        // 创建生成布局属性的闭包
        let generateLayoutAttributes = { (character: Character, indexPath: IndexPath, hidden: Bool) in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let size = String(character).size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
            attributes.size = size
            
            let center = ringLabel.bounds.center
            if hidden {
                attributes.alpha = 0
                attributes.center = center
            } else {
                let itemAngle = size.width / innerRadius
                currentAngle += itemAngle / 2 * clockwiseFactor
                var itemCenter = CGPoint.zero
                itemCenter.x = center.x + (innerRadius + size.height / 2) * cos(currentAngle)
                itemCenter.y = center.y + (innerRadius + size.height / 2) * sin(currentAngle)
                let rotationAngle = currentAngle + CGFloat.pi * 0.5 * clockwiseFactor
                currentAngle += itemAngle / 2 * clockwiseFactor
                
                attributes.alpha = 1
                attributes.center = itemCenter
                attributes.transform = CGAffineTransform(rotationAngle: rotationAngle)
            }
            
            self.layoutAttributesOfIndexPaths[indexPath] = attributes
        }
        
        // 生成布局属性
        var textItem = 0
        var index = ringLabel.text.startIndex
        while index != ringLabel.text.endIndex {
            if index == omittedRange.lowerBound {
                for dotItem in 0..<3 {
                    generateLayoutAttributes(".", IndexPath(item: dotItem, section: 1), ellipsisHidden)
                }
            }
            
            generateLayoutAttributes(ringLabel.text[index], IndexPath(item: textItem, section: 0), omittedRange.contains(index))
            textItem += 1
            index = ringLabel.text.index(after: index)
        }
    }
    
    private func prepareLineMode(for ringLabel: RingLabel) {
        // 显示文本的最大尺寸
        let maxTextSize = ringLabel.drawingRect.size
        // 显示文本所用字体
        var font = ringLabel.drawingFont
        // 单行横向绘制文本所占尺寸
        var textSize: CGSize
        
        // 调整字体尺寸
        repeat {
            // 按照指定字体绘制文本所需的尺寸
            textSize = ringLabel.text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
            
            // 调整字体适应高度
            if textSize.height > maxTextSize.height {
                if font.pointSize > 1 {
                    font = font.withSize(font.pointSize - 1)
                    continue
                }
            }
            
            // 如果适应宽度有效，调整字体适应宽度
            if ringLabel.adjustsFontSizeToFitWidth && textSize.width > maxTextSize.width {
                let minFontSize = max(1, ringLabel.font.pointSize * ringLabel.minimumScaleFactor)
                if font.pointSize > minFontSize {
                    font = font.withSize(font.pointSize - 1)
                    continue
                }
            }
            
            break
        } while true
        
        // 如果文本依然显示不全，对文本进行省略处理
        let (omittedRange, ellipsisHidden, text) = self.omitText(ringLabel.text, withFont: font, andBreakMode: ringLabel.lineBreakMode, toFitWidth: maxTextSize.width)
        
        // 计算文字描绘尺寸
        textSize = text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
        // 根据基准角度和文字对齐方式调整开始位置
        // 根据基准角度确定显示方位
        enum Direction: Int {case right, bottom, left, top}
        guard let direction = Direction(rawValue: Int((ringLabel.baseAngle / CGFloat.pi  + 0.25).truncatingRemainder(dividingBy: 2) / 0.5)) else {
            fatalError()
        }
        // 根据显示方位确定开始位置Y轴坐标
        var currentPoint = CGPoint.zero
        switch direction {
        case .top:
            currentPoint.y = (ringLabel.bounds.height - maxTextSize.height + textSize.height) / 2
        case .left, .right:
            currentPoint.y = ringLabel.bounds.midY
        case .bottom:
            currentPoint.y = (ringLabel.bounds.height + maxTextSize.height - textSize.height) / 2
        }
        // 根据文字对齐方式调整开始位置X轴坐标
        switch ringLabel.textAlignment {
        case .left:
            currentPoint.x = (ringLabel.bounds.width - maxTextSize.width) / 2
        case .right:
            currentPoint.x = (ringLabel.bounds.width + maxTextSize.width) / 2 - textSize.width
        case .center: fallthrough
        default:
            currentPoint.x = (ringLabel.bounds.width - textSize.width) / 2
        }
        
        // 重置布局属性字典
        self.layoutAttributesOfIndexPaths.removeAll()
        
        // 创建生成布局属性的闭包
        let generateLayoutAttributes = { (character: Character, indexPath: IndexPath, hidden: Bool) in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let size = String(character).size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
            attributes.size = size
            
            if hidden {
                attributes.alpha = 0
                attributes.center = ringLabel.bounds.center
            } else {
                currentPoint.x += size.width / 2
                var itemCenter = CGPoint.zero
                itemCenter = currentPoint
                currentPoint.x += size.width / 2
                
                attributes.alpha = 1
                attributes.center = itemCenter
            }
            
            self.layoutAttributesOfIndexPaths[indexPath] = attributes
        }
        
        // 生成布局属性
        var textItem = 0
        var index = ringLabel.text.startIndex
        while index != ringLabel.text.endIndex {
            if index == omittedRange.lowerBound {
                for dotItem in 0..<3 {
                    generateLayoutAttributes(".", IndexPath(item: dotItem, section: 1), ellipsisHidden)
                }
            }
            
            generateLayoutAttributes(ringLabel.text[index], IndexPath(item: textItem, section: 0), omittedRange.contains(index))
            textItem += 1
            index = ringLabel.text.index(after: index)
        }
    }
    
    /// 省略文本处理
    ///
    /// - Parameters:
    ///   - text: 要省略的文本
    ///   - font: 所用字体
    ///   - breakMode: 中断模式
    ///   - maxWidth: 宽度限制
    /// - Returns: (省略范围, 是否隐藏省略号, 省略后的文本)
    private func omitText(_ text: String, withFont font: UIFont, andBreakMode breakMode: NSLineBreakMode, toFitWidth limitWidth: CGFloat) -> (omittedRange: Range<String.Index>, ellipsisHidden: Bool, omittedText: String) {
        let ellipsis = "..."
        var omittedRange = text.startIndex..<text.startIndex
        var ellipsisHidden = true
        var omittedText = text
        
        // 按照指定字体绘制文本所需的尺寸
        var textSize = text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
        // 如果文本显示不全，省略或截断文本
        if textSize.width > limitWidth {
            ellipsisHidden = false
            switch breakMode {
            case .byTruncatingHead:
                // 首部省略
                var startIndex = text.index(after: text.startIndex)
                while startIndex != text.endIndex {
                    omittedText = ellipsis + text[startIndex...]
                    textSize = omittedText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
                    if textSize.width < limitWidth {
                        break
                    }
                    startIndex = text.index(after: startIndex)
                }
                omittedRange = text.startIndex..<startIndex
            case .byTruncatingMiddle:
                // 中部省略
                var leftEndIndex = text.index(after: text.startIndex)
                var rightStartIndex = text.endIndex
                var leftChanged = true
                while leftEndIndex != rightStartIndex {
                    let leftText = text[text.startIndex..<leftEndIndex]
                    let rightText = text[rightStartIndex..<text.endIndex]
                    omittedText = leftText + ellipsis + rightText
                    textSize = omittedText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
                    if textSize.width > limitWidth {
                        if leftChanged {
                            leftEndIndex = text.index(before: leftEndIndex)
                        } else {
                            rightStartIndex = text.index(after: rightStartIndex)
                        }
                        break
                    }
                    
                    let leftSize = String(leftText).size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
                    let rightSize = String(rightText).size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
                    if leftSize.width < rightSize.width {
                        leftChanged = true
                        leftEndIndex = text.index(after: leftEndIndex)
                    } else {
                        leftChanged = false
                        rightStartIndex = text.index(before: rightStartIndex)
                    }
                }
                omittedRange = leftEndIndex..<rightStartIndex
            case .byTruncatingTail:
                // 尾部省略
                var endIndex = text.index(before: text.endIndex)
                while endIndex != text.startIndex {
                    omittedText = text[..<endIndex] + ellipsis
                    textSize = omittedText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
                    if textSize.width < limitWidth {
                        break
                    }
                    endIndex = text.index(before: endIndex)
                }
                omittedRange = endIndex..<text.endIndex
            default:
                // 尾部截断
                ellipsisHidden = true
                var endIndex = text.index(before: text.endIndex)
                while endIndex != text.startIndex {
                    omittedText = String(text[..<endIndex])
                    textSize = omittedText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
                    if textSize.width < limitWidth {
                        break
                    }
                    endIndex = text.index(before: endIndex)
                }
                omittedRange = endIndex..<text.endIndex
            }
        }
        
        omittedText = text.replacingCharacters(in: omittedRange, with: ellipsisHidden ? "" : ellipsis)
        return (omittedRange, ellipsisHidden, omittedText)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
