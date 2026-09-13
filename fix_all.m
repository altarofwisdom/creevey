                                if ((++i & 127) == 0)
                                    [self updateStatusOnMainThread:^NSString *{
                                        return [NSString stringWithFormat:@"%@ (%lu)", loadingMsg, i];
                                    }];
                            }
                        }
                        if (stopCaching) {
