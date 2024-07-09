# Deployment with kubernetes

## Resources

- **deployment/heimv-web**: The app's web server and main component
- **deployment/heimv-worker**: The app's job worker
- **service/heimv-web-service**: Service for *deployment/heimv-web*

## Additional needed resources

- A postgres database
- A redis database (ephemeral is sufficent)
- An S3-compatible bucket
- An SMTP server
- An Ingress
