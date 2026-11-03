#!/bin/bash

# DEPRECATED - DO NOT USE
#
# This script previously rebuilt www/ by pulling the old conceal-web-wallet
# repository as a Git subtree. That wallet is deprecated and this repository
# now ships www/ as a committed static export of conceal-next-wallet.
#
# Running the old script would delete the current www/ bundle
# (rm -rf www) and replace it with the deprecated wallet, so it now aborts.
#
# To regenerate the web bundle, run from conceal-next-wallet:
#   npm run cordova
# which builds the export and post-processes it into ../conceal-wallet-cordova/www.

echo "ERROR: setup-web-wallet.sh is deprecated and intentionally disabled." >&2
echo "" >&2
echo "It used to replace www/ with the deprecated conceal-web-wallet subtree," >&2
echo "which would destroy the current conceal-next-wallet bundle committed here." >&2
echo "" >&2
echo "To regenerate the web bundle, run from a checkout of conceal-next-wallet:" >&2
echo "  npm run cordova" >&2
echo "" >&2
echo "See README.md and FDROID_SUBMISSION.md for the bundle provenance." >&2
exit 1
