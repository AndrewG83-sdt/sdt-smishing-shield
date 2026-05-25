# SDT Smishing Shield

SDT Smishing Shield is a mobile-first Flutter cybersecurity app for local smishing, phishing, scam, and social engineering risk assessment. It can analyze screenshots from SMS, WhatsApp, email, or social media direct messages, extract text with on-device OCR, classify the risk, explain detected indicators, suggest safe action, generate a safe reply, and save previous analyses locally.

The app never claims 100% certainty. It uses three risk levels only:

- LOW RISK
- SUSPICIOUS
- HIGH RISK

## Features

- Screenshot selection from gallery
- Local OCR using `google_mlkit_text_recognition`
- Manual text analysis
- Local rule-based risk engine
- Weighted risk score from 0 to 100
- Detected indicator chips
- Clear explanation and safe action guidance
- Safe reply suggestion with copy action
- Local SQLite history with delete single and delete all actions
- Text report export
- Premium dark Apple-style interface with frosted cards, refined spacing, and risk color system

## Install dependencies

Install Flutter, then run:

```bash
flutter pub get
```

If platform folders are not present yet, initialize them with Flutter:

```bash
flutter create .
flutter pub get
```

## Run the app

```bash
flutter run
```

For iOS, open the generated iOS project in Xcode if signing is required. For Android, make sure an emulator or device is connected.

## Privacy model

SDT Smishing Shield is designed as a privacy-first, local-only app:

- Screenshots are processed on the device.
- OCR runs locally through an on-device OCR library.
- Message analysis is rule-based and local.
- Analysis history is stored only in SQLite on the device.
- No cloud backend is included.
- No external model API is used.
- No paid APIs are used.
- No ads or user tracking are included.

## Local-only processing

The application does not upload screenshots, extracted text, or analysis results to external servers. Exporting a report is user-initiated and uses the device share sheet.

## Risk scoring model

The local risk engine assigns weighted points for scam indicators:

- Request for password: +40
- Request for OTP: +45
- Shortened URL: +25
- Suspicious domain: +30
- Urgent threat: +20
- Payment request: +20
- Unknown sender: +10
- Brand impersonation: +25
- Grammatical anomalies: +10
- Account suspension threat: +25
- Fake delivery message: +20
- Request for bank details: +45
- Link click request: +20

Classification:

- 0-29: LOW RISK
- 30-59: SUSPICIOUS
- 60-100: HIGH RISK

## Limitations

This tool supports risk assessment but does not guarantee absolute detection. Rule-based detection may miss new scam patterns, messages in unsupported languages, image-only scams, QR-code scams, or attacks with clean grammar and no obvious trigger phrases. Users should always verify sensitive requests through official channels.

## Future improvements

- Offline LLM integration
- Local URL reputation database
- Domain age analysis
- QR code scam detection
- Multilingual detection
- PDF report export
- Desktop OSINT dashboard integration
- Local threat intelligence feed
- Browser extension companion
