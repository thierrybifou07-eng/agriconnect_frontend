import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/agent/data/demo_agent_repository.dart';
import 'package:agri_connect/features/agent/domain/agent_repository.dart';

/// Entry point of the agent data layer; overridden by tests.
final agentRepositoryProvider = Provider<AgentRepository>(
  (ref) => DemoAgentRepository(),
);
