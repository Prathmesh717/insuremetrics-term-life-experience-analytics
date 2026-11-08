# InsureMetrics – Term-Life Insurance Experience & Portfolio Analytics Engine

# Governance Checklist

**Document Version:** 2.1  
**Document Status:** Portfolio Demonstration – Self-Review  
**Project:** InsureMetrics  
**Observation Period:** 1 January 2021 – 31 December 2025  
**Dataset:** Synthetic term-life insurance portfolio (20,000 policies)  
**Technology Stack:** Python, PostgreSQL 16, SQL, Streamlit, Docker  
**Document Owner:** Project Author  
**Repository Location:** `docs/Governance_Checklist.md`

---

## 1. Purpose

This Governance Checklist defines the controls and review procedures used to assess the reliability, consistency, traceability, and appropriate use of the InsureMetrics analytics platform.

The checklist establishes a structured approach to reviewing:

- Source data quality and completeness.
- Policy, claims, and assumption data integrity.
- Exposure calculations and segmentation.
- Mortality and lapse calculations.
- Statistical methodology and credibility adjustments.
- SQL validation controls and reconciliation.
- Dashboard reporting and business interpretation.
- Documentation, evidence, limitations, and approval requirements.

The purpose is to demonstrate sound data governance, analytical controls, quality assurance, and business review practices within a portfolio project.

This checklist does not constitute an independent actuarial audit, regulatory certification, production model validation, or formal actuarial approval.

## 2. Governance Objectives

The governance framework aims to:

1. Establish traceability from source data to analytical outputs.
2. Verify the completeness and consistency of policy and claims data.
3. Confirm that mortality and lapse assumptions are appropriately matched.
4. Validate exposure calculations and policy-period boundaries.
5. Reconcile actual and expected experience measures.
6. Review credibility calculations and recommendation classifications.
7. Maintain evidence for executed controls and identified exceptions.
8. Ensure that analytical limitations and synthetic-data disclosures remain visible.
9. Define responsibilities for review, approval, and issue resolution.
10. Distinguish project-author self-review from independent external review.

## 3. Governance Scope

### 3.1 In Scope

| Governance Area | Scope |
|---|---|
| Data Governance | Synthetic source data, completeness, uniqueness, validity, and consistency |
| Data Integrity | Policy, claims, product, and assumption relationships |
| Exposure Governance | Policy duration, calendar-year boundaries, anniversaries, and leap-year handling |
| Mortality Analytics | Actual deaths, expected deaths, expected claim amounts, and A/E analysis |
| Lapse Analytics | Voluntary lapse events, expected lapse, and competing termination treatment |
| Statistical Governance | Confidence intervals, credibility calculations, and recommendation thresholds |
| Technical Controls | SQL validation, reconciliation, and automated test execution |
| Reporting Governance | Dashboard consistency, metric definitions, and synthetic-data disclosure |
| Documentation | Methodology, data dictionary, limitations, BRD, and UAT documentation |
| Review and Approval | Self-review, independent review requirements, and sign-off status |

### 3.2 Out of Scope

The following activities are not represented as completed or certified by this portfolio demonstration:

- Independent actuarial model validation.
- External actuarial approval or professional certification.
- Regulatory compliance certification.
- Production deployment approval.
- Real policyholder data governance or privacy certification.
- Insurance pricing, reserving, capital, or profitability approval.
- Independent audit of assumptions or source data.
- Formal approval by an insurance company or reinsurer.

## 4. Governance Principles

| Principle | Governance Requirement |
|---|---|
| Accuracy | Calculations must follow documented definitions and assumptions. |
| Completeness | Required records and fields must be available for the intended analysis. |
| Consistency | Related datasets and analytical outputs must reconcile. |
| Traceability | Outputs must be traceable to source data, assumptions, and calculation logic. |
| Reproducibility | The study should produce consistent results when executed using the same inputs and random seed. |
| Transparency | Synthetic data, fictional assumptions, and analytical limitations must be disclosed. |
| Evidence-Based Review | Control status must be supported by recorded execution evidence. |
| Accountability | Responsibilities and approval boundaries must be clearly identified. |
| Independence | Self-review must not be represented as independent review. |

## 5. Data Governance Controls

**Status definitions:** Not Run, Pass, Fail, Blocked, or Not Applicable. A control may only be marked Pass after the required verification has been completed and supporting evidence is available.

