# Business Requirements Document (BRD)
## InsureMetrics – Term-Life Insurance Experience & Portfolio Analytics Engine

**Document Version:** 2.1  
**Document Status:** Portfolio Demonstration  
**Project Type:** Insurance Analytics / Actuarial Data Analysis  
**Observation Period:** 2021–2025  
**Data Classification:** Synthetic Data Only

---

## 1. Executive Summary

InsureMetrics is an actuarial analytics platform designed to transform term-life insurance policy and claims data into validated mortality and lapse experience insights.

The platform processes synthetic policy, death-claim, mortality-assumption, and lapse-assumption datasets using Python, PostgreSQL, SQL, statistical analysis, and Streamlit.

It calculates exposure, actual-to-expected (A/E) experience, statistical confidence intervals, and credibility-adjusted results. It also applies defined review rules to classify experience and support assumption review.

The purpose of this project is to demonstrate an end-to-end insurance analytics workflow, including business requirements, data processing, validation controls, statistical analysis, reporting, and decision support.

**Important:** This is a portfolio demonstration using synthetic data. It is not a production actuarial model, an approved pricing basis, or an actuarial opinion.

## 2. Business Problem

Insurance experience analysis requires reliable policy, claims, and assumption data. Inconsistent records, incorrect exposure calculations, incomplete claims reconciliation, and insufficient statistical credibility can lead to misleading conclusions.

The project addresses the following business challenges:

- Difficulty converting raw policy and claims records into meaningful experience measures.
- Risk of inaccurate exposure calculations due to policy dates, anniversaries, and study-period boundaries.
- Need to reconcile approved claims with policy records and calculated experience.
- Need to compare actual mortality and lapse experience against expected assumptions.
- Risk of drawing conclusions from segments with insufficient exposure or event counts.
- Need for structured validation, transparent review rules, and management-ready reporting.

## 3. Business Objectives

| ID | Business Objective | Expected Outcome |
|---|---|---|
| BO-01 | Perform mortality experience analysis | Compare actual and expected mortality experience across defined portfolio segments. |
| BO-02 | Perform lapse experience analysis | Evaluate voluntary lapse experience against expected lapse assumptions. |
| BO-03 | Improve data reliability | Apply validation and reconciliation controls to policy, claim, exposure, and assumption data. |
| BO-04 | Assess statistical credibility | Use confidence intervals and credibility adjustments to qualify experience results. |
| BO-05 | Support assumption review | Classify experience into maintain, monitor, strengthen, weaken, or low-credibility categories. |
| BO-06 | Improve business reporting | Present portfolio results through structured tables, summaries, and dashboard visualisations. |

## 4. Stakeholders

| Stakeholder | Responsibility |
|---|---|
| Business / Product Owner | Defines business objectives and expected outcomes. |
| Business Analyst | Documents requirements, business rules, scope, and traceability. |
| Actuarial Reviewer | Reviews mortality, lapse, exposure, and credibility methodology. |
| Data Analyst | Performs data profiling, analysis, and reconciliation. |
| Data Engineer / Developer | Implements data generation, SQL processing, and application logic. |
| QA / UAT Reviewer | Reviews test scenarios, expected results, and defects. |
| Management / Decision Maker | Reviews portfolio insights and potential assumption actions. |

These are proposed project roles, not actual external project appointments.

## 5. Project Scope

### 5.1 In Scope

- Generation and processing of synthetic term-life policy records.
- Processing of synthetic approved death-claim records.
- Loading of mortality and lapse assumptions.
- Policy exposure calculation over the observation period.
- Mortality and lapse experience analysis.
- Actual-to-expected calculations.
- Statistical confidence intervals and credibility adjustments.
- Data validation and reconciliation controls.
- Experience segmentation and dashboard reporting.
- Documentation of methodology, limitations, and review recommendations.

### 5.2 Out of Scope

- Real customer or insurer data processing.
- Production actuarial pricing or reserving.
- Regulatory or statutory actuarial opinions.
- Reinsurance pricing and capital modelling.
- Individual policy underwriting decisions.
- Predictive mortality or lapse machine-learning models.
- Automated production approval of actuarial assumptions.
- Integration with live insurance administration systems.

## 6. Functional Requirements

Each functional requirement includes a measurable acceptance criterion to support implementation, testing, and UAT traceability.

