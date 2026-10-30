import 'dart:io';
import 'package:backend/src/server.dart';
import 'package:backend/src/shared/partner_database.dart';
import 'package:backend/src/workers/partner_webhook_worker.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:supabase/supabase.dart';

void main(List<String> args) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((rec) {
    stdout.writeln('[${rec.level.name}] ${rec.time}: ${rec.message}');
  });

  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final paystackSecret = Platform.environment['PAYSTACK_SECRET_KEY'];
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];

  PartnerDatabase? partnerDb;
  PartnerWebhookWorker? webhookWorker;

  if (supabaseUrl != null &&
      supabaseUrl.isNotEmpty &&
      serviceRoleKey != null &&
      serviceRoleKey.isNotEmpty) {
    partnerDb = SupabasePartnerDatabase(
      supabaseUrl: supabaseUrl,
      serviceRoleKey: serviceRoleKey,
    );
    final supabaseClient = SupabaseClient(supabaseUrl, serviceRoleKey);
    webhookWorker = PartnerWebhookWorker(supabaseClient: supabaseClient);
    webhookWorker.start();
    stdout.writeln('⚡ Partner Webhook Worker active and polling outbox.');
  } else {
    stdout.writeln('ℹ️  Running with in-memory partner database (SUPABASE_URL not configured).');
  }

  final handler = createServerHandler(
    paystackSecretKey: paystackSecret,
    partnerDatabase: partnerDb,
  );
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  stdout.writeln('⚡ Go-Volts API server listening on http://${server.address.host}:${server.port}');
  stdout.writeln('⚡ Health check: http://${server.address.host}:${server.port}/health');

  ProcessSignal.sigint.watch().listen((_) {
    stdout.writeln('\n🛑 Shutting down server gracefully...');
    webhookWorker?.stop();
    server.close().then((_) => exit(0));
  });
}
