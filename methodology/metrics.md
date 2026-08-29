# Metrics

Metrics are defined **before** experiments run. Each maps to a research sub-question from the thesis scope.

## A. Podvajanje / DRY

Measures how much configuration is shared vs repeated across deployment units.

| Metric ID | Name                      | Definition                                                                |
| --------- | ------------------------- | ------------------------------------------------------------------------- |
| D1        | Total relevant lines      | Non-empty, non-comment HCL lines excluding lock/state and generated files |
| D2        | Shared share              | Share of lines in shared modules / common fragments                       |
| D3        | Env/region-specific share | Share of lines that are environment- or region-specific                   |
| D4        | Duplicated share          | Share of duplicated lines or identical blocks                             |

**Exclude:** comments, blank lines, lock/state files, generated content.

## B. Change amplification

For each change in [change-catalog.md](change-catalog.md), measured after applying the change from a tagged baseline.

| Metric ID | Name             | Definition                                         |
| --------- | ---------------- | -------------------------------------------------- |
| CA1       | Files changed    | Count of modified/added/deleted config files       |
| CA2       | Lines changed    | Sum of added + removed lines (git diff stat)       |
| CA3       | Edit loci        | Number of places where the change must be written  |
| CA4       | Plan/apply units | Number of separate plan/apply units required       |
| CA5       | User commands    | Number of user CLI commands to complete the change |

## C. State isolation and blast radius

| Metric ID | Name                    | Definition                                                                                               |
| --------- | ----------------------- | -------------------------------------------------------------------------------------------------------- |
| BR1       | State file count        | Total state files for the full scenario (descriptive: more states → better isolation, more coordination) |
| BR2       | Max resources per state | Largest number of resources in any single state file                                                     |
| BR3       | Max environments hit    | Max environments one wrong apply can affect                                                              |
| BR4       | Max regions hit         | Max regions one wrong apply can affect                                                                   |
| BR5       | Max modules hit         | Max modules one wrong apply can affect                                                                   |

## D. Adding an environment or region

Measured when executing catalog change **05-add-environment** or **06-add-region**.

| Metric ID | Name                          | Definition                                        |
| --------- | ----------------------------- | ------------------------------------------------- |
| AE1       | Files touched                 | New and modified files                            |
| AE2       | Lines touched                 | New and changed lines                             |
| AE3       | Manual steps                  | Non-scripted steps (documented count)             |
| AE4       | New state/backend units       | New state files or backend configurations created |
| AE5       | Commands and plan/apply units | CLI commands plus separate plan/apply units       |

Time is supplementary only.

## E. Cognitive complexity

Broader than toolchain count alone: tools, concepts, and operational steps.

| Metric ID | Name               | Definition                                                                                |
| --------- | ------------------ | ----------------------------------------------------------------------------------------- |
| CC1       | Tools and formats  | Distinct tools and config formats                                                         |
| CC2       | Key concepts       | Approach-specific concepts needed for routine work (workspace, dependency, deployment, …) |
| CC3       | Steps and commands | Steps and commands for basic operations and for adding an environment                     |

## Reporting

Results are reported per metric and per approach. Conclusions are contextual (decision guide), not a single winner ranking.
