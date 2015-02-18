//
//  logger.h
//  Rented
//
//  Created by Lucian Gherghel on 23/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

//custom error log implementation to ease comments removal when going to store

#ifndef Rented_logger_h
#define Rented_logger_h

#define ENABLE_DEBUGGING    TRUE

#define DISPLAY_ERROR       TRUE
#define DISPLAY_WARNING     TRUE
#define DISPLAY_INFO        TRUE

#define RTLog(fmt, ...) if(ENABLE_DEBUGGING) NSLog(fmt, ##__VA_ARGS__)

#define RTLogError(fmt, ...) if(DISPLAY_ERROR) RTLog(fmt, ##__VA_ARGS__)

#define RTLogWarning(fmt, ...) if(DISPLAY_WARNING) RTLog(fmt, ##__VA_ARGS__)

#define RTLogInfo(fmt, ...) if(DISPLAY_INFO) RTLog(fmt, ##__VA_ARGS__)

#endif
