# Validation: redesign-card-profile

- Date: 2026-11-21
- Validator: independent `feature-validator` execution
- Spec: `docs/specs/redesign-card-profile.md`
- Input status: `passing`
- Verdict: `accept` (2026-11-21, owner approval resolved the sole external blocker)
- Recommended status: `accepted`

## Resolution (2026-11-21)

The single blocking finding below — pending owner visual approval — was resolved after the
header change-request. The github-flow orchestrator served the worktree on port 3601 and
captured the corrected header at 390x844 and 1280x800 (0 console messages at both). The owner
(Fahed Hermoza) reviewed those captures against the `DESIGN.md` reference and explicitly
responded "Apruebo, publicar" for both mobile and desktop. The approved header: `NFC CONNECT`
(signal icon + text) top-left in `#484dc4`, a decorative external-link icon (`aria-hidden`)
top-right in `#6b7280`, and the ornamental status dot `#2f8f65` on the avatar (bottom-right),
all ornamental with no presence/active-NFC semantics. No technical, AA, responsive, scope, or
security regression was found. The feature moves `passing` → `accepted`. The prior `block`
below is retained for history.

## Verdict Basis (original, superseded by the resolution above)

The implementation passes the independent technical validation. No product defect, AA
regression, responsive regression, security issue, or out-of-scope implementation was found.
Final acceptance is blocked only by the explicit external condition in the spec: the owner has
not reviewed the mobile and desktop result against the original visual references. Technical
checks and validator screenshots do not substitute for that approval.

## Blocking Finding

### Owner visual approval is still pending

- Severity: High acceptance blocker; external, not a repairable technical defect.
- Evidence: `docs/specs/redesign-card-profile.md` lines 94, 107 and 111 require an explicit
  owner response for mobile and desktop before `accepted`; `feature_list.json` records
  `Owner visual review: pending`; the original reference captures are not versioned.
- Why it matters: accepting now would contradict the feature contract and incorrectly convert
  technical validation into visual approval by the owner.
- Required next action: give the owner the independent 390x844 and 1280x800 captures together
  with the original references and record an explicit dated response for both contexts.
- Verification after resolution: confirm `PROGRESS.md` and `feature_list.json` include the
  owner's explicit approval or requested changes, context/device information, and date. If the
  owner requests changes, return the feature to implementation and rerun validation.

## Reproduced Evidence

- `bash -n init.sh && ./init.sh`: exit 0. The gate executed all checks, including
  `Accessibility checks:` and `Responsive checks:`, and only printed the serve command for
  port 3601; it did not start a server.
- Independent negative copies: removing `aria-hidden="true"` from the NFC ornament failed with
  the ornament diagnostic; removing the `FH` fallback failed with the fallback diagnostic.
- Normal mobile 390x844: card 358x891 at x=16/y=24; 24px radius; NFC ornament visible but
  absent from the accessibility tree; avatar 88x88 with 460x460 source; exactly one `h1`;
  descriptive avatar alt; Tagline `lang="en"`; all eight full-width controls 308x48; no
  clipped text or horizontal overflow; 0 console messages; 5/5 requests returned 200.
- Normal desktop 1280x800: card 400x891 at x=432.5/y=24 in the 1265px content area; avatar and
  profile centered; all eight controls 350x48; no clipped text or horizontal overflow; 0
  console messages; 5/5 requests returned 200.
- Responsive matrix 320/360/375/390/480/736/768/1280: document and body scroll widths equaled
  client widths at every size; card widths were 288/328/343/358/400/400/400/400; minimum
  control dimension was 48px; no audited text was clipped.
- Keyboard/animation: Instagram focus used a 2px accent outline with 2px offset; desktop hover
  used translateY(-1.5px), the documented shadow and brightness(1.03); reduced motion set
  transition to none and transform to none while preserving focus.
- Avatar failure, isolated cache at 390x844 and 1280x800: the 88x88 frame and position were
  unchanged; `FH` rendered with the documented neutral colors and remained `aria-hidden`; alt
  remained descriptive; only `/assets/avatar.jpg` returned the expected 404. The asset was
  restored with SHA-256 `b73575ae31cee7ead9de09377d90b60d3cbf2079402602c217a47f02afe4aa7c`.
- Lighthouse mobile navigation on `http://127.0.0.1:3601/`: Accessibility 100, Best Practices
  100, Agentic Browsing 100 and SEO 92; 46 audits passed. The only failure was the pre-existing,
  out-of-scope SEO `meta-description` audit; no accessibility failure was reported.
- Scope regression: `index.html` changes only add the ornamental label/dot; seven destinations,
  vCard anchor, footer links and production metadata remain intact; avatar, vCard and OG assets
  have no diff; the other five redesign features remain `not_started`.
- Independent screenshots:
  `/var/folders/nn/pfw3yqwx4wsdch14n5z5wpkh0000gn/T/opencode/redesign-card-profile-validator-390x844.png`
  and
  `/var/folders/nn/pfw3yqwx4wsdch14n5z5wpkh0000gn/T/opencode/redesign-card-profile-validator-1280x800.png`.
- Server was stopped and port 3601 was confirmed free after validation.

## Quality And Security

- Correctness, scope, maintainability, harness and durable documentation: technical pass.
- No persistent E2E harness exists; the spec explicitly uses gate, browser matrix and Lighthouse
  for this static slice, all reproduced independently.
- Feature-scoped security checklist: no secrets, authentication boundary, user input, file
  upload, dependency, server/client, or external-service changes were introduced. The page
  remains intentionally public and static. No security finding.
- `git diff --check` and JSON parsing passed. No commit was created.

## Follow-Up

This is not an implementation repair brief because the blocker cannot be fixed in code. Obtain
and persist the owner's explicit visual decision. Revalidate only if that decision requests
product changes; otherwise the orchestrator may persist acceptance after confirming the recorded
approval and this technical validation remain applicable.