### 5.1 Source Data Quality Controls

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| DQ-01 | Source data completeness | Check required fields for missing or null values. | `docs/evidence/DQ-01_missing_values.csv` | Not Run |
| DQ-02 | Unique policy identifiers | Confirm policy identifiers are unique. | `docs/evidence/DQ-02_duplicate_policy_check.sql` | Not Run |
| DQ-03 | Policy record validity | Verify policy records contain valid identifiers and required attributes. | `docs/evidence/DQ-03_policy_validity.csv` | Not Run |
| DQ-04 | Valid policy dates | Confirm issue, commencement, and termination dates are logically valid. | `docs/evidence/DQ-04_policy_dates.csv` | Not Run |
| DQ-05 | Valid policy status | Confirm policy statuses belong to the permitted status categories. | `docs/evidence/DQ-05_policy_status.csv` | Not Run |
| DQ-06 | Valid sum assured | Confirm face amounts are positive and fall within the defined dataset rules. | `docs/evidence/DQ-06_face_amount.csv` | Not Run |
| DQ-07 | Product reference integrity | Verify policy product references correspond to valid product records. | `docs/evidence/DQ-07_product_integrity.csv` | Not Run |
| DQ-08 | Claim identifier uniqueness | Confirm claim identifiers are unique. | `docs/evidence/DQ-08_claim_duplicates.csv` | Not Run |
| DQ-09 | Claim-policy relationship | Confirm claims reference valid policy identifiers. | `docs/evidence/DQ-09_claim_policy_integrity.csv` | Not Run |
| DQ-10 | Claim date validity | Confirm claim dates are consistent with policy coverage and study rules. | `docs/evidence/DQ-10_claim_dates.csv` | Not Run |
| DQ-11 | Assumption data completeness | Verify mortality and lapse assumptions contain all required fields. | `docs/evidence/DQ-11_assumption_completeness.csv` | Not Run |
| DQ-12 | Assumption rate validity | Verify assumption rates are within valid probability bounds. | `docs/evidence/DQ-12_assumption_rates.csv` | Not Run |
| DQ-13 | Duplicate assumption records | Confirm assumption keys do not create ambiguous matching records. | `docs/evidence/DQ-13_duplicate_assumptions.csv` | Not Run |
| DQ-14 | Synthetic-data disclosure | Confirm documentation and dashboard identify the dataset as synthetic. | `docs/evidence/DQ-14_synthetic_disclosure.png` | Not Run |

### 5.2 Data Integrity Controls

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| DI-01 | Referential integrity | Verify policy, product, claim, and assumption relationships. | `docs/evidence/DI-01_referential_integrity.csv` | Not Run |
| DI-02 | Policy and claim consistency | Reconcile claims against the corresponding policy records. | `docs/evidence/DI-02_claim_policy_reconciliation.csv` | Not Run |
| DI-03 | Study-period consistency | Confirm source records and analytical periods follow the defined 2021–2025 observation period. | `docs/evidence/DI-03_study_period.csv` | Not Run |
| DI-04 | Termination consistency | Verify termination events are consistent with the policy record and analysis rules. | `docs/evidence/DI-04_termination_consistency.csv` | Not Run |
| DI-05 | Exposure source consistency | Confirm exposure outputs are derived from the intended policy records. | `docs/evidence/DI-05_exposure_reconciliation.csv` | Not Run |
| DI-06 | Assumption matching | Confirm every eligible analytical segment has a valid corresponding assumption. | `docs/evidence/DI-06_assumption_matching.csv` | Not Run |

## 6. Analytical and Methodology Governance

### 6.1 Exposure Calculation Controls

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| EX-01 | Exposure period boundaries | Verify exposure segments respect policy commencement and termination dates. | `docs/evidence/EX-01_exposure_boundaries.csv` | Not Run |
| EX-02 | Calendar-year segmentation | Confirm exposure is split at calendar-year boundaries. | `docs/evidence/EX-02_calendar_year.csv` | Not Run |
| EX-03 | Policy anniversary handling | Verify segments split correctly at policy anniversaries. | `docs/evidence/EX-03_anniversary_handling.csv` | Not Run |
| EX-04 | Leap-year handling | Verify the documented treatment of 29 February policy anniversaries. | `docs/evidence/EX-04_leap_year.csv` | Not Run |
| EX-05 | Exposure reconciliation | Confirm segment exposure reconciles to total policy-time under the documented convention. | `docs/evidence/EX-05_exposure_reconciliation.csv` | Not Run |
| EX-06 | No overlapping exposure | Confirm exposure segments do not overlap. | `docs/evidence/EX-06_exposure_overlap.csv` | Not Run |
| EX-07 | No exposure gaps | Confirm eligible policy periods contain no unintended gaps. | `docs/evidence/EX-07_exposure_gaps.csv` | Not Run |
| EX-08 | Positive exposure | Confirm exposure values are non-negative and valid under the calculation rules. | `docs/evidence/EX-08_positive_exposure.csv` | Not Run |

