import UIKit

extension UIFont {
    
    func monospaced() -> UIFont {
        let fontDescriptorFeatureSettings = [
            [
                UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
            ]
        ]
        
        let fontDescriptorAttributes = [UIFontDescriptorFeatureSettingsAttribute: fontDescriptorFeatureSettings]
        let fontDescriptor = self.fontDescriptor().fontDescriptorByAddingAttributes(fontDescriptorAttributes)
        
        return UIFont(descriptor: fontDescriptor, size: pointSize)
    }
    
}