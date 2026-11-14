class ParsedQrPayment {
  final String recipient;
  final String payeeName;
  final double? amount;
  final String? note;
  final String raw;

  ParsedQrPayment({
    required this.recipient,
    required this.payeeName,
    this.amount,
    this.note,
    required this.raw,
  });

  factory ParsedQrPayment.parse(String raw) {
    final text = raw.trim();

    // 1. Standard UPI Scheme: upi://pay?pa=...&pn=...&am=...&tn=...
    if (text.toLowerCase().startsWith('upi://pay') || text.toLowerCase().contains('pa=')) {
      try {
        final uri = Uri.parse(text);
        final pa = uri.queryParameters['pa'] ?? '';
        final pn = uri.queryParameters['pn'];
        final am = uri.queryParameters['am'];
        final tn = uri.queryParameters['tn'];

        if (pa.isNotEmpty) {
          final decodedName = pn != null && pn.isNotEmpty
              ? Uri.decodeComponent(pn.replaceAll('+', ' '))
              : (pa.contains('@') ? pa.split('@').first.toUpperCase() : pa);

          final parsedAmt = am != null ? double.tryParse(am) : null;
          final decodedNote = tn != null ? Uri.decodeComponent(tn.replaceAll('+', ' ')) : null;

          return ParsedQrPayment(
            recipient: pa,
            payeeName: decodedName,
            amount: parsedAmt,
            note: decodedNote,
            raw: text,
          );
        }
      } catch (_) {}
    }

    // 2. JSON Format: {"pa": "...", "am": "..."} or {"recipient": "...", ...}
    if (text.startsWith('{') && text.endsWith('}')) {
      try {
        final paMatch = RegExp(r'"(?:pa|recipient|to|receiver)"\s*:\s*"([^"]+)"').firstMatch(text);
        final pnMatch = RegExp(r'"(?:pn|name|payee)"\s*:\s*"([^"]+)"').firstMatch(text);
        final amMatch = RegExp(r'"(?:am|amount)"\s*:\s*([0-9.]+)').firstMatch(text);
        final tnMatch = RegExp(r'"(?:tn|note|description)"\s*:\s*"([^"]+)"').firstMatch(text);

        if (paMatch != null) {
          final pa = paMatch.group(1)!;
          final pn = pnMatch?.group(1) ?? (pa.contains('@') ? pa.split('@').first.toUpperCase() : pa);
          final am = amMatch != null ? double.tryParse(amMatch.group(1)!) : null;
          final tn = tnMatch?.group(1);

          return ParsedQrPayment(
            recipient: pa,
            payeeName: pn,
            amount: am,
            note: tn,
            raw: text,
          );
        }
      } catch (_) {}
    }

    // 3. Phone Number: 10 digits or 12 digits (+91)
    final cleanDigits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if ((cleanDigits.length == 10 || (cleanDigits.length == 12 && cleanDigits.startsWith('91'))) && !text.contains('@')) {
      final phone = cleanDigits.length == 12 ? cleanDigits.substring(2) : cleanDigits;
      return ParsedQrPayment(
        recipient: '$phone@upi',
        payeeName: 'Mobile Contact (+91 $phone)',
        raw: text,
      );
    }

    // 4. Email or UPI Handle (contains @)
    if (text.contains('@')) {
      final cleanHandle = text.replaceAll(RegExp(r'\s+'), '');
      return ParsedQrPayment(
        recipient: cleanHandle,
        payeeName: cleanHandle.split('@').first.toUpperCase(),
        raw: text,
      );
    }

    // 5. Fallback for account numbers or plain identifiers (e.g. DC-BOB-001)
    return ParsedQrPayment(
      recipient: text,
      payeeName: text,
      raw: text,
    );
  }
}
