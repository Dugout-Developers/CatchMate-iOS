//
//  FontUtility.swift
//  CatchMate
//
//  Created by 방유빈 on 7/3/24.
//

import UIKit
import RxSwift

struct TextStyle {
    let font: UIFont
    let kern: CGFloat?
    let lineHeight: CGFloat?
}

extension TextStyle {
    init(fontName: String, pointSize: CGFloat, kerning: CGFloat, lineHeight: CGFloat) {
        let fontDescriptor = UIFontDescriptor(name: fontName, size: pointSize)
        let font = UIFont(descriptor: fontDescriptor, size: pointSize)
        self.init(font: font, kern: kerning, lineHeight: lineHeight)
    }

    init(font: UIFont) {
        self.init(font: font, kern: nil, lineHeight: nil)
    }
    
    func getAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: self.font,
        ]
        
        if let lineHeight = self.lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }
        
        if let kern = self.kern {
            attributes[.kern] = kern
        }

        return attributes
    }
}

final class FontUtility {
    enum PretendardWeight: String  {
        case regular = "PretendardVariable-Regular"
        case thin = "PretendardVariable-Thin"
        case extraLight = "PretendardVariable-ExtraLight"
        case light = "PretendardVariable-Light"
        case medium = "PretendardVariable-Medium"
        case semibold = "PretendardVariable-SemiBold"
        case bold = "PretendardVariable-Bold"
        case extraBold = "PretendardVariable-ExtraBold"
        case black = "PretendardVariable-Black"
    }

    static func loadPretendardFont(size: CGFloat, weight: PretendardWeight = .regular) -> UIFont {
        guard let pretendardFont = UIFont(name: weight.rawValue, size: size) else {
            fatalError("""
                Failed to load the PretendardVariable font.
                Make sure the font file is included in the project and the Info.plist is updated.
                """
            )
        }
        
        return pretendardFont
    }
}

extension UILabel {
    func applyStyle(textStyle: TextStyle) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: textStyle.font,
        ]
        
        if let lineHeight = textStyle.lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }
        
        if let kern = textStyle.kern {
            attributes[.kern] = kern
        }

        if let currentText = self.text {
            self.attributedText = NSAttributedString(string: currentText, attributes: attributes)
        }
    }
}

extension UITextField {
    func applyStyle(textStyle: TextStyle, placeholdeAttr: [NSAttributedString.Key: Any]? = nil) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: textStyle.font,
        ]
        
        if let lineHeight = textStyle.lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }
        
        if let kern = textStyle.kern {
            attributes[.kern] = kern
        }
        
        if let currentText = self.text, !currentText.isEmpty {
            self.attributedText = NSAttributedString(string: currentText, attributes: attributes)
        }
        // Placeholder 적용
        if let placeholderText = self.placeholder, let attr = placeholdeAttr {
            var tempAttr = attributes
            attr.forEach { key, value in
                tempAttr[key] = value
            }
            self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: tempAttr)
        }
    }
}

extension UITextView {
    func applyStyle(textStyle: TextStyle) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: textStyle.font,
        ]
        
        if let lineHeight = textStyle.lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }
        
        if let kern = textStyle.kern {
            attributes[.kern] = kern
        }

        if let currentText = self.text {
            self.attributedText = NSAttributedString(string: currentText, attributes: attributes)
        }
    }
}

extension UIButton {
    func applyStyle(textStyle: TextStyle, anyAttr: [NSAttributedString.Key: Any]? = nil) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: textStyle.font,
        ]
        
        if let lineHeight = textStyle.lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }
        
        if let kern = textStyle.kern {
            attributes[.kern] = kern
        }
        if let anyAttr = anyAttr {
            anyAttr.forEach { key, value in
                attributes[key] = value
            }
        }
        
        let attributedString = NSAttributedString(string: self.currentTitle ?? "", attributes: attributes)
        self.setAttributedTitle(attributedString, for: .normal)

    }
}
