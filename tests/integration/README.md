# Integration Tests

## Goal / Purpose

The Integration folder contains integration test suites that verify how different game systems work together. These tests validate system interactions across layers (Geoscape ↔ Basescape ↔ Battlescape).

## Content

- Cross-system integration tests
- Gameplay flow tests
- State transition tests
- Data consistency tests
- Multi-system interaction tests

## Features

- **System Integration**: Test system interactions
- **Data Flow**: Verify data between systems
- **State Management**: Test state transitions
- **Campaign Flow**: Complete gameplay progression
- **Edge Cases**: Complex scenario testing

## Test Scenarios

- **Geoscape → Battlescape**: Mission start and completion
- **Battlescape → Basescape**: Results affecting base
- **Basescape → Geoscape**: Research unlocking missions
- **Economy**: Resource flow between systems
- **Campaign**: Full phase progression
- **Complex Workflows**: Multi-step game operations

## Running Tests

```bash
lovec tests/runners integration
```

## Test Development

When adding integration tests:
1. Plan the scenario
2. Set up initial state
3. Execute multi-system operations
4. Verify final state
5. Check data consistency
6. Test edge cases

## See Also

- [Tests README](../README.md) - Testing overview
- [Test Development Guide](../TEST_DEVELOPMENT_GUIDE.md) - How to write tests
- [Architecture](../../architecture/README.md) - System integration patterns
- [Integration Flow](../../architecture/INTEGRATION_FLOW_DIAGRAMS.md) - System flows
