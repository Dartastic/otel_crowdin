// Licensed under the MIT License.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_crowdin_suppression.dart';

const _tracerName = 'dartastic_otel_libs_crowdin';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class CrowdinResult {
  const CrowdinResult({
    this.organization,
    this.projectId,
    this.projectVisibility,
    this.entityKind,
    this.entityId,
    this.fileId,
    this.fileType,
    this.branchId,
    this.targetLanguageId,
    this.stringsTotal,
    this.translatedProgress,
    this.approvedProgress,
    this.mtEngineId,
    this.mtCharsConsumed,
    this.tasksId,
    this.tasksStatus,
    this.workflowStepId,
    this.statusCode,
  });

  /// Crowdin Enterprise organization subdomain (`{org}.crowdin.com`).
  /// Null on crowdin.com (single-tenant).
  final String? organization;

  final String? projectId;

  /// `open` / `private` / `enterprise` — affects who can see strings.
  final String? projectVisibility;

  /// `project` / `file` / `directory` / `branch` / `string` /
  /// `translation` / `string_translation` / `screenshot` / `glossary`
  /// / `tm` / `task` / `workflow_step` / `report` / `bundle` /
  /// `vendor` / `webhook` / `mt_engine`.
  final String? entityKind;

  final String? entityId;

  final String? fileId;

  /// `auto` / `android` / `ios` / `arb` / `json` / `xml` / `csv` /
  /// `xliff` / `yaml` / `properties` / `gettext` / `flutter_arb` /
  /// `web_xml` / `srt` / `vtt` / `xlsx` / `webxml` / `dart`.
  final String? fileType;

  final String? branchId;

  /// Target locale id (`fr-FR`, `de-DE`, etc).
  final String? targetLanguageId;

  /// Project-level string count.
  final int? stringsTotal;

  /// Per-language progress percentages (0-100).
  final int? translatedProgress;
  final int? approvedProgress;

  /// MT engine id used (Crowdin supports DeepL/Microsoft/Google/Yandex
  /// /Tencent/ModernMT/Amazon Translate/custom).
  final String? mtEngineId;

  /// Characters run through MT (Crowdin Enterprise meters MT by
  /// character).
  final int? mtCharsConsumed;

  final String? tasksId;

  /// `todo` / `in_progress` / `done` / `closed`.
  final String? tasksStatus;

  /// Active workflow step id (translate / proofread / etc).
  final String? workflowStepId;

  final int? statusCode;
}

class CrowdinCallResult<T> {
  const CrowdinCallResult({required this.value, this.result});
  final T value;
  final CrowdinResult? result;
}

/// Wraps a Crowdin API call in a CLIENT span. [operation] is one of
/// `projects.list`, `projects.create`, `files.list`, `files.upload`,
/// `files.download`, `branches.create`, `strings.list`,
/// `strings.create`, `string_translations.create`,
/// `translations.bulk_upload`, `tasks.create`, `mt.translate`,
/// `glossaries.create`, `tm.export`, `reports.generate`,
/// `webhooks.create`.
Future<T> tracedCrowdin<T>({
  required String operation,
  required Future<CrowdinCallResult<T>> Function() invoke,
}) async {
  if (crowdinInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'crowdin',
    'rpc.method': operation,
    'crowdin.operation': operation,
  };

  final span = _tracer().startSpan(
    'crowdin $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.organization != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.organization',
          r.result!.organization!,
        ));
      }
      if (r.result!.projectId != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.project.id',
          r.result!.projectId!,
        ));
      }
      if (r.result!.projectVisibility != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.project.visibility',
          r.result!.projectVisibility!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.fileId != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.file.id',
          r.result!.fileId!,
        ));
      }
      if (r.result!.fileType != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.file.type',
          r.result!.fileType!,
        ));
      }
      if (r.result!.branchId != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.branch.id',
          r.result!.branchId!,
        ));
      }
      if (r.result!.targetLanguageId != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.target_language.id',
          r.result!.targetLanguageId!,
        ));
      }
      if (r.result!.stringsTotal != null) {
        extras.add(OTelAPI.attributeInt(
          'crowdin.strings.total',
          r.result!.stringsTotal!,
        ));
      }
      if (r.result!.translatedProgress != null) {
        extras.add(OTelAPI.attributeInt(
          'crowdin.progress.translated',
          r.result!.translatedProgress!,
        ));
      }
      if (r.result!.approvedProgress != null) {
        extras.add(OTelAPI.attributeInt(
          'crowdin.progress.approved',
          r.result!.approvedProgress!,
        ));
      }
      if (r.result!.mtEngineId != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.mt.engine_id',
          r.result!.mtEngineId!,
        ));
      }
      if (r.result!.mtCharsConsumed != null) {
        extras.add(OTelAPI.attributeInt(
          'crowdin.mt.chars_consumed',
          r.result!.mtCharsConsumed!,
        ));
      }
      if (r.result!.tasksId != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.task.id',
          r.result!.tasksId!,
        ));
      }
      if (r.result!.tasksStatus != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.task.status',
          r.result!.tasksStatus!,
        ));
      }
      if (r.result!.workflowStepId != null) {
        extras.add(OTelAPI.attributeString(
          'crowdin.workflow_step.id',
          r.result!.workflowStepId!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Crowdin HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
