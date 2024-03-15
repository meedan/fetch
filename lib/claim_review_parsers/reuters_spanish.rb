# frozen_string_literal: true

class ReutersSpanish < Reuters
  include PaginatedReviewClaims
  def self.deprecated
    false
  end

  def fact_list_path(page = 1)
    "/pf/api/v3/content/fetch/articles-by-section-alias-or-id-v1?query=%7B%22arc-site%22%3A%22reuters%22%2C%22offset%22%3A#{(page-1)*10}%2C%22requestId%22%3A2%2C%22section_id%22%3A%22%2Ffact-check%2Fespanol%2F%22%2C%22size%22%3A20%2C%22uri%22%3A%22%2Ffact-check%2Fespanol%2F%22%2C%22website%22%3A%22reuters%22%7D&_website=reuters"
  end

  def score_map
    {
      "Erróneamente etiquetado" => 0.5,
      "Falta contexto" => 0.5,
      "Sin evidencia" => 0.5,
      "Alterado" => 0.5,
      "Falso" => 0,
      "Engañoso" => 0.5,
      "Contenido artificial" => 0,
      "Alterada" => 0.5,
      "Erróneamente etiquetada" => 0.5,
      "Parcialmente falso" => 0.5,
      "Sátira" => 0.5,
      "Erróneamente etiquetadas" => 0.5,
      "Falta Contexto" => 0.5,
      "No hay evidencia" => 0,
      "Mayormente falso" => 0.5,
      "Imagen alterada" => 0.5,
    }
  end
end
