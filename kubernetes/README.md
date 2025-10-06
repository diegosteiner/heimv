# Deployment with kubernetes

## Resources

- **deployment/web**: The app's web server and main component
- **deployment/hobs**: The app's job worker

## Configuration

- Generate/Add secrets and config in *kustomization.yaml*

## Additional needed resources

- A postgres database
- A redis database (ephemeral is sufficent)
- An S3-compatible bucket
- An SMTP server
- An Ingress
