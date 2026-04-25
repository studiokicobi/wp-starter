# Design intake checklist

Defines what "a completed Figma design" means for this workflow. Phase 0 of the build workflow checks the design against this list before any code is written.

A design meets the bar when Phases 1-11 can run without looping back to the designer for missing information.

## How to use

**Solo practice (you are both designer and developer).** Run the checklist against your own file and sign off against yourself, in writing, with a date. The date is what keeps you from quietly moving on with gaps unaddressed.

**Separate designer (external or in-house).** Share this file before engagement so they know what "done" means. At Phase 0, walk the checklist with the client as a sign-off contract: every box checked or explicitly waived, in writing.

Either way, unchecked items at Phase 0 mean the design isn't ready. Don't start the build.

## Scope

Gate decisions — settle these before token or component work.

- **Dark mode** — fully specified or explicitly out. Not "we'll figure it out."
- **Navigation** — header, footer, and mobile navigation drawn.
- **Error / 404 pages** — drawn or waived in writing.
- **Third-party integrations identified.** Contact forms (existing system? new? native?), newsletter ESP, map provider, analytics, any embedded service. Integration decisions made mid-build are a scope-creep pattern — close the gap here.

## Token layer

- **Palette.** Named colors, not loose swatches.
- **Type scale.** Sizes and weights actually used in the design, not the entire Figma style library.
- **Spacing scale.** Explicit values (e.g. 4 / 8 / 16 / 24 / …), not eyeballed gaps per section.
- **Content widths.** At least one breakpoint, ideally mobile + desktop.

## Component layer

- **Every unique section drawn once.** No redraws of the same shape.
- **Repeated sections reuse the same component.** Not recopied frames.
- **Component hierarchy is visible.** Primitives, composites, and sections are distinguished via Figma's component / variant / instance system. A design where every section is a frame-of-frames with no main components is technically "drawn" but produces garbage for extraction and automation.
- **Interactive states defined.** Default, hover, focus for components that have them.

## Page layer

- **Every page in the agreed sitemap** — not just homepage plus a few.
- **Dynamic pages in a populated state.** Blog index, CPT archives, search results.
- **Empty / loading states** for anything the client will see regularly.

## Responsive

- **Mobile + desktop per section.** Tablet is derivable when the ends behave.
- **Tablet addressed for sections that don't interpolate cleanly.** A layout that switches from 3-column to 1-column needs a 2-column intermediate — show it.

## Content

- **Representative-length real copy.** Not lorem ipsum. Doesn't have to be final, but should be in the ballpark of production length so layout assumptions hold at Phase 8.
- **Real-enough imagery with rights clearance.** Images are client-owned, client-licensed, or flagged for replacement with a concrete sourcing plan (stock budget approved, AI-generated with review, custom photography booked). Stock images the client doesn't have rights to use are a silent liability.

## Not required

Don't let designers (including yourself) block on these — they belong downstream:

- Pixel-level annotations on every element — tokens + AI derive this.
- Animation / micro-interaction specs — phase these after build is shaped.
- Pixel parity between breakpoints. Set the expectation up front: a token-driven build produces brand-parity, not pixel-parity.

## Incompleteness signatures

Phase 0 rejects these:

- "We'll figure mobile out in dev" → patterns thrash at Phase 3.
- "Dark mode later" → guaranteed scope creep.
- "47 button variants, all basically the same" → not systematic.
- Lorem ipsum throughout → layout assumptions break at Phase 8.
- Sections drawn as frames-of-frames with no component structure → extraction produces garbage.
- Stock images without rights clearance → silent liability that surfaces at launch.

## The judgment call

Where "completed enough to start" ends and "more detail belongs upstream" begins. The line: if the designer can't answer *"name every page and show me each one at mobile + desktop"* without referring to unfinished work, it's not complete.
