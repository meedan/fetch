# frozen_string_literal: true

class ReutersBrazil < Reuters
  include PaginatedReviewClaims
  def self.deprecated
    false
  end

  def fact_list_path(page = 1)
    "/news/archive/factcheckportuguesenew?view=page&page=#{page}&pageSize=10"
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
