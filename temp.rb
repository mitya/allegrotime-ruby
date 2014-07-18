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