### 6.2 Mortality Analysis Controls

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| MO-01 | Actual mortality definition | Verify actual deaths use approved claims under the documented rules. | `docs/evidence/MO-01_actual_deaths.csv` | Not Run |
| MO-02 | Death-date allocation | Confirm claims are allocated to the exposure segment containing the death date. | `docs/evidence/MO-02_death_allocation.csv` | Not Run |
| MO-03 | Expected mortality calculation | Verify expected deaths equal exposure multiplied by the matched mortality rate. | `docs/evidence/MO-03_expected_deaths.csv` | Not Run |
| MO-04 | Expected claim amount | Verify expected claim amount follows exposure × mortality rate × face amount. | `docs/evidence/MO-04_expected_claim_amount.csv` | Not Run |
| MO-05 | Actual-to-expected calculation | Recalculate and reconcile mortality A/E ratios. | `docs/evidence/MO-05_mortality_ae.csv` | Not Run |
| MO-06 | Claim amount reconciliation | Reconcile actual approved claim amounts with source claim records. | `docs/evidence/MO-06_claim_amount_reconciliation.csv` | Not Run |
| MO-07 | Mortality segmentation | Verify the documented portfolio and experience dimensions are represented correctly. | `docs/evidence/MO-07_mortality_segments.csv` | Not Run |
| MO-08 | Mortality assumption basis | Confirm the fictional assumption basis is identified and consistently applied. | `docs/evidence/MO-08_mortality_basis.csv` | Not Run |

### 6.3 Lapse Analysis Controls

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| LA-01 | Actual lapse definition | Verify only qualifying voluntary lapse terminations count as actual lapse events. | `docs/evidence/LA-01_actual_lapse.csv` | Not Run |
| LA-02 | Expected lapse calculation | Verify expected lapse follows exposure multiplied by the matched lapse rate. | `docs/evidence/LA-02_expected_lapse.csv` | Not Run |
| LA-03 | Lapse A/E calculation | Recalculate and reconcile lapse actual-to-expected ratios. | `docs/evidence/LA-03_lapse_ae.csv` | Not Run |
| LA-04 | Competing termination treatment | Verify non-voluntary termination events are treated according to documented rules. | `docs/evidence/LA-04_competing_terminations.csv` | Not Run |
| LA-05 | Lapse segmentation | Verify product, duration, calendar-year, and face-amount segment definitions. | `docs/evidence/LA-05_lapse_segments.csv` | Not Run |
| LA-06 | Lapse assumption basis | Confirm the fictional lapse basis is identified and consistently applied. | `docs/evidence/LA-06_lapse_basis.csv` | Not Run |

### 6.4 Statistical and Credibility Controls

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| ST-01 | Confidence interval calculation | Verify the documented Byar approximation is applied to mortality counts. | `docs/evidence/ST-01_confidence_intervals.csv` | Not Run |
| ST-02 | Zero-event treatment | Verify the upper confidence limit for zero observed events uses the documented formula. | `docs/evidence/ST-02_zero_event.csv` | Not Run |
| ST-03 | Full credibility standard | Verify the full credibility threshold uses the documented 10% relative error at 95% confidence. | `docs/evidence/ST-03_full_credibility.csv` | Not Run |
| ST-04 | Credibility factor | Verify the credibility factor follows the documented square-root formula and is capped at 1. | `docs/evidence/ST-04_credibility_factor.csv` | Not Run |
| ST-05 | Credibility-adjusted A/E | Verify the adjusted A/E calculation is consistent with the documented formula. | `docs/evidence/ST-05_adjusted_ae.csv` | Not Run |
| ST-06 | Low-credibility classification | Verify segments below 250 life-years or with fewer than 5 actual events are classified as low credibility. | `docs/evidence/ST-06_low_credibility.csv` | Not Run |
| ST-07 | Recommendation thresholds | Verify strengthen, weaken, monitor, and maintain classifications follow documented rules. | `docs/evidence/ST-07_recommendation_thresholds.csv` | Not Run |
| ST-08 | Statistical interpretation | Confirm small-segment results are not presented as conclusive without appropriate credibility context. | `docs/evidence/ST-08_interpretation_review.md` | Not Run |

