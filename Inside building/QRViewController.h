//
//  ViewController.h
//  QRReader
//
//  Created by Мария Тимофеева on 13.05.17.
//  Copyright © 2017 Мария Тимофеева. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderDelegate.h"
@interface QRViewController : UIViewController <QRCodeReaderDelegate>

- (IBAction)scanAction:(id)sender;


@end

