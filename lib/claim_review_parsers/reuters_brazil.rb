# frozen_string_literal: true

class ReutersBrazil < Reuters
  include PaginatedReviewClaims
  def self.deprecated
    false
  end

  def fact_list_path(page = 1)
    "/pf/api/v3/content/fetch/articles-by-section-alias-or-id-v1?query=%7B%22arc-site%22%3A%22reuters%22%2C%22offset%22%3A#{(page-1)*10}%2C%22requestId%22%3A2%2C%22section_id%22%3A%22%2Ffact-check%2Fportugues%2F%22%2C%22size%22%3A20%2C%22uri%22%3A%22%2Ffact-check%2Fportugues%2F%22%2C%22website%22%3A%22reuters%22%7D&d=176&_website=reuters"
  end
  

  def score_map
    {
      "Legenda errada" => 0.5,
      "Falso" => 0,
      "Mídia sintética" => 0,
      "Sem contexto" => 0.5,
      "Enganoso" => 0.5,
      "Alterado digitalmente" => 0.5,
      "Parcialmente falso" => 0.5,
      "Sem evidências" => 0,
      "Imagem adulterada" => 0.5,
      "Descrição" => 0.5,
    }
  end
end