## 7. Technical Validation and Reconciliation

### 7.1 SQL Validation Controls

The dashboard screenshot records **19 of 19 SQL controls passed**, with zero reported failures and a dashboard control status of PASS.

The validation execution timestamp displayed in the screenshot is **29 August 2026, 11:13:18 UTC**.

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| SQL-01 | Orphan claims | Confirm no claim records reference nonexistent policies. | `docs/evidence/SQL-01_orphan_claims.csv` | Pass |
| SQL-02 | Invalid claim dates | Identify claim dates outside permitted policy or study periods. | `docs/evidence/SQL-02_invalid_claim_dates.csv` | Pass |
| SQL-03 | Death-policy mismatch | Verify death claims are consistent with the associated policy. | `docs/evidence/SQL-03_death_policy_mismatch.csv` | Pass |
| SQL-04 | Invalid exposure | Identify invalid or negative exposure records. | `docs/evidence/SQL-04_invalid_exposure.csv` | Pass |
| SQL-05 | Study and policy window | Verify exposure records respect study and policy boundaries. | `docs/evidence/SQL-05_policy_window.csv` | Pass |
| SQL-06 | Missing mortality assumption | Identify segments without a valid mortality assumption match. | `docs/evidence/SQL-06_missing_mortality_assumption.csv` | Pass |
| SQL-07 | Duplicate exposure segments | Identify duplicate segment records. | `docs/evidence/SQL-07_duplicate_segments.csv` | Pass |
| SQL-08 | Exposure gaps and overlaps | Verify continuity and non-overlap of exposure segments. | `docs/evidence/SQL-08_exposure_integrity.csv` | Pass |
| SQL-09 | Expected deaths calculation | Reconcile expected deaths to exposure and mortality assumptions. | `docs/evidence/SQL-09_expected_deaths.csv` | Pass |
| SQL-10 | Expected claim amount | Reconcile expected claim amounts to exposure, rate, and face amount. | `docs/evidence/SQL-10_expected_claim_amount.csv` | Pass |
| SQL-11 | Claim count reconciliation | Reconcile actual claim counts to source claim records. | `docs/evidence/SQL-11_claim_count.csv` | Pass |
| SQL-12 | Claim amount reconciliation | Reconcile actual claim amounts to approved claims. | `docs/evidence/SQL-12_claim_amount.csv` | Pass |
| SQL-13 | Dimension result reconciliation | Reconcile mortality results across documented analytical dimensions. | `docs/evidence/SQL-13_dimension_reconciliation.csv` | Pass |
| SQL-14 | Lapse spine mismatch | Identify inconsistencies in the lapse exposure and result structure. | `docs/evidence/SQL-14_lapse_spine.csv` | Pass |
| SQL-15 | Expected lapse calculation | Reconcile expected lapse to exposure and lapse assumptions. | `docs/evidence/SQL-15_expected_lapse.csv` | Pass |
| SQL-16 | Competing termination control | Verify competing termination events are handled according to methodology. | `docs/evidence/SQL-16_competing_termination.csv` | Pass |
| SQL-17 | Lapse reconciliation | Reconcile actual and expected lapse results. | `docs/evidence/SQL-17_lapse_reconciliation.csv` | Pass |
| SQL-18 | Additional dashboard validation control | Retain the exact implemented check name and result from the complete dashboard validation output. | `docs/evidence/SQL-18_validation_output.txt` | Pass |
| SQL-19 | Additional dashboard validation control | Retain the exact implemented check name and result from the complete dashboard validation output. | `docs/evidence/SQL-19_validation_output.txt` | Pass |

**Evidence qualification:** The screenshot confirms the aggregate result of 19/19 passed and zero failures. The full list of individual check names should be transcribed from the complete validation output before treating this table as a detailed control-by-control audit trail. The SQL-18 and SQL-19 descriptions are placeholders, not claims about their actual implementation names.

