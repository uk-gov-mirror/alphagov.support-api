# Deleting old feedback

## Benchmarking

**Important:** if you want to measure the impact on performance of deleting old
feedback, [benchmark](benchmarking_anonymous_feedback_queries.md) at three
stages:

- _before_ deleting any feedback
- _after_ deleting feedback but _before_ vacuuming the table
- _after_ vacuuming the table

Having benchmarks both at the baseline and after each discrete action allows you
to observe the impact of each action. Without capturing a baseline benchmark, it
would be difficult to draw any conclusions.

## Deleting the database records

```sh
bundle exec rake old_feedback:delete
```

Removes feedback older than two years in batches to avoid long locks. This
doesn't resize the table on disk - the database pages are only marked as
freed/reusable. The vacuum task will shrink the disk usage, which also affects
performance.

## Recovering disk space

```sh
bundle exec rake old_feedback:vacuum
```

Rewrites the `anonymous_contacts` table so the space the deletion freed is
returned to the disk. This blocks every read and write to the table while it
runs, which may prevent feedback submission. It reports how long it took so that
runs in e.g. integration can inform whether the process is acceptably efficient
to run in production.