| ID | Functional Requirement | Acceptance Criterion |
|---|---|---|
| FR-01 | The system shall generate or load synthetic term-life policy records. | The standard dataset contains 20,000 generated policy records, with unique policy identifiers and valid policy dates. |
| FR-02 | The system shall load synthetic death-claim records and their approval information. | Claim records can be loaded and associated with valid policy identifiers; invalid or orphan references are identified by validation controls. |
| FR-03 | The system shall load mortality and lapse assumption datasets. | Assumption records are available with the required product, duration, and rate information; unmatched assumption records are flagged. |
| FR-04 | The system shall calculate policy exposure within the defined observation period. | Exposure is calculated using the documented inclusive calendar-day convention and is split at calendar-year and policy-anniversary boundaries. **Verification:** The sum of daily exposures equals total policy-time, and leap-day policies are split correctly (see UAT-004). |
| FR-05 | The system shall calculate actual mortality experience. | Approved death claims are counted in the exposure segment containing the death date, with claim-to-policy reconciliation. |
| FR-06 | The system shall calculate expected mortality experience. | Expected deaths are calculated as exposure multiplied by the matched mortality rate. |
| FR-07 | The system shall calculate expected claim amounts. | Expected claim amounts are calculated using exposure, mortality assumptions, and policy face amounts. |
| FR-08 | The system shall calculate actual-to-expected mortality ratios. | The system produces actual and expected mortality measures and A/E ratios for supported portfolio segments. |
| FR-09 | The system shall calculate statistical confidence intervals for mortality results. | The system produces the documented 95% Byar count interval, including the defined zero-event treatment. |
| FR-10 | The system shall calculate credibility-adjusted mortality experience. | Credibility is calculated using the documented limited-fluctuation method and applied consistently to supported results. |
| FR-11 | The system shall calculate lapse experience. | Voluntary lapse terminations are identified and reconciled against policy exposure records. |
| FR-12 | The system shall calculate expected lapse experience and lapse A/E. | Expected lapses are calculated using exposure multiplied by the matched lapse assumption, with actual-to-expected results produced. |
| FR-13 | The system shall perform data-quality and reconciliation checks. | The defined SQL validation controls execute and identify configured data-quality or reconciliation failures. |
| FR-14 | The system shall segment experience by supported business dimensions. | Results are available for the documented mortality and lapse segmentation dimensions, with segment totals reconcilable to the portfolio results. |
| FR-15 | The system shall classify experience using defined review rules. | Each eligible result receives the applicable review classification, including low credibility, strengthen, weaken, monitor, or maintain. |
| FR-16 | The system shall present experience results through a dashboard. | The dashboard displays mortality, lapse, credibility, validation, and recommendation outputs from the processed datasets. |

## 7. Business Rules

| Rule ID | Business Rule |
|---|---|
| BR-01 | The study observation period is 1 January 2021 to 31 December 2025. |
| BR-02 | Exposure is calculated using inclusive calendar days. |
| BR-03 | Exposure segments are split at calendar-year and policy-anniversary boundaries. |
| BR-04 | A 29 February policy anniversary advances to 28 February in a non-leap year. |
| BR-05 | Only approved death claims are included in actual mortality experience. |
| BR-06 | A death claim is assigned to the exposure segment containing its death date. |
| BR-07 | Expected deaths equal exposure multiplied by the matched mortality assumption. |
| BR-08 | Expected claim amount equals exposure multiplied by the mortality assumption and policy face amount. |
| BR-09 | Only voluntary lapse terminations are included in actual lapse experience. |
| BR-10 | Expected lapses equal exposure multiplied by the matched lapse assumption. |
| BR-11 | Results below defined exposure or event-count thresholds are classified as low credibility. |
| BR-12 | Review recommendations follow the documented confidence interval, credibility, and A/E thresholds. |

## 7.5 Data Requirements

The platform requires policy, claim, mortality-assumption, and lapse-assumption data. The following table describes the logical business data requirements. Physical column names, data types, and constraints must be confirmed against the implemented SQL schema and data dictionary.

