# Refactor & Method Split Roadmap (WIP)

Canonical Scope: engine/src modules already under test. Objective: increase unit isolation & test depth without altering external behavior. Each suggestion lists: Current Pain, Proposed Split(s), Test Opportunities, Priority, Risk, Effort.

Legend:
- Priority: 🔴 High (unblocks coverage), 🟡 Medium (incremental), 🟢 Low (opportunistic)
- Effort: XS (<10 LOC), S (10–30), M (30–80), L (80+)
- Risk: Low (pure extraction), Med (order/side effects), High (shared mutable state)

---
## 1. low/action.py (TAction)
### 1.1 `__init__`
Current Pain: Mixed concerns (parent wiring, table instantiation, dependency graph setup, logging).
Proposed Splits:
- `_init_parent(parent)` (XS, Low)
- `_init_table(args_yaml)` (S, Med) – isolates table_config handling.
- `_log_initialization()` (XS, Low) – centralize logging string.
Test Opportunities:
- Add test to assert table created only when `table` key present.
- Add test for propagation of description to table.
Priority: 🟡  Effort: S  Risk: Low

### 1.2 `execute_sql`
Current Pain: 150+ lines (validation, execution, schema, logging). Hard to force specific branches.
Proposed Splits:
- `_preflight_checks()` -> returns (ok: bool, reason:str) (S, Low)
- `_prepare_and_execute_table()` -> returns exec_result (S, Med)
- `_handle_exec_result(exec_result)` -> bool (XS, Low)
- `_run_schema_validation()` wrapper calling `validate_schema` (XS, Low)
- `_log_execution_start()` (XS, Low)
Refactor Flow: execute_sql calls helpers sequentially with early returns.
Test Opportunities:
- Unit test `_preflight_checks` via monkeypatching minimal table.
- Force failure in `_prepare_and_execute_table` by raising inside `table.prepare_sql`.
Priority: 🔴  Effort: M  Risk: Med

### 1.3 `validate_schema`
Current Pain: Inline query building, type mapping, mismatch loop.
Proposed Splits:
- `_fetch_schema_metadata()` -> dict[column->type] (S, Med)
- `_expected_column_types()` -> dict (XS, Low)
- `_validate_types(column_types, expected)` -> returns mismatch_count (S, Low)
- `_log_schema_results(mismatch_count)` (XS, Low)
Test Opportunities:
- Mock `_fetch_schema_metadata` to simulate mismatch.
- Directly test `_validate_types` pure function.
Priority: 🟡 Effort: S Risk: Low

---
## 2. low/table.py (TTable)
Focus Targets (long, branchy methods): `__init__`, `prepare_sql`, `execute_sql`, `_process_python_source`, `_execute_sql_processing_pipeline`, `generate_sql_from_sql_template`, `generate_sql_code_for_union_details`.

### 2.1 `__init__`
Splits:
- `_parse_schema_table(raw)` (S, Low) – returns (schema, table) or raises.
- `_load_world(parent)` (XS, Low) – encapsulates TWorld lookup.
- `_validate_numeric_params()` (XS, Low)
- `_collect_source_flags(args_yaml)` -> dataclass (M, Med)
- `_log_active_sources(active_sources)` (XS, Low)
Test Gains:
- Pure tests for `_parse_schema_table` invalid cases.
- Mock parent to test `_load_world` fallback.
Priority: 🟡 Effort: M Risk: Med

### 2.2 `prepare_sql`
Current: Multi-stage pipeline; each numbered stage convertible to helper; adds clarity & isolate failure tests.
Splits (1:1 with comments):
- `_stage_schema_creation()`
- `_stage_validate_sources()`
- `_stage_sql_reference()`
- `_stage_direct_sql()`
- `_stage_union_details()`
- `_stage_template()`
- `_stage_sql_file()`
- `_stage_param_replacement(sql_code)` -> returns mutated code
- `_stage_finalize(sql_code)` -> sets dependencies
All helpers return updated sql_code (or early signals). Main reduces to linear composition.
Tests:
- Each stage individually monkeypatched to raise -> ensure main logs & returns ''.
- Param replacement unit test for non-matching param warns.
Priority: 🔴 Effort: L Risk: Med

