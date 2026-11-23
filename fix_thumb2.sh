#!/bin/bash
cat << 'INNER' > script.awk
/\[self updateStatusOnMainThread:\^NSString \*{/ {
    if (in_thumb == 0) {
        # Check if we are inside thumbLoader
        # Actually it's easier to just match the specific code block
    }
}
INNER
# Let's just use sed to replace the thumbLoader block
