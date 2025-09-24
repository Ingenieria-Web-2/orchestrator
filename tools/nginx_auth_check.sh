#!/bin/sh
# Small helper script to manually test nginx auth flow.
# Usage examples (run these in your shell):
# 1) Obtain a token from users service:
#    curl -X POST -d "username=test@example.com&password=s3cret" http://localhost:80/api/user/token
# 2) Verify token via gateway (this triggers nginx auth subrequest):
#    curl -H "Authorization: Bearer <token>" http://localhost/api/recipe/
#
# If everything is wired correctly, nginx will call the internal /_verify_auth
# which proxies to users_service /api/user/verify-token and captures X-User-ID.

echo "Example curl commands to test auth flow:\n"
echo "1) Login and get token (replace email/password):"
echo "   curl -X POST -d 'username=test@example.com&password=s3cret' http://localhost/api/user/token"
echo "\n2) Call recipe endpoint via gateway with Authorization header (replace <token>):"
echo "   curl -H 'Authorization: Bearer <token>' http://localhost/api/recipe/"

echo "\n3) If you want to see the verify endpoint directly (for debugging):"
echo "   curl -I -H 'Authorization: Bearer <token>' http://localhost/api/user/verify-token"

echo "\nNote: If using docker-compose, ensure the gateway is bound to localhost:80"
