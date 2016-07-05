//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/30.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation

var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}
