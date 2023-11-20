# frozen_string_literal: true

class ReutersSpanish < Reuters
  include PaginatedReviewClaims
  def self.deprecated
    false
  end

  def fact_list_path(page = 1)
    "/news/archive/factCheckSpanishNew?view=page&page=#{page}&pageSize=10"
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
