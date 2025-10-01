# GitHub Actions for Play Store Deployment

This directory contains GitHub Actions workflows for building and deploying your Flutter app to the Google Play Store with support for multiple flavors and different signing keys.

## Workflows

### 1. `play-store-deploy.yml` (Basic)
A straightforward workflow that builds and deploys all flavors using a matrix strategy.

### 2. `play-store-deploy-advanced.yml` (Advanced)
An advanced workflow that:
- Uses a configuration file for flavor settings
- Supports manual deployment of specific flavors
- Handles different signing keys per flavor
- Provides better error handling and notifications

### 3. `play-store-deploy-safe.yml` (Recommended for Production)
A safe workflow with proper deployment strategies:
- **Automatic triggers**: Deploy to INTERNAL track (safe testing)
- **Tag releases**: Deploy to PRODUCTION track (public release)
- **Manual triggers**: Choose specific track (internal/alpha/beta/production)
- **Demo flavor**: Always goes to INTERNAL track

### 4. `test-build.yml` (Testing)
Build validation workflow for pull requests without deployment.

## Setup Instructions

### 1. Required Secrets

You need to set up the following secrets in your GitHub repository:

#### For each flavor (replace `{FLAVOR}` with the actual flavor name):
- `{FLAVOR}_STORE_PASSWORD` - Password for the keystore file
- `{FLAVOR}_KEY_PASSWORD` - Password for the key alias
- `{FLAVOR}_KEYSTORE_BASE64` - Base64 encoded keystore file

#### Global secrets:
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Service account JSON for Play Console API

### 2. Setting up Secrets

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add the following secrets:

#### For PACE flavor (and others using pace_key.jks):
```
PACE_STORE_PASSWORD=pace1234
PACE_KEY_PASSWORD=pace1234
PACE_KEYSTORE_BASE64=<base64 encoded pace_key.jks>
```

#### For GAES flavor (using separate key):
```
GAES_STORE_PASSWORD=123456
GAES_KEY_PASSWORD=123456
GAES_KEYSTORE_BASE64=<base64 encoded gaes.key>
```

#### For other flavors using pace_key.jks:
```
IISS_STORE_PASSWORD=pace1234
IISS_KEY_PASSWORD=pace1234
IISS_KEYSTORE_BASE64=<base64 encoded pace_key.jks>
# ... repeat for other flavors
```

#### Google Play Console Service Account:
```
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=<your service account JSON>
```

### 3. Converting Keystore to Base64

To convert your keystore files to base64:

```bash
# For pace_key.jks
base64 -i android/pace_key.jks | pbcopy

# For gaes.key (if you have it)
base64 -i path/to/gaes.key | pbcopy
```

### 4. Google Play Console Setup

1. Go to Google Play Console
2. Navigate to Setup → API access
3. Create a new service account
4. Download the JSON key file
5. Add the service account to your app with "Release Manager" role
6. Copy the JSON content to the `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret

## Usage

### 🚨 **IMPORTANT: INTERNAL TRACK ONLY**

**All workflows are configured to deploy ONLY to the INTERNAL track for safety.**

| Trigger | Track | Description |
|---------|-------|-------------|
| **Push to main** | `internal` | Safe testing - only internal testers |
| **Tag release (v*)** | `internal` | Safe testing - only internal testers |
| **Manual trigger** | `internal` | Safe testing - only internal testers |
| **All flavors** | `internal` | Always internal testing only |

### Automatic Deployment

The workflows will automatically trigger on:
- **Push to `main`** → Deploy to **INTERNAL** track (safe)
- **Tag pushes** (e.g., `v1.0.0`) → Deploy to **INTERNAL** track (safe)

### Manual Deployment

1. Go to Actions tab in your GitHub repository
2. Select "Deploy to Play Store (Safe)" (recommended)
3. Click "Run workflow"
4. Choose:
   - **Flavor** to deploy
   - Whether to upload to Play Store
   - **Note**: All deployments go to INTERNAL track only

### Safe Deployment Process

1. **Development** → Push to `main` → **INTERNAL** track
2. **Testing** → Test with internal users
3. **Manual Promotion** → Manually promote from Play Console to production when ready
4. **Public** → Available to all users (after manual promotion)

## Flavor Configuration

The `flavor-config.json` file contains configuration for each flavor:

```json
{
  "flavors": {
    "pace": {
      "app_id": "com.pacesharjah.schoolapp",
      "app_name": "PACE INTL",
      "key_file": "pace_key.jks",
      "key_alias": "pace",
      "track": "production",
      "icon_config": "flutter_launcher_icons-pace.yaml"
    }
    // ... other flavors
  }
}
```

## Supported Flavors

- **pace** - PACE INTL (com.pacesharjah.schoolapp)
- **iiss** - PACE IISS (com.iiss.schoolapp)
- **gaes** - PACE GAES (com.gaes.schoolapp) - Uses separate signing key
- **cbsa** - CBS Abudhabi (com.cbsa.schoolapp)
- **dpsa** - DPS Ajman (com.dpsa.schoolapp)
- **pmbs** - PACE PMBS (com.pmbs.schoolapp)
- **pcbs** - PACE PCBS (com.pcbs.schoolapp)
- **pbss** - PACE PBSS (com.pbss.schoolapp)
- **sisd** - Springfield (com.sisd.schoolapp)
- **demo** - DEMO (com.demo.schoolapp) - Deploys to internal track

## Troubleshooting

### Common Issues

1. **Signing key not found**: Make sure the keystore file is properly base64 encoded and the secret is set correctly.

2. **Play Store upload fails**: Verify that the service account has the correct permissions and the app ID matches.

3. **Build fails**: Check that all dependencies are properly configured and the Flutter version is compatible.

### Debug Steps

1. Check the workflow logs for detailed error messages
2. Verify all secrets are set correctly
3. Test the build locally first
4. Ensure the keystore files are valid

## Security Notes

- Never commit keystore files or passwords to the repository
- Use GitHub Secrets for all sensitive information
- Regularly rotate your signing keys
- Monitor the Actions logs for any security issues

## Customization

You can customize the workflows by:
- Modifying the `flavor-config.json` file
- Adding new flavors to the configuration
- Changing the build matrix in the workflow files
- Adding additional build steps or notifications

