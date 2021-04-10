#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

void loadObjCHooks();
void loadStealienObjCHooks();
void loadYogiyoObjcHooks();
void loadSmilePayObjcHooks();
void loadKakaoTaxiObjcHooks();

@interface CUINamedImage : NSObject
-(CGImageRef)image;
-(CGSize)size;
-(double)scale;
-(id)name;
-(CGImageRef)createImageFromPDFRenditionWithScale:(double)scale;
@end

@interface CUICatalog : NSObject
+(CUICatalog *)defaultUICatalogForBundle:(id)bundle;
-(id)initWithURL:(id)url error:(id*)error;
-(id)initWithName:(id)name fromBundle:(id)bundle error:(id*)error;
-(id)allImageNames;
-(id)imagesWithName:(id)name;
-(CUINamedImage*)imageWithName:(id)name scaleFactor:(double)factor;
-(CUINamedImage*)imageWithName:(id)name scaleFactor:(double)factor deviceIdiom:(int)idiom;
-(CUINamedImage*)imageWithName:(id)name scaleFactor:(double)factor displayGamut:(long long)gamut;
-(id)imageWithName:(id)arg1 scaleFactor:(double)arg2 displayGamut:(unsigned long long)arg3 layoutDirection:(long long)direction;
@end
