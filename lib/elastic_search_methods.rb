# frozen_string_literal: true

module ElasticSearchMethods
  def es_hostname
    Settings.get('es_host')
  end

  def client
    Elasticsearch::Transport::Client.new(url: es_hostname)
  end
end
