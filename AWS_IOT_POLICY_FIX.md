# AWS IoT Core Policy Fix - School App Not Receiving MQTT Messages

## 🔴 CRITICAL ISSUE IDENTIFIED

**Problem**: School app subscribes successfully but receives **ZERO messages** even though:
- ✅ Connection is active
- ✅ Subscription is confirmed (both exact and wildcard)
- ✅ Transporter app is publishing successfully
- ✅ Topics match exactly

**Root Cause**: **AWS IoT Core Policy Missing `iot:Receive` Permission**

## 📋 Current Status

From the logs:
- Both subscriptions confirmed: `pace/transport/bus/299` and `pace/transport/bus/+`
- Connection state: `MqttConnectionState.connected`
- Messages received: **0** (this is the problem!)

## 🔧 REQUIRED FIX: Update AWS IoT Core Policy

### Step 1: Access AWS IoT Core Console

1. Go to [AWS IoT Core Console](https://console.aws.amazon.com/iot/)
2. Navigate to **Security** → **Certificates**
3. Find the certificate used by the **school app**
4. Click on the certificate → Go to **Policies** tab

### Step 2: Check Current Policy

Review the policy attached to the school app certificate. It likely has:
- ✅ `iot:Connect` - Allows connection
- ✅ `iot:Subscribe` - Allows subscription
- ❌ **MISSING** `iot:Receive` - **This is why no messages are received!**

### Step 3: Update Policy

Add the `iot:Receive` permission. Here's the complete policy needed:

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
        "arn:aws:iot:ap-south-1:*:topic/pace/transport/bus/*"
      ]
    }
  ]
}
```

### Step 4: Key Points

1. **Use `topicfilter` for Subscribe**: `arn:aws:iot:ap-south-1:*:topicfilter/...`
2. **Use `topic` for Receive**: `arn:aws:iot:ap-south-1:*:topic/...`
3. **Region must match**: `ap-south-1` (Mumbai)
4. **Wildcard in Resource**: Use `pace/transport/bus/*` to allow all bus topics

### Step 5: Verify Transporter App Policy

Also check the transporter app's certificate policy has:

```json
{
  "Effect": "Allow",
  "Action": [
    "iot:Publish"
  ],
  "Resource": [
    "arn:aws:iot:ap-south-1:*:topic/pace/transport/bus/*"
  ]
}
```

## 🧪 Testing After Fix

1. **Update the policy** in AWS IoT Core Console
2. **No app restart needed** - policy changes take effect immediately
3. **Check school app logs** for:
   - `📨 [MQTT] Raw message batch received` ← This should appear!
   - `✅ [MQTT] Processing message for subscribed topic`

## 📊 Expected Log Output After Fix

You should see:
```
[log] 📨 [MQTT] Raw message batch received with 1 message(s)
[log] 📨 [MQTT] Processing message 0 of 1
[log] 📨 [MQTT] Message topic: pace/transport/bus/299
[log] ✅ [MQTT] Processing message for subscribed topic
[log] 📊 [MQTT] Total messages received: 1
```

## 🔍 Why This Happens

AWS IoT Core requires **three separate permissions**:
1. **`iot:Connect`** - To establish connection ✅ (you have this)
2. **`iot:Subscribe`** - To subscribe to topics ✅ (you have this)
3. **`iot:Receive`** - To actually receive messages ❌ (you're missing this!)

Without `iot:Receive`, the subscription succeeds but messages are silently dropped by AWS IoT Core.

## 🚨 Common Mistakes

1. **Wrong Resource Type**: Using `topicfilter` for Receive (should be `topic`)
2. **Missing Wildcard**: Not including `/*` in resource ARN
3. **Region Mismatch**: Using wrong region in ARN
4. **Too Restrictive**: Policy only allows specific topic, not wildcard

## ✅ Verification Checklist

- [ ] Policy includes `iot:Receive` action
- [ ] Resource uses `topic` (not `topicfilter`) for Receive
- [ ] Resource ARN includes wildcard: `pace/transport/bus/*`
- [ ] Region is correct: `ap-south-1`
- [ ] Policy is attached to school app certificate
- [ ] Transporter app has `iot:Publish` permission

## 📝 Additional Notes

- Policy changes are **immediate** (no restart needed)
- Check AWS CloudWatch logs for IoT Core to see rejected operations
- You can test policies using AWS IoT Core Test feature in console
- If still not working after fix, check CloudWatch for error messages

## 🆘 Still Not Working?

If messages still don't arrive after adding `iot:Receive`:

1. **Check CloudWatch Logs**: Look for rejected operations
2. **Verify Certificate**: Ensure correct certificate is attached
3. **Test with AWS IoT Test**: Use console test feature to verify policy
4. **Check Network**: Ensure no firewall blocking MQTT traffic
5. **Verify Topic**: Double-check topic name matches exactly

