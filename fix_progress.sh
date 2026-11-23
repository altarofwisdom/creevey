#!/bin/bash
cat << 'INNER' > script.awk
/while \(\(ent = readdir\(dir\)\) != NULL\) \{/ {
    print $0
    print "        static int loopCount = 0;"
    print "        if (progress && ((++loopCount) % 128 == 0)) {"
    print "            [lock lock];"
    print "            NSUInteger currentCount = results.count + localURLs.count;"
    print "            [lock unlock];"
    print "            progress(pathStr, currentCount);"
    print "        }"
    next
}
{print}
INNER
awk -f script.awk FastScanner.m > tmp.m && mv tmp.m FastScanner.m
