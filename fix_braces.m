                                if ((++i & 127) == 0)
                                    [self updateStatusOnMainThread:^NSString *{
                                        return [NSString stringWithFormat:@"%@ (%lu)", loadingMsg, i];
                                    }];
                                
                                static NSTimeInterval lastUIDate = 0;
                                NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
                                if (now - lastUIDate > 0.3) {
                                    lastUIDate = now;
                                    NSArray *currentFilenames = [filenames copy];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (self->currCat == 0) {
                                            [self->displayedFilenames setArray:currentFilenames];
                                            self->imgMatrix.numberOfCells = currentFilenames.count;
                                            [self->imgMatrix setNeedsDisplay:YES];
                                        }
                                    });
                                }
                            }
                        }
