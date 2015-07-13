//
//  Constants.h
//  valueup_test_device
//
//  Created by JoonHo Son on 2015. 7. 7..
//  Copyright © 2015년 JoonHo Son. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

//#define LOCALHOST
//#define WIFI

#ifdef LOCALHOST
#define HOST @"http://localhost:8080"
#else
#ifdef WIFI
//#define HOST @"http://192.168.0.13:8080"
#define HOST @"http://192.168.0.116:8080"
#else
#define HOST @"http://23.236.53.102:8080/project-valueup"
#endif
#endif

#define RESULT_OK @"ok"
#define RESULT_FAIL @"fail"
#define CELL_IDENTIFIER @"cell"

#define MESSAGE_SERVER_ERROR @"서버에서 오류가 발생하였습니다"

#define CONNECT_STRING(uri) [NSString stringWithFormat:@"%@%@", HOST, uri]

#define CHECK_RESULT(obj) if (obj == nil || [RESULT_FAIL isEqualToString:[obj objectForKey:@"result"]]) { \
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil \
                                                                              message:@"서버와의 통신에서 오류가 발생하였습니다." \
                                                                             delegate:nil \
                                                                    cancelButtonTitle:@"확인" \
                                                                    otherButtonTitles:nil, nil];\
                              [alert show]; \
                              return; \
                           }

#define SHOW_INDICATOR [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]
#define HIDE_INDICATOR [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]

#endif /* Constants_h */
