## Fetch
[![Code Climate](https://api.codeclimate.com/v1/badges/42a4437feae3058176ff/maintainability)](https://codeclimate.com/repos/5ef4a2779226cb00dd00473b/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/42a4437feae3058176ff/test_coverage)](https://codeclimate.com/repos/5ef4a2779226cb00dd00473b/test_coverage)

A Fact / Claim Review aggregation service.

## Development

- `docker-compose build`
- `docker-compose up`
- Open http://localhost:9292/about for the Fetch API
- Open http://localhost:5601 for the Kibana UI
- Open http://localhost:9200 for the Elasticsearch API
- `docker-compose exec fetch bash` to get inside the Fetch service console and directly debug issues

## Testing

- `docker-compose run fetch test`

## Rake Tasks

- `bundle exec rake test` - run test suite
- `bundle exec rake list_datasources` - list all services currently implemented in `fetch`
- `bundle exec rake collect_datasource [service] [cursor_back_to_date] [overwrite_existing_claims]` - initiate crawl on `service` that optionally forces collection back to a `Time`-parseable `cursor_back_to_date`. Optionally allow `overwrite_existing_claims` - can be `true` or `false` - if true, will overwrite documents - useful for addressing issues with malformed existing documents.
- `bundle exec rake collect_all [cursor_back_to_date] [overwrite_existing_claims]` - Kickoff crawl for all currently-implemented services. Optionally allow `overwrite_existing_claims` - can be `true` or `false` - if true, will overwrite documents - useful for addressing issues with malformed existing documents.

## Adding a New Data Source

At a high level, Fetch is a series of scrapers for paginating through news sources, identifying article URLs, and then iterating through those article URLs to extract relevant fields. At a *minimum*, we expect that each and every identified article will contain a `claim_review_headline`, `claim_review_url`, `created_at`, and `id`. These are all strings, spare `created_at` which is a Time object.

While its possible to interact with the database and build your own scraper totally independent of other scrapers, a ton of useful, overlapping methods are contained within the parent class `ClaimReviewParser` (and, it should be stated, building a scraper *outside* of `ClaimReviewParser` will likely cause tons of annoying issues). All scrapers are subclasses of `ClaimReviewParser`, or subclasses of some other parser that is in turn a subclass of `ClaimReviewParser`. Additionally, there is a `PaginatedReviewClaims` module that can be included into any scraper - this contains tons of helper methods specifically around paginating through a news source. 

To explain a bit more, take the example of the `AFP` parser class in this codebase. It is a subclass of `ClaimReviewParser`, and also includes the `PaginatedReviewClaims` module. It defines a hostname (i.e. where the website is) and a `fact_list_path` which is the pagination path given a page number. By including `PaginatedReviewClaims`, it will visit via hostname and iterate through pages using `fact_list_path`'s specified path, and on each page, extract links matching `url_extraction_search` - for each link, it will pluck out the URL via `url_extractor(atag)`. Then, it will, in parallel, go to 5 concurrent URLs that are not yet included in the existing database - for each, it will load an object `raw_claim_review` that looks like `{page: [NOKOGIRI_PAGE_CONTENTS], url: [URL_OF_PAGE]}`. That gets emitted into `parse_raw_claim_review(raw_claim_review)` which is where the substantive contents of the scraper actually lives. Here, you can select out the contents of interest and create a `claim_review` object ready for storage. We allow the following fields as of right now:

- `id`: Mandatory - some unique identifying string (it's hashed right before storage anyways). Typically the claim URL.
- `created_at`: Mandatory - a timestamp for when the claim was published
- `author`: a string for the author's name
- `author_link`: a string for the author's URL
- `claim_review_headline`: Mandatory - a string for the headline
- `claim_review_body`: The string "body" of the claim
- `claim_review_reviewed`: The string of what is being reviewed in the claim
- `claim_review_image_url`: The string URL for a source image
- `claim_review_result`: The string claim result (i.e. True/False/Unknown/etc)
- `claim_review_result_score`: The float/integer value representing truth/falsity (0-1 typically)
- `claim_review_url`: The claim URL
- `raw_claim_review`: Any raw data worth capturing (typically ld+json schema.org blocks), any JSON-able format is fine here.

Once in place, all that's needed is pushing the new subclass to dev and then prod - on boot, `Fetch` will detect the presence of a new `ClaimReviewParser` subclass and start a `RunClaimReviewParser` task for the subclass, which will self-generate new checks according to the subclasses `interevent_time` (default is daily in non-prod, hourly in prod). If you look at all the other `AFP`-subclassed scrapers, you'll notice that each one has significantly fewer defined functions - ideally you're able to represent families of sites this way. 

Sometimes, parsing is more complicated - if the pagination mechanism is `JSON` based (i.e. some asynchronous event like a "load more" at the bottom of a page), you can specify that and have pages render as JSON objects rather than Nokogiri-parsed HTML by adding a `@fact_list_page_parser = 'json'` into the class initialization. If you need to slow down the parser, add a `@per_article_sleep_time = 3` and a `@run_in_parallel = false` to the initialization to specify how long it should pause between article parses, and whether or not it should run multiple at the same time. Rarely, pagination routines are too complex for `PaginatedReviewClaims`, and need to be explicitly written. Examples of that sort of situation are hard to generalize, but you can see how that's been dealt with in `GoogleFactCheck`, `BoomLive`, `DataCommons`, `Mafindo`, and a few others.

In other situations, light overrides of `PaginatedReviewClaims` logic is necessary as seen in `NewtralFakes`, `PesaCheck`, and `TempoCekfakta`. In rare cases, we fully stop supporting scrapers, but want to keep the code in case we have to re-enable - that's done with a `self.deprecated` method return value of `true` as seen in `Tattle`, `AajtakIndiaToday`, and a few others.

## Reimporting/Rebuilding/Debugging an existing data Source

Sometimes, we need to rebuild a data source. One hypothetical reason could be if a publisher has added `ClaimReview` objects to all historical data, and we now want to re-capture high quality claims data. In that situation, once we have deployed our updates to the parser to collect those fixes, we will manually re-run a `RunClaimReviewParser` task in a console session with fetch - to run it within the session, we'd run:

```
RunClaimReviewParser.new.perform("service_name", (Time.now-60*60*24*365*15).to_s, true)
```

To run asynchronously, we'd run:
```
RunClaimReviewParser.perform_async("service_name", (Time.now-60*60*24*365*15).to_s, true)
```

The way that all tasks run is that they paginate backwards in time until they see articles they've parsed before, *or*, if a date is specified, they keep paginating until they hit articles from that date. In this example, we set the date 15 years back to so that, in effect, we go re-build *all* data.

If you just want to verify if/how an article is parsed by a service, you can run it this way:
```
ServiceParserClassHere.test_parser_on_url(url)
```
