# frozen_string_literal: true

# Parser for
class GESISClaims < ClaimReviewParser
  include GenericRawClaimParser
  def self.deprecated
    true
  end

  def post_request_get_fact_ids(page, limit)
    RestClient::Request.execute(
      :method => :post,
      :url => 'https://data.gesis.org/claimskg/sparql',
      :payload => {
        query: "PREFIX schema: <http://schema.org/> PREFIX nif: <http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#> select * where {select distinct (?claims as ?id) COALESCE(?date, 'Unknown') as ?date ?truthRating ?ratingName COALESCE(?author, 'Unknown') as ?author COALESCE(?link, '') as ?link?text where { ?claims a schema:ClaimReview . OPTIONAL {?claims schema:headline ?headline} . ?claims schema:reviewRating ?truth_rating_review . ?truth_rating_review schema:alternateName ?ratingName . ?truth_rating_review schema:author <http://data.gesis.org/claimskg/organization/claimskg> . ?truth_rating_review schema:ratingValue ?truthRating . OPTIONAL {?claims schema:url ?link} . ?item a schema:CreativeWork . ?claims schema:itemReviewed ?item . ?item schema:text ?text . OPTIONAL {?item schema:author ?author_info . ?author_info schema:name ?author } . OPTIONAL {?item schema:datePublished ?date} . }ORDER BY desc (?date)}LIMIT #{limit} OFFSET #{limit * (page - 1)}"
      },
      :headers => {"Accept": 'application/sparql-results+json'},
      :timeout => 10,
      :open_timeout => 10
    )
  end

  def get_fact_ids(page, limit = 100)
    retry_count = 0
    begin
      JSON.parse(
        self.post_request_get_fact_ids(page, limit)
      )['results']['bindings'].collect { |c| [c['id']['value'].split('/').last, id_from_raw_claim_review({ 'content' => c })] }
    rescue RestClient::ServiceUnavailable, RestClient::BadGateway => e
      if retry_count < 3
        retry_count += 1
        sleep(1)
        retry
      else
        Error.log(e)
        return []
      end
    rescue StandardError => e
      Error.log(e)
      []
    end
  end

  def get_all_fact_ids
    page = 1
    results = get_fact_ids(page)
    all_results = results
    until results.empty?
      page += 1
      results = get_fact_ids(page)
      results.each do |id|
        all_results << id
      end
    end
    all_results
  end

  def post_request_fact_id(fact_id)
    RestClient::Request.execute(
      :method => :post,
      :url => 'https://data.gesis.org/claimskg/sparql',
      :payload => {
        query: 'PREFIX schema: <http://schema.org/> PREFIX nif: <http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#> select distinct (?claim as ?id) COALESCE(?date, "") as ?date COALESCE(?keywords, "") as ?keywords group_concat(distinct ?entities_name, ";!;") as ?mentions group_concat(distinct ?entities_name_article, ";!;") as ?mentionsArticle COALESCE(?language, "") as ?language group_concat(?citations, ";!;") as ?citations ?truthRating ?ratingName ?text COALESCE(?author, "") as ?author COALESCE(?source, "") as ?source COALESCE(?sourceURL, "") as ?sourceURL COALESCE(?link, "") as ?link where { ?claim a schema:ClaimReview . OPTIONAL{ ?claim schema:headline ?headline} . ?claim schema:reviewRating ?truth_rating_review . ?truth_rating_review schema:author <http://data.gesis.org/claimskg/organization/claimskg> . ?truth_rating_review schema:alternateName ?ratingName . ?truth_rating_review schema:ratingValue ?truthRating . OPTIONAL {?claim schema:url ?link} . ?item a schema:CreativeWork . ?item schema:text ?text . ?claim schema:itemReviewed ?item . OPTIONAL {?item schema:mentions ?entities . ?entities nif:isString ?entities_name} . OPTIONAL {?claim schema:mentions ?entities_article . ?entities_article nif:isString ?entities_name_article} . OPTIONAL {?item schema:author ?author_info .  ?author_info schema:name ?author } . OPTIONAL {?claim schema:inLanguage ?inLanguage . ?inLanguage schema:name ?language} . OPTIONAL {?claim schema:author ?sourceAuthor . ?sourceAuthor schema:name ?source . ?sourceAuthor schema:url ?sourceURL} . OPTIONAL {?item schema:keywords ?keywords} . OPTIONAL {?item schema:citation ?citations} . OPTIONAL {?item schema:datePublished ?date} . FILTER (?claim = <http://data.gesis.org/claimskg/claim_review/' + fact_id + '>) }'
      },
      :headers => {"Accept": 'application/sparql-results+json'},
      :timeout => 10,
      :open_timeout => 10
    )
  end

  def get_fact(fact_id)
    return {}
    # retry_count = 0
    # begin
    #   JSON.parse(
    #     self.post_request_fact_id(fact_id)
    #   )['results']['bindings'][0]
    # rescue RestClient::ServiceUnavailable, RestClient::BadGateway => e
    #   if retry_count < 3
    #     retry_count += 1
    #     sleep(1)
    #     retry
    #   else
    #     Error.log(e)
    #     return {}
    #   end
    # rescue StandardError => e
    #   Error.log(e)
    #   {}
    # end
  end

  def get_claim_reviews
    return nil
    # get_all_fact_ids.shuffle.each_slice(100) do |id_set|
    #   existing_ids = ClaimReview.existing_ids(id_set.collect(&:last), self.class.service)
    #   new_ids = id_set.reject { |x| existing_ids.include?(x.last) }.collect(&:first)
    #   results =
    #     Parallel.map(new_ids, in_processes: Settings.parallelism_for_task(:get_claim_reviews), progress: 'Downloading GESIS Corpus') do |id|
    #       [id, get_fact(id)]
    #     end
    #   process_claim_reviews(results.compact.map { |x| parse_raw_claim_review(QuietHashie[{ id: x[0], content: x[1] }]) })
    # end
  end

  def author_from_raw_claim_review(raw_claim_review)
    get_key_value_from_raw_claim_review(raw_claim_review, 'source')
  end

  def created_at_from_raw_claim_review(raw_claim_review)
    time_text = get_key_value_from_raw_claim_review(raw_claim_review, 'date')
    if time_text && !time_text.empty?
      Time.parse(time_text)
    end
  rescue StandardError => e
    Error.log(e)
  end

  def get_key_value_from_raw_claim_review(raw_claim_review, key)
    raw_claim_review['content'] &&
    raw_claim_review['content'][key] &&
    raw_claim_review['content'][key]['value']
  rescue StandardError => e
    Error.log(e)
  end

  def author_link_from_raw_claim_review(raw_claim_review)
    get_key_value_from_raw_claim_review(raw_claim_review, 'sourceURL')
  end

  def claim_headline_from_raw_claim_review(raw_claim_review)
    get_key_value_from_raw_claim_review(raw_claim_review, 'text')
  end


  def claim_result_from_raw_claim_review(raw_claim_review)
    get_key_value_from_raw_claim_review(raw_claim_review, 'ratingName')
  end

  def claim_result_score_from_raw_claim_review(raw_claim_review)
    get_key_value_from_raw_claim_review(raw_claim_review, 'truthRating')
  end

  def claim_url_from_raw_claim_review(raw_claim_review)
    get_key_value_from_raw_claim_review(raw_claim_review, 'link')
  end

  def id_from_raw_claim_review(raw_claim_review)
    get_key_value_from_raw_claim_review(raw_claim_review, 'id').to_s.split('/').last
  end
end