| Data Entity | Key Fields | Business Purpose | Validation Requirement |
|---|---|---|---|
| Policy | policy_id, issue_date, product_code, face_amount, issue_age, sex, smoking_status, policy_status, termination_date, termination_reason, issue_state | Represents the term-life policy and its coverage characteristics. | Unique policy ID, valid dates, positive face amount, valid product reference, and consistent termination information. |
| Death Claim | claim_id, policy_id, claim_date, claim_status, approved_amount | Represents death claims associated with policies. | Unique claim ID, valid policy reference, valid claim date, approved status, and valid approved amount. |
| Product | product_code, product_name | Defines the insurance product associated with a policy. | Unique product code and valid product reference. |
| Mortality Assumption | product_code, duration, mortality_rate (qx), assumption_basis | Provides expected mortality rates for experience calculations. | Valid product and duration mapping; rate must be within the permitted range. |
| Lapse Assumption | product_code, duration, lapse_rate, assumption_basis | Provides expected lapse rates for lapse calculations. | Valid product and duration mapping; rate must be within the permitted range. |
| Exposure Result | policy_id, segment_start_date, segment_end_date, exposure | Stores calculated exposure for the relevant observation segment. | No invalid date range, gaps, overlaps, or negative exposure. |
| Experience Result | segment dimensions, actual_events, expected_events, actual_to_expected, confidence_interval, credibility_factor | Stores mortality and lapse experience outputs. | Reconciles to source records and documented calculation rules. |

### 7.5.1 Data Quality Expectations

- Primary identifiers must be unique within their respective entities.
- Foreign-key relationships must resolve to valid records.
- Required dates must be populated and logically consistent.
- Numeric rates and monetary values must satisfy defined business constraints.
- Missing or unmatched assumptions must be identified rather than silently ignored.
- Exposure segments must not contain unintended gaps or overlaps.
- Aggregated results must reconcile with their underlying records.
- Synthetic data must remain clearly identified in reports and documentation.

## 8. Non-Functional Requirements

| ID | Requirement | Acceptance Criterion |
|---|---|---|
| NFR-01 | Data integrity | Defined primary-key, relationship, and reconciliation checks execute successfully against valid test data. |
| NFR-02 | Reliability | Repeated generation using the same random seed produces reproducible synthetic datasets. |
| NFR-03 | Maintainability | SQL scripts, Python logic, documentation, and dashboard components are organised into separate project modules. |
| NFR-04 | Usability | Dashboard users can navigate mortality, lapse, validation, and recommendation views. |
| NFR-05 | Transparency | Methodology, assumptions, thresholds, and model limitations are documented. |
| NFR-06 | Performance | The application processes the standard synthetic dataset without requiring manual record-by-record intervention. |
| NFR-07 | Reproducibility | The study can be executed using the documented setup and run instructions. |
| NFR-08 | Data privacy | The portfolio demonstration uses synthetic data and does not require real policyholder information. |

## 9. Reporting Requirements

The dashboard and supporting outputs shall provide:

- Portfolio-level mortality experience.
- Mortality results by calendar year and supported business segments.
- Actual deaths, expected deaths, and A/E ratios.
- Expected claim amounts and relevant claim experience measures.
- Confidence intervals and credibility-adjusted results.
- Portfolio-level and segmented lapse experience.
- Data validation and reconciliation results.
- Assumption review classifications.
- Clear disclosure of synthetic data and model limitations.

## 10. Business Acceptance Criteria

The project will be considered functionally ready for portfolio demonstration when:

1. The documented data-generation and study execution process completes.
2. Policy, claim, product, and assumption datasets are loaded and processed.
3. Exposure calculations follow the documented date and segmentation rules.
4. Mortality and lapse calculations follow the documented methodology.
5. Validation controls identify deliberately introduced invalid records in applicable test scenarios.
6. Experience results reconcile to their underlying source data.
7. Confidence intervals and credibility calculations follow the documented formulas.
8. Review classifications follow the configured business rules.
9. Dashboard outputs reflect the processed results.
10. Project limitations and synthetic-data disclosures are visible in the documentation.

These criteria define project acceptance expectations; they do not represent completed external UAT or independent actuarial approval.

Detailed UAT test scenarios, expected results, and pass/fail records are maintained in `docs/UAT_Plan.md`. Governance controls and validation evidence are maintained in `docs/Governance_Checklist.md`.

## 11. Assumptions and Dependencies

### Assumptions

- All policy, claim, and assumption data are synthetic.
- The observation period is fixed to 2021–2025.
- The mortality and lapse assumption bases are fictional.
- The documented exposure and statistical methodologies are applied consistently.
- The project is intended for demonstration and learning, not production decision-making.

### Dependencies