### 7.2 Reconciliation Requirements

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| RC-01 | Policy population reconciliation | Confirm the generated policy population reconciles to the expected dataset size of 20,000. | `docs/evidence/RC-01_policy_population.csv` | Not Run |
| RC-02 | Claims reconciliation | Confirm claim outputs reconcile to approved source claims under the analysis rules. | `docs/evidence/RC-02_claims_reconciliation.csv` | Not Run |
| RC-03 | Mortality result reconciliation | Reconcile mortality output totals to underlying exposure and event records. | `docs/evidence/RC-03_mortality_reconciliation.csv` | Not Run |
| RC-04 | Lapse result reconciliation | Reconcile lapse output totals to underlying exposure and termination records. | `docs/evidence/RC-04_lapse_reconciliation.csv` | Not Run |
| RC-05 | Validation result reconciliation | Confirm validation outputs accurately represent executed controls. | `docs/evidence/RC-05_validation_results.csv` | Not Run |
| RC-06 | Dashboard reconciliation | Confirm dashboard values match the underlying analytical outputs. | `docs/evidence/RC-06_dashboard_reconciliation.png` | Not Run |

## 8. Model and Assumption Governance

### 8.1 Assumption Register

| Assumption Area | Basis Identifier | Description | Governance Requirement |
|---|---|---|---|
| Mortality | `LSL_2020_FICTIONAL` | Fictional mortality assumption basis used for portfolio analysis. | Identify as fictional and verify matching logic. |
| Lapse | `LSL_2020_LAPSE_FICTIONAL` | Fictional lapse assumption basis used for lapse analysis. | Identify as fictional and verify matching logic. |
| Study Period | 2021–2025 | Five-year observation period. | Apply consistently to source and analytical records. |
| Dataset | 20,000 policies | Synthetic policy population. | Preserve synthetic-data disclosure. |
| Credibility | 10% relative error at 95% confidence | Full credibility standard used for the documented credibility calculation. | Verify formula and threshold implementation. |
| Confidence Interval | Byar approximation | Approximate 95% count confidence interval. | Disclose approximation and limitations. |

### 8.2 Assumption Governance Controls

| ID | Control | Verification / Evidence Required | Evidence Reference | Status |
|---|---|---|---|---|
| AG-01 | Assumption identification | Verify mortality and lapse bases have clear identifiers. | `docs/evidence/AG-01_assumption_register.md` | Not Run |
| AG-02 | Assumption documentation | Confirm assumption definitions and matching dimensions are documented. | `docs/evidence/AG-02_assumption_documentation.md` | Not Run |
| AG-03 | Assumption versioning | Record the version or release identifier used for the analysis. | `docs/evidence/AG-03_assumption_version.md` | Not Run |
| AG-04 | Assumption application | Verify the intended assumption is applied to each eligible segment. | `docs/evidence/AG-04_assumption_application.csv` | Not Run |
| AG-05 | Assumption limitations | Confirm fictional assumptions are not presented as industry-standard or approved bases. | `docs/evidence/AG-05_assumption_limitations.md` | Not Run |
| AG-06 | Change traceability | Document changes to assumptions, matching rules, or calculation logic. | `docs/evidence/AG-06_change_log.md` | Not Run |

## 9. Roles and Responsibilities

### 9.1 Governance Responsibility Matrix

| Activity | Business Analyst | Data Analyst | Developer | QA Reviewer | Actuarial Reviewer | Project Owner |
|---|---|---|---|---|---|---|
| Business requirements | Responsible | Consulted | Consulted | Consulted | Consulted | Accountable |
| Data quality review | Consulted | Responsible | Supporting | Reviewing | Consulted | Accountable |
| Data transformation | Consulted | Responsible | Responsible | Reviewing | Consulted | Accountable |
| SQL validation | Consulted | Responsible | Responsible | Reviewing | Consulted | Accountable |
| Mortality methodology | Consulted | Supporting | Supporting | Reviewing | Responsible | Accountable |
| Lapse methodology | Consulted | Supporting | Supporting | Reviewing | Responsible | Accountable |
| Statistical review | Consulted | Supporting | Supporting | Reviewing | Responsible | Accountable |
| Dashboard validation | Consulted | Responsible | Responsible | Reviewing | Consulted | Accountable |
| UAT execution | Responsible | Supporting | Supporting | Responsible | Consulted | Accountable |
| Final governance approval | Supporting | Supporting | Supporting | Reviewing | Reviewing | Accountable |

