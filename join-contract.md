# Join contract

## PAI 1.0

```text
LEFT   quota_raj_gp_raj_2015_2020.parquet
       key: election_gp_key
       unique: 7,882 of 7,882 rows
RIGHT  PAI 1.0 Theme 8 rows
       key: gp_code
       unique: 10,634 of 10,634 Rajasthan rows
CARD   many to one
OUT    exactly 7,882 rows; the election panel is preserved
MATCH  direct LGD GP code; missing LGD codes remain unmatched
```

## PAI 2.0 groups

```text
LEFT   one normalized district-block group per election GP
RIGHT  one normalized district-block group per PAI 2.0 group
CARD   many to one
RULE   exact normalized group first
       nonexact groups require status=approved in pai2_group_overrides.csv
OUT    exactly 7,882 rows; an unapproved group remains unmatched
```

The active review list contains 77 source groups affected by spelling or Rajasthan's district reorganization. All 77 were reviewed without treatment or outcome fields. Every target exists in PAI, every pair has 5 to 34 exact normalized GP-name overlaps, and ambiguous statewide block names require explicit disambiguating evidence. The pipeline uses only rows with a reviewer, date, and `status=approved`.

## PAI 2.0 GP names

```text
LEFT   election GP within an exact or approved canonical group
RIGHT  PAI 2.0 GP within the same canonical group
KEY    exact normalized official GP name, then exact normalized election GP name
CARD   one to one in accepted links
FUZZY  preclink Jaro-Winkler score within canonical group
       threshold 0.85, margin 0.05, Hungarian assignment
       proposals enter only the review queue
       only decision=approved rows enter the analysis crosswalk
OUT    exactly 7,882 rows; unmatched outcomes remain missing
```

The fuzzy review queue excludes treatment and PAI scores. A reviewer sees names, groups, component scores, and competing pairs without knowing reservation status or the outcome.

## Required diagnostics

- Row count before and after every join.
- Key uniqueness on the required side.
- Match rate overall and by reservation status.
- Linked GPs and informative assignment strata by PAI version.
- Right-side reuse count, which must be zero for accepted PAI 2.0 links.
- Unmatched examples from both sides.
- Precision and recall from a hand-labeled sample stratified over score and margin.

## UP election release

```text
LEFT   local_elections_up canonical election release
       key: source_id within election year
FILTER election_year = 2021 and office = gp
OUT    exactly 49,773 winner rows
RULE   import canonical names, reservation recodes, LGD links, and collision flags
       do not maintain parallel name overrides in nari_niti
```

## UP PAI 1.0

```text
LEFT   49,773 UP election rows
RIGHT  PAI 1.0 Good Governance rows
KEY    accepted election-to-LGD GP code = PAI GP code
CARD   one to one among accepted links
OUT    exactly 49,773 rows; unmatched scores remain missing
```

## UP PAI 2.0

```text
LEFT   49,773 UP election rows
RIGHT  PAI 2.0 Good Governance rows with unique normalized GP keys
BLOCK  normalized district and LGD block
PASS 1 exact normalized official LGD GP name
PASS 2 exact normalized election GP name among unused rows
CARD   one to one among accepted links
OUT    exactly 49,773 rows; unmatched scores remain missing
```

The two UP wave joins stack to exactly 99,546 rows. The pipeline asserts unique election and PAI keys, preserves every election row, writes unmatched rows from both sides, and reports coverage by treatment. Normalized PAI keys with collisions are excluded rather than silently deduplicated.