- Python environment and required packages.
- PostgreSQL database.
- Docker and Docker Compose for the documented database setup.
- SQL scripts and synthetic input datasets.
- Streamlit dashboard and associated dependencies.
- Project documentation and test fixtures.

## 12. Risks and Constraints

| Risk ID | Risk | Potential Impact | Mitigation |
|---|---|---|---|
| R-01 | Synthetic data may not reflect real insurance portfolios. | Results may not generalise to actual insurer experience. | Clearly disclose synthetic data and avoid production claims. |
| R-02 | Low event counts may produce unstable experience ratios. | Misleading assumption conclusions. | Apply credibility and low-volume review rules. |
| R-03 | Incorrect exposure segmentation may distort expected experience. | Incorrect mortality or lapse results. | Apply boundary, anniversary, and reconciliation tests. |
| R-04 | Missing or unmatched assumptions may affect calculations. | Incomplete or invalid results. | Use fail-fast validation controls. |
| R-05 | Simplified actuarial assumptions may not capture real-world dependencies. | Model limitations and potential bias. | Document methodology and limitations. |
| R-06 | Results may be interpreted as approved actuarial recommendations. | Inappropriate business decisions. | Require qualified independent review before any real-world use. |

## 13. Requirements Traceability Matrix

The following matrix connects business objectives to functional requirements and UAT scenarios. It is intended to support end-to-end traceability from business need through testing.

| Business Objective | Functional Requirements | Related UAT Test Cases |
|---|---|---|
| BO-01: Mortality experience analysis | FR-04, FR-05, FR-06, FR-07, FR-08 | UAT-004, UAT-005, UAT-006, UAT-007, UAT-008 |
| BO-02: Lapse experience analysis | FR-11, FR-12 | UAT-015, UAT-016, UAT-017 |
| BO-03: Data reliability | FR-01, FR-02, FR-03, FR-13 | UAT-001, UAT-002, UAT-003, UAT-009, UAT-010, UAT-011 |
| BO-04: Statistical credibility | FR-09, FR-10 | UAT-012, UAT-013 |
| BO-05: Assumption review | FR-10, FR-15 | UAT-014, UAT-018, UAT-019 |
| BO-06: Business reporting | FR-14, FR-16 | UAT-020, UAT-021, UAT-022, UAT-023, UAT-024, UAT-025 |

**Traceability note:** The UAT references above are proposed mappings to the 25-case UAT plan. Confirm each case title and test procedure against `docs/UAT_Plan.md` before treating the matrix as a formally baselined traceability record. Any change in requirement or test-case scope should be reflected in both documents.

## 14. Approval and Sign-Off

### 14.1 Portfolio Demonstration Role Declaration

For the purposes of this portfolio demonstration, the Project Author performed the responsibilities associated with the following roles:

- Business Analyst – requirements gathering, business rules, scope definition, and documentation.
- Data Analyst – data profiling, validation, and documentation of the data dictionary.
- QA Reviewer – preparation and review of validation scenarios and UAT documentation.
- Actuarial Methodology Reviewer – documentation-level review of the implemented experience calculations and stated assumptions.

These are self-performed portfolio responsibilities and do not constitute independent professional review, formal business approval, or qualified actuarial sign-off.

**External stakeholder sign-off is pending and has not been obtained.**

### 14.2 Sign-Off Record

| Role | Reviewer | Status |
|---|---|---|
| Project Author / Business Analyst | Project Author | Self-review |
| Data Analyst | Project Author | Self-review |
| QA / UAT Reviewer | To be assigned | Pending independent review |
| Actuarial Reviewer | To be assigned | Pending independent review |
| Business / Project Owner | Not applicable to this demonstration | No external approval |

### 14.3 Approval Conditions

- Requirements should be reviewed against the implemented application.
- UAT results must be recorded after actual test execution.
- Defects must be documented and resolved or formally accepted.
- Actuarial methodology should receive independent qualified review before any real-world application.
- External approval must not be implied where none has been provided.

## 15. Document Control

| Field | Value |
|---|---|
| Document | Business Requirements Document |
| Project | InsureMetrics |
| Version | 2.1 |
| Status | Portfolio Demonstration |
| Data | Synthetic |
| Observation Period | 2021–2025 |
| Related Document | UAT_Plan.md |
| Related Document | Governance_Checklist.md |
| Related Document | data_dictionary.md |
| Related Document | methodology.md |

**End of Document**