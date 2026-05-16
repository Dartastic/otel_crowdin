// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_crowdin/otel_crowdin.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_crowdin-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('files.upload records project + file type + branch', () async {
    await tracedCrowdin<String>(
      operation: 'files.upload',
      invoke: () async => const CrowdinCallResult(
        value: 'ok',
        result: CrowdinResult(
          organization: 'acme',
          projectId: 'proj_1',
          projectVisibility: 'enterprise',
          fileId: 'f_1',
          fileType: 'flutter_arb',
          branchId: 'br_1',
          stringsTotal: 1200,
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('crowdin files.upload')!);
    expect(a['crowdin.organization'], 'acme');
    expect(a['crowdin.project.visibility'], 'enterprise');
    expect(a['crowdin.file.type'], 'flutter_arb');
    expect(a['crowdin.strings.total'], 1200);
  });

  test('mt.translate records engine + chars consumed', () async {
    await tracedCrowdin<String>(
      operation: 'mt.translate',
      invoke: () async => const CrowdinCallResult(
        value: 'ok',
        result: CrowdinResult(
          targetLanguageId: 'de-DE',
          mtEngineId: 'deepl_1',
          mtCharsConsumed: 18500,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('crowdin mt.translate')!);
    expect(a['crowdin.target_language.id'], 'de-DE');
    expect(a['crowdin.mt.engine_id'], 'deepl_1');
    expect(a['crowdin.mt.chars_consumed'], 18500);
  });

  test('progress fields surface', () async {
    await tracedCrowdin<String>(
      operation: 'reports.generate',
      invoke: () async => const CrowdinCallResult(
        value: 'ok',
        result: CrowdinResult(
          targetLanguageId: 'fr-FR',
          translatedProgress: 92,
          approvedProgress: 78,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('crowdin reports.generate')!);
    expect(a['crowdin.progress.translated'], 92);
    expect(a['crowdin.progress.approved'], 78);
  });

  test('suppression skips spans', () async {
    await runWithoutCrowdinInstrumentationAsync(() async {
      await tracedCrowdin<String>(
        operation: 'projects.list',
        invoke: () async => const CrowdinCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('crowdin '), isEmpty);
  });
}
