// Licensed under the MIT License.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_crowdin/otel_crowdin.dart';

/// Traces Crowdin calls with OpenTelemetry.
///
/// `otel_crowdin` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Crowdin call in
/// [tracedCrowdin]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'crowdin-example');

  // Wraps a Crowdin API call in a CLIENT span.
  final crowdinId = await tracedCrowdin<String>(
    operation: 'projects.create',
    invoke: () async {
      // Make the Crowdin call here, then report what it returned.
      const id = 'crowdin_8f3a2c';
      return const CrowdinCallResult(
          value: id,
          result: CrowdinResult(
              organization: '{org}.crowdin.com',
              projectId: 'project_8f3a2c',
              projectVisibility: 'open',
              entityKind: 'project',
              entityId: 'entity_8f3a2c',
              fileId: 'file_8f3a2c',
              fileType: 'auto',
              branchId: 'branch_8f3a2c',
              targetLanguageId: 'fr-FR',
              stringsTotal: 1,
              translatedProgress: 1,
              approvedProgress: 1,
              mtEngineId: 'mtengine_8f3a2c',
              mtCharsConsumed: 1,
              tasksId: 'tasks_8f3a2c',
              tasksStatus: 'todo',
              workflowStepId: 'workflowstep_8f3a2c',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedCrowdin projects.create returned $crowdinId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutCrowdinInstrumentationAsync.
  await runWithoutCrowdinInstrumentationAsync(
    () => tracedCrowdin<String>(
      operation: 'projects.create',
      invoke: () async {
        const id = 'crowdin_8f3a2c';
        return const CrowdinCallResult(
            value: id,
            result: CrowdinResult(
                organization: '{org}.crowdin.com',
                projectId: 'project_8f3a2c',
                projectVisibility: 'open',
                entityKind: 'project',
                entityId: 'entity_8f3a2c',
                fileId: 'file_8f3a2c',
                fileType: 'auto',
                branchId: 'branch_8f3a2c',
                targetLanguageId: 'fr-FR',
                stringsTotal: 1,
                translatedProgress: 1,
                approvedProgress: 1,
                mtEngineId: 'mtengine_8f3a2c',
                mtCharsConsumed: 1,
                tasksId: 'tasks_8f3a2c',
                tasksStatus: 'todo',
                workflowStepId: 'workflowstep_8f3a2c',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