*For this portfolio demonstration, the Project Author performed the roles of Data Analyst, Developer, Business Analyst, and QA Reviewer. Actuarial Reviewer and Project Owner roles are proposed for independent review and have not been externally assigned.*

### 9.2 Responsibility Boundaries

- The Project Author is responsible for implementation and documentation of the portfolio demonstration.
- Self-review provides an initial quality assessment but does not establish independent validation.
- The Actuarial Reviewer role is intended for an appropriately qualified independent reviewer.
- The Project Owner role is intended to provide business acceptance and approval.
- External review and approval remain pending unless formally obtained and documented.

## 10. Governance Review Record

### 10.1 Review Details

| Field | Review Record |
|---|---|
| Review ID | `GOV-2026-001` |
| Review Date | `2026-11-08` |
| Project Name | InsureMetrics |
| Dataset Version | `v1.0-synthetic-20000` *(proposed version identifier)* |
| Assumption Basis Version | `fictional-v1.0` *(proposed version identifier)* |
| Reviewer | Project Author (self-review) |
| Review Type | Portfolio Project Governance Self-Review |
| Total Controls Reviewed | `19` |
| Passed Controls | `19` |
| Failed Controls | `0` |
| Pending Controls | `62` |
| Not Applicable Controls | `0` |
| Key Findings | All 19 SQL validation controls passed, with zero reported failures. The InsureMetrics dashboard displays a PASS status. The recorded validation timestamp is 29 August 2026 at 11:13:18 UTC. The remaining 62 governance checklist controls require execution and supporting evidence. Independent actuarial review and external approval have not been obtained. |
| Final Decision | SQL validation passed. Overall governance approval remains pending completion of the remaining controls and independent external review. |

**Control-count basis:** The checklist contains 81 listed control rows. The 19 SQL validation controls are recorded as passed based on the dashboard screenshot. The remaining 62 rows are pending. Some governance controls may overlap in their verification scope; these counts represent checklist-row status, not 81 independent tests or unique technical checks.

### 10.2 Review Execution Summary

The governance review must be performed against the implemented project and its supporting evidence.

The reviewer should:

1. Confirm that the checklist corresponds to the current project version.
2. Execute the relevant Python and SQL tests.
3. Inspect validation outputs and reconciliation results.
4. Verify that the methodology and assumption documentation match the implementation.
5. Inspect dashboard values against analytical outputs.
6. Record exceptions and failed controls.
7. Link supporting evidence to each reviewed control.
8. Record unresolved issues and required follow-up.
9. Document the review outcome without representing self-review as independent approval.

### 10.3 Review Status Summary

| Status | Definition |
|---|---|
| Pass | Control executed successfully and supporting evidence is available. |
| Fail | Control executed and did not satisfy its acceptance requirement. |
| Not Run | Control has not yet been executed. |
| Blocked | Control execution is prevented by an unresolved dependency or issue. |
| Not Applicable | Control does not apply, with a documented reason. |

### 10.4 Key Findings and Exceptions

| Finding ID | Related Control | Finding / Observation | Severity | Action Required | Status |
|---|---|---|---|---|---|
| GOV-F-001 | SQL-01 to SQL-19 | Dashboard reports 19/19 SQL controls passed and zero failures. | Informational | Retain dashboard evidence and detailed validation output. | Recorded |
| GOV-F-002 | Remaining governance controls | 62 checklist rows remain pending execution or evidence collection. | Medium | Execute applicable checks and update evidence references. | Open |
| GOV-F-003 | Independent review | Independent actuarial review and external project approval have not been obtained. | Medium | Seek independent review if formal approval is required. | Pending |

No finding should be treated as resolved until the corrective action has been completed and the relevant control has been retested.

## 11. Approval and Sign-Off

### 11.1 Sign-Off Matrix

| Role | Responsibility | Reviewer / Approver | Sign-Off Status | Date |
|---|---|---|---|---|
| Project Author | Project implementation and self-review | Project Author | Self-review recorded | 2026-11-08 |
| Business Analyst | Business requirements and process alignment | Project Author | Self-review recorded | 2026-11-08 |
| Data Analyst | Data quality and analytical reconciliation | Project Author | Self-review recorded for SQL validation | 2026-11-08 |
| QA Reviewer | Test execution and quality review | Project Author | SQL validation result recorded | 2026-11-08 |
| Actuarial Reviewer | Independent methodology and actuarial review | To be assigned | Pending external review | Pending |
| Project Owner | Business acceptance and project approval | To be assigned | Pending external approval | Pending |