### 2.3 `execute_sql`
Splits:
- `_phase_initialize_environment()`
- `_phase_acquire_data(output_path)`
- `_phase_file_ops(output_path)`
- `_phase_create_view(final_file)`
- `_phase_update_ui()`
Return early detection simplifies branch coverage.
Priority: 🔴 Effort: M Risk: Low

### 2.4 `_process_python_source`
Splits:
- `_resolve_python_script()` -> (file, fn)
- `_execute_python_script_wrapper(file, fn, params)` (delegate existing)
- `_validate_python_result(result)`
Priority: 🟡 Effort: S Risk: Low

### 2.5 `_execute_sql_processing_pipeline`
Splits:
- `_sql_pipeline_materialize_temp()`
- `_sql_pipeline_transform()`
- `_sql_pipeline_write_parquet()`
Priority: 🟡 Effort: M Risk: Med

### 2.6 `generate_sql_from_sql_template`
Splits:
- `_load_template_source()`
- `_render_template(template_str)`
- `_post_process_rendered_sql(sql)`
Priority: 🟢 Effort: S Risk: Low

### 2.7 `generate_sql_code_for_union_details`
Splits:
- `_iter_union_entries()` -> yields entries
- `_render_union_entry(entry)`
- `_finalize_union_query(parts)`
Priority: 🟢 Effort: S Risk: Low

---
## 3. high/indicator.py (TIndicator)
Target big blocks: `__init__`, `_init_components`, `indicator_execute`, `collect_components`, `collect_column_formatting`, `collect_dependencies`, `process_docs`, backup/restore trio.

### 3.1 `__init__`
Splits:
- `_init_basic_fields(args_yaml)`
- `_derive_paths(full_path, spec_path, db_path)`
- `_load_reference_paths(args_yaml)`
- `_resolve_practice(args_yaml)`
- `_init_report_meta(args_yaml)`
- `_init_component_containers()`
- `_load_formatting_and_charts(args_yaml)`
- `_apply_macros(args_yaml)`
- `_final_bootstrap(args_yaml)` (directories + components + sql ref)
Priority: 🔴 Effort: L Risk: Med
Tests: Each helper individually patch to raise to assert partial failure logging; new tests for missing practice raising ValueError.

### 3.2 `_init_components`
Splits by component type:
- `_init_actions(args)`
- `_init_symptoms(args)`
- `_init_snapshots(args)`
- `_init_trends(args)`
- `_init_stylers(args)`
Priority: 🟡 Effort: M Risk: Low

### 3.3 `collect_components`
Current inner nested rank logic.
Splits:
- `_assign_ranks(component_collection, current_rank)` (extract inner function)
Priority: 🟢 Effort: XS Risk: Low

### 3.4 `indicator_execute`
Likely large orchestration; split into:
- `_execute_component_group(component_dict, label)`
- `_post_execution_reporting()`
Priority: 🟡 Effort: M Risk: Med

### 3.5 `collect_column_formatting`
Splits:
- `_normalize_format_entry(formatting_entry)`
- `_merge_format_entry(column_name, formatting_entry)` (extract inner add_formatting_entry)
Priority: 🟢 Effort: S Risk: Low

### 3.6 `collect_dependencies`
Extract local helper `_ensure_table_deps` already inline; formalize & add unit test for scenario: missing table -> no crash.
Priority: 🟢 Effort: XS Risk: Low

### 3.7 Docs & Backup Group
- `process_docs` -> `_load_reference_docs()`, `_write_data_markdown()`, `_write_formats_yaml()`
- `backup_indicator` & `restore_indicator` -> factor shared path enumeration `_iter_trend_files(filter)`
Priority: 🟡 Effort: M Risk: Low

---
## 4. model/world.py (TWorld)
Focus: `process_args_params`, `init_BIS_engine`, `scan_folder_and_load_jobs`.

### 4.1 `process_args_params`
Splits:
- `_extract_base_cli_params(args_yaml)`
- `_configure_base_paths()`
- `_apply_remote_overrides()`
- `_derive_secondary_paths()`
Priority: 🟡 Effort: M Risk: Low
Tests: Param subset injection to assert each stage updates expected attributes.

### 4.2 `scan_folder_and_load_jobs`
Splits:
- `_gather_job_files(path_to_scan)`
- `_load_single_job(full_path)` (existing inner)
- `_register_job(data, path)`
Priority: 🔴 Effort: M Risk: Med
Tests: Simulate missing file, malformed YAML, duplicate registration.

