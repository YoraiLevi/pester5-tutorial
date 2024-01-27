# What's executed?

Following Pester's [Discovery and Run](https://pester.dev/docs/usage/discovery-and-run) we're introduced to the "Discovery" and "Run" phases Pester's execution and in
[Setup and teardown](https://pester.dev/docs/usage/setup-and-teardown) we're shown a rough skeleton for the `Blocks` layout. Both articles are short and to the point but they do not demonstrate any edge cases or pitfalls that can occur. That's our job here.

Assuming you've read these articles, you probably understand that:

1) The discovery phase executes before the run phase
1) If and where you should place Before*/After*/Describe/Context blocks and at what phase they're executed.
1) 