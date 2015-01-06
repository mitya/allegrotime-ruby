NSString.stringWithFormat "ooooo - %@", "string"
NSString.stringWithFormat "ooooo - %s", "heheh"


NSString.stringWithFormat "%@ %@", 20, "mins"


# rake args="-com.apple.CoreData.SQLDebug 1" 
# -AppleLanguages (sv)

# NSLocale.preferredLanguages
# NSBundle.mainBundle.preferredLocalizations
# NSBundle.mainBundle.localizations
# NSLocale.currentLocale.localeIdentifier
# NSUserDefaults.standardUserDefaults['AppleLanguages']


NSBundle.mainBundle.pathForResource("Localizable", ofType:"strings")
# NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:stringsPath];


private func titleAndDateAttributedString(title: String, dateString: String) -> NSAttributedString {
    let workTitle = countElements(title) > 0 ? title : "Untitled"
    let workFont = UIFont.serifItalicFontWithSize(16)
    var attributedString = NSMutableAttributedString(string: workTitle, attributes: [NSFontAttributeName : workFont ])
    
    if countElements(dateString) > 0 {
        let dateFont = UIFont.serifFontWithSize(16)
        let dateString = NSMutableAttributedString(string: ", " + dateString, attributes: [ NSFontAttributeName : dateFont ])
        attributedString.appendAttributedString(dateString)
    }
    
    return attributedString.copy() as NSAttributedString
}


def titleAndDateAttributedString(title, dateString)
  workTitle = countElements(title) > 0 ? title : "Untitled"
  workFont = UIFont.serifItalicFontWithSize(16)
  attributedString = NSMutableAttributedString.new string: workTitle, attributes: {NSFontAttributeName: workFont}
  
  if countElements(dateString) > 0
    dateFont = UIFont.serifFontWithSize(16)
    dateString = NSMutableAttributedString.new string: ", " + dateString, attributes: {NSFontAttributeName: dateFont}
    attributedString.appendAttributedString(dateString)
  end
  
  attributedString.copy
end





func animate(times: Float) {
    let transformOffset = -1.01 * M_PI
    let transform = CATransform3DMakeRotation( CGFloat(transformOffset), 0, 0, 1);
    let rotationAnimation = CABasicAnimation(keyPath:"transform");

    rotationAnimation.toValue = NSValue(CATransform3D:transform)
    rotationAnimation.duration = rotationDuration;
    rotationAnimation.cumulative = true;
    rotationAnimation.repeatCount = Float(times);
    layer.addAnimation(rotationAnimation, forKey:"spin");
}

def animate(times)
  transformOffset = -1.01 * M_PI
  transform = CATransform3DMakeRotation( CGFloat(transformOffset), 0, 0, 1)
  rotationAnimation = CABasicAnimation(keyPath: "transform")

  rotationAnimation.toValue = NSValue(CATransform3D: transform)
  rotationAnimation.duration = rotationDuration
  rotationAnimation.cumulative = true
  rotationAnimation.repeatCount = Float(times)
  layer.addAnimation(rotationAnimation, forKey:"spin")
end



return XAppRequest(artworksEndpoint).map { (object) -> AnyObject! in
    if let response = object as? MoyaResponse {
        return response.statusCode == 200
    }
    return false
}.catchTo(RACSignal.`return`(false))


return XAppRequest.new(artworksEndpoint).map { |object|
    return MoyaResponse === response ? response.statusCode == 200 : false
}.catchTo(RACSignal.`return`(false))