### 4.3 `init_BIS_engine`
Splits:
- `_pre_clear_and_process_args(args_yaml)`
- `_load_engine_configs()`
- `_final_mode_dispatch()`
Priority: 🟡 Effort: S Risk: Low

---
## 5. model/pipeline.py (TPipeline)
Targets: `run_pipeline`, `start_ELT_config`, extraction methods repetition.

### 5.1 `run_pipeline`
Split into:
- `_iter_pipeline_functions()` (generator over configured functions) 
- `_execute_single_function(name, args)` returns success/bubble exception
- `_log_pipeline_summary(executed, total)`
Priority: 🟡 Effort: S Risk: Low
Tests: Inject fake function raising exception to verify global counter increment remains.

### 5.2 Repeated extraction patterns (`run_extract_*`)
Introduce template method:
- `_run_generic_extraction(kind:str, args, extract_callable)` handles connect/log/close.
Refactor each method to call generic.
Priority: 🟢 Effort: M Risk: Med
Tests: Parametrized test verifying log lines and DS.close invocation under exception.

---
## 6. tool/utils.py
File is very large (3k+ LOC). Initial thin-slice refactors around pure functions for fast coverage gains.

### 6.1 Candidate Groupings
- File Age / Skipping: group into class `FileAgeChecker` (pure wrappers) – low risk.
- Time Constants: move computed datetime block into function `init_time_constants(now=None)` returning struct for easier freeze tests.
- CSV SQL Generation: split `read_csv_sql` into `_build_read_params`, `_apply_replacements`, `_filename_date_expression`, `_compose_query`.
Priority: 🔴 (CSV path used widely) Effort: M Risk: Med
Tests: Unit tests around each helper with deterministic inputs (no filesystem).

### 6.2 Logging wrappers
Add `_log_info(msg)` / `_log_warning(msg)` local helpers to reduce repetition (optional later).
Priority: 🟢 Effort: XS Risk: Low

---
## 7. Cross-Cutting Test Additions (After Splits)
| Module | New Helper | Test Type | Notes |
|--------|------------|-----------|-------|
| TAction |_preflight_checks | unit pure-ish | Force each early-return branch |
| TAction |_prepare_and_execute_table | mock table methods | Raise on prepare vs execute |
| TTable  |_stage_param_replacement | param logic test | Missing param warning |
| TTable  |_stage_sql_file | file missing case | Ensure logs & '' |
| TIndicator |_init_actions | count objects | Provide minimal args |
| TIndicator |_assign_ranks | deterministic order | Provide 2 components with same rank |
| TWorld |_gather_job_files | simulate temp dir | Empty vs populated |
| TPipeline |_execute_single_function | mock raising function | Increment error counter |
| utils.read_csv_sql |_filename_date_expression | pure output assertion | Different prefixes |

---
## 8. Suggested Execution Order (Incremental PRs)
1. Small low-risk extractions in `TAction` & `read_csv_sql` (fast safety net) 🔴
2. Stage-based refactor of `TTable.prepare_sql` 🔴
3. Indicator initialization breakdown (highest complexity) 🔴
4. World job scanning split 🟡
5. Pipeline generic extraction method 🟡
6. Remaining medium splits (backup/docs, python source, sql pipeline) 🟢
7. Larger grouping (utils constants struct) 🟢

---
## 9. Metrics & Success Criteria
- Maintain existing test pass & coverage never decreases per PR.
- Each extraction introduces ≥1 new direct unit test for new helper.
- Cyclomatic complexity reduction: target 20% drop for `prepare_sql` & `indicator.__init__`.
- Increase line coverage by +2% cumulative after phases 1–3.

---
## 10. Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| Hidden side-effects in long methods | Keep original public method orchestration & compare logs in tests |
| Over-refactor causing churn | Batch helpers logically & keep naming consistent with existing comments |
| Flaky time-based tests after moving constants | Provide injectable `now` arg |
| SQL template behavior change | Golden-file style assertion pre/post refactor for one complex spec |

---
## 11. Next Immediate Actions
1. Pick Phase 1 subset (TAction execute_sql helpers + read_csv_sql helpers).
2. Create dedicated test file `engine/test/test_low/test_action_internal.py` for new helpers.
3. Ratchet coverage to 25 once Phase 1 merged.

---
(End of WIP document)
