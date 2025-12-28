# MQTT Troubleshooting Guide - School App Not Receiving Messages

## Problem Summary

The school app is successfully:
- ✅ Connecting to AWS IoT Core MQTT broker
- ✅ Subscribing to the correct topic: `pace/transport/bus/299`
- ✅ Receiving subscription confirmation
- ✅ Message listener is active

**BUT** it's **NOT receiving any messages** even though the transporter app is successfully publishing to the same topic.

## Root Cause Analysis

Based on the logs, the most likely issue is **AWS IoT Core Policy Permissions**. The school app's certificate needs explicit permissions to receive messages on the subscribed topic.

## Diagnosis

### What We Know:
1. **Transporter App** (publishing):
   - Topic: `pace/transport/bus/299`
   - Status: ✅ Publishing successfully
   - Broker: `a7nalq3sp79e9-ats.iot.ap-south-1.amazonaws.com:8883`

2. **School App** (subscribing):
   - Topic: `pace/transport/bus/299` ✅ (matches exactly)
   - Subscription: ✅ Confirmed
   - Connection: ✅ Active
   - Messages Received: ❌ **0 messages**

### The Issue:
When a client subscribes to a topic but doesn't receive messages even though:
- The subscription is confirmed
- The connection is active
- Messages are being published to that exact topic

This typically indicates an **AWS IoT Core Policy permission issue**.

## Solution: Fix AWS IoT Core Policy

### Step 1: Check Current Policy

1. Go to AWS IoT Core Console
2. Navigate to **Security** → **Certificates**
3. Find the certificate used by the school app
4. Click on the certificate → **Policies** tab
5. Review the attached policy

### Step 2: Verify Policy Permissions

The policy attached to the school app's certificate must include:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Connect"
      ],
      "Resource": "arn:aws:iot:ap-south-1:*:client/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Subscribe"
      ],
      "Resource": [
        "arn:aws:iot:ap-south-1:*:topicfilter/pace/transport/bus/*",
        "arn:aws:iot:ap-south-1:*:topicfilter/pace/transport/bus/299"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Receive"
      ],
      "Resource": [
        "arn:aws:iot:ap-south-1:*:topic/pace/transport/bus/*",
        "arn:aws:iot:ap-south-1:*:topic/pace/transport/bus/299"
      ]
    }
  ]
}
```

### Step 3: Update or Create Policy

If the policy doesn't have `iot:Receive` permission, you need to:

1. **Option A: Update Existing Policy**
   - Edit the policy attached to the school app certificate
   - Add the `iot:Receive` action with the correct topic ARN

2. **Option B: Create New Policy**
   - Create a new policy with all required permissions
   - Attach it to the school app certificate

### Step 4: Verify Transporter App Policy

Also verify the transporter app's certificate has permission to publish:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Connect"
      ],
      "Resource": "arn:aws:iot:ap-south-1:*:client/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Publish"
      ],
      "Resource": [
        "arn:aws:iot:ap-south-1:*:topic/pace/transport/bus/*"
      ]
    }
  ]
}
```

## Testing After Fix

After updating the policy:

1. Restart the school app
2. Navigate to bus tracking
3. Check logs for:
   - `📨 [MQTT] Raw message batch received`
   - `✅ [MQTT] Processing message for subscribed topic`

## Alternative Diagnostic: Wildcard Subscription

The code now includes a diagnostic wildcard subscription (`pace/transport/bus/+`). If you see messages on the wildcard but not the exact topic, it confirms a policy issue specific to the exact topic subscription.

## Common Policy Mistakes

1. **Missing `iot:Receive`**: Most common issue - subscription works but receiving doesn't
2. **Wrong Resource ARN**: Topic ARN must match exactly (including region)
3. **Wildcard in wrong place**: Use `topicfilter` for Subscribe, `topic` for Receive/Publish
4. **Region mismatch**: Ensure ARN uses `ap-south-1` (Mumbai region)

## Verification Checklist

- [ ] School app certificate has `iot:Connect` permission
- [ ] School app certificate has `iot:Subscribe` permission for `pace/transport/bus/*`
- [ ] School app certificate has `iot:Receive` permission for `pace/transport/bus/*`
- [ ] Transporter app certificate has `iot:Publish` permission for `pace/transport/bus/*`
- [ ] Policy resource ARNs use correct region (`ap-south-1`)
- [ ] Policy uses `topicfilter` for Subscribe, `topic` for Receive/Publish

## Additional Notes

- Policy changes take effect immediately (no restart needed)
- You can test policies using AWS IoT Core Test feature
- Check CloudWatch logs for AWS IoT Core to see if messages are being rejected