*For this portfolio demonstration, the Project Author performed a self-review of all governance controls. External sign-off is pending and has not been obtained.*

### 11.2 Conditions for Governance Approval

The project should not be described as independently approved or production-ready unless the relevant review and approval conditions have been satisfied.

The following conditions apply:

1. Required governance controls have been executed.
2. Failed controls and material exceptions have been investigated and addressed.
3. Supporting evidence is available and traceable.
4. Methodology and assumptions have been reviewed by an appropriately qualified independent reviewer where required.
5. Business acceptance has been obtained from an authorized project owner where applicable.
6. Review outcomes and sign-off decisions have been documented.

### 11.3 Approval Status

**Current governance status:** Portfolio demonstration – self-review; SQL validation passed.

**Independent actuarial review:** Pending.

**External project approval:** Pending.

**Production approval:** Not applicable; this project is not represented as a production insurance system.

## 12. Evidence Management

### 12.1 Evidence Storage

Governance evidence should be maintained in:

`docs/evidence/`

Evidence may include:

- SQL query outputs.
- Data-quality exception reports.
- Policy and claims reconciliation results.
- Exposure validation outputs.
- Mortality and lapse calculation checks.
- Statistical and credibility calculation checks.
- Python unit-test results.
- SQL test execution results.
- Dashboard screenshots.
- Review notes and exception logs.
- Assumption and methodology review records.

### 12.2 Evidence Naming Convention

Use a consistent naming convention:

`<CONTROL-ID>_<short-description>.<extension>`

Example structure:

```text
docs/
├── Governance_Checklist.md
└── evidence/
    ├── GOV-2026-001_sql-validation-dashboard.png
    ├── SQL-01_orphan_claims.csv
    ├── SQL-02_invalid_claim_dates.csv
    ├── SQL-03_death_policy_mismatch.csv
    ├── EX-04_leap_year.csv
    ├── MO-03_expected_deaths.csv
    ├── LA-03_lapse_ae.csv
    ├── ST-04_credibility_factor.csv
    └── GOV-2026-001_review_record.md
```

These are proposed filenames. Create each evidence file only when the corresponding output or record is actually available.

### 12.3 Evidence Requirements

Every control marked Pass or Fail should have an evidence reference or a documented explanation for why evidence is unavailable.

Evidence should be:

- Relevant to the control being assessed.
- Traceable to the project version and execution date.
- Reproducible where applicable.
- Stored in the designated evidence folder.
- Consistent with the recorded control status.

Do not create placeholder evidence files merely to make a checklist appear complete.

### 12.4 Existing SQL Validation Evidence

The supplied dashboard screenshot records:

| Metric | Observed Result |
|---|---|
| Controls passed | 19 / 19 |
| Total failures | 0 |
| Control status | PASS |
| Validation timestamp | 2026-08-29 11:13:18 UTC |

The screenshot should be retained as:

`docs/evidence/GOV-2026-001_sql-validation-dashboard.png`

The screenshot supports the aggregate SQL validation result. A detailed control-level audit trail should additionally retain the complete validation output, including the names of all 19 checks.

## 13. Issue and Exception Management

### 13.1 Issue Classification

| Severity | Description | Expected Treatment |
|---|---|---|
| Critical | Material error affecting core calculations or data integrity. | Resolve before relying on affected results. |
| High | Significant analytical or reconciliation issue. | Investigate and resolve before final review. |
| Medium | Non-critical defect affecting a subset of outputs or controls. | Document and prioritize corrective action. |
| Low | Documentation, presentation, or minor usability issue. | Record and address as appropriate. |

### 13.2 Issue Register

| Issue ID | Related Control | Description | Severity | Owner | Target Date | Status |
|---|---|---|---|---|---|---|
| GOV-I-001 | To be assigned | To be recorded if an issue is identified. | To be assessed | To be assigned | To be assigned | Open |
| GOV-I-002 | To be assigned | To be recorded if an issue is identified. | To be assessed | To be assigned | To be assigned | Open |

### 13.3 Corrective Action Requirements

For every failed or materially blocked control:

1. Record the issue and affected control.
2. Identify the cause of the failure.
3. Determine the impact on analytical outputs.
4. Assign a corrective action.
5. Re-execute the affected test or control.
6. Record the retest result.
7. Update the evidence reference.
8. Close the issue only after the outcome has been verified.

## 14. Change Management

Changes to the following project components should be documented:

- Source data generation logic.
- Dataset size or random seed.
- Policy and claim data definitions.
- Mortality or lapse assumptions.
- Exposure calculation logic.
- SQL validation rules.
- Statistical methodology.
- Credibility thresholds.
- Recommendation classification rules.
- Dashboard calculations and presentation.
- Project documentation.

### 14.1 Change Log

| Change ID | Date | Component | Change Description | Reason | Impact Assessment | Reviewed By |
|---|---|---|---|---|---|---|
| CHG-001 | 2026-11-08 | Governance documentation | Initial governance checklist baseline | Documentation baseline | Establishes governance control framework | Project Author |
| CHG-002 | 2026-11-08 | Governance documentation | Added SQL validation execution result, evidence references, and review disclosures | Dashboard validation evidence | Updated governance review record | Project Author |

### 14.2 Change Control Requirements

- Maintain version history for material changes.
- Record the reason for changes.
- Identify affected controls and tests.
- Perform regression testing where calculation logic changes.
- Update documentation and evidence references.
- Do not overwrite historical review records without retaining traceability.

## 15. Governance Limitations

The following limitations must be considered when interpreting this governance framework.

1. **Synthetic Data:** The dataset represents a simulated portfolio and does not contain real policyholder records.
2. **Fictional Assumptions:** Mortality and lapse bases are fictional and are intended only for demonstration.
3. **No Independent Validation:** The project author has not represented self-review as independent actuarial validation.
4. **No External Sign-Off:** No external actuarial or business approval is implied.
5. **Methodological Limitations:** Exposure-based expected-event calculations and statistical approximations have the limitations documented in `docs/methodology.md` and `docs/model_limitations.md`.
6. **No Production Use:** The outputs should not be used directly for insurance pricing, reserving, capital assessment, regulatory reporting, or business decisions.
7. **Evidence Dependency:** A control cannot be considered passed solely because a corresponding SQL query, Python function, or documentation section exists. Its execution and result must be reviewed.
8. **SQL Evidence Scope:** The dashboard screenshot supports the aggregate result of 19 passed SQL checks and zero failures. It does not independently establish that all other governance checklist controls have passed.

## 16. Related Documentation

| Document | Purpose |
|---|---|
| `README.md` | Project overview, setup, and execution instructions |
| `docs/BRD.md` | Business requirements and acceptance criteria |
| `docs/UAT_Plan.md` | User acceptance testing scenarios and procedures |
| `docs/UAT_Execution_Log.md` | UAT execution records and outcomes |
| `docs/data_dictionary.md` | Dataset fields and definitions |
| `docs/methodology.md` | Analytical methodology and calculation definitions |
| `docs/validation_controls.md` | Technical validation control descriptions |
| `docs/model_limitations.md` | Model and analytical limitations |
| `docs/assumption_recommendation.md` | Assumption review and recommendation framework |
| `docs/evidence/` | Supporting governance and testing evidence |

## 17. Document Control

| Field | Description |
|---|---|
| Document Name | Governance Checklist |
| Project | InsureMetrics |
| Version | 2.1 |
| Document Owner | Project Author |
| Status | Portfolio Demonstration – Self-Review |
| Created For | Data Governance, Analytical Controls, and Quality Assurance |
| Last Updated | 8 November 2026 |
| Next Review | After remaining control execution and evidence collection |
| Repository Path | `docs/Governance_Checklist.md` |

### Version History

| Version | Date | Description |
|---|---|---|
| 1.0 | 8 November 2026 | Initial governance checklist. |
| 2.0 | 8 November 2026 | Added evidence-reference columns, portfolio role clarification, self-review disclosure, and governance review record. |
| 2.1 | 8 November 2026 | Updated governance review record with the observed 19/19 SQL validation result, zero failures, validation timestamp, evidence reference, and outstanding control status. |

---

**End of Document**

**Governance Statement:** InsureMetrics demonstrates a structured approach to data governance, analytical validation, statistical review, and evidence-based quality assurance. The dashboard records 19 of 19 SQL validation controls passed with zero reported failures. Remaining governance controls and evidence collection are pending. This document does not imply independent actuarial validation, external approval, or production readiness.