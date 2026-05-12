class RuleEvaluatorService
  def self.evaluate_all
    data_items = DataItem.where.not(caption: nil)
    location_keywords = Location.pluck(:lokasi)

    [
      evaluate_rule("Exact Match Keyword", data_items, location_keywords) do |caption, keywords|
        InstagramScraperController.detect_location_ner(caption, keywords)[:locations_from_keywords]
      end,

      evaluate_rule("Preposisi", data_items, location_keywords) do |caption, keywords|
        InstagramScraperController.detect_location_ner(caption, keywords)[:locations_from_pattern]
      end,

      evaluate_rule("Struktur Deskriptif", data_items, location_keywords) do |caption, keywords|
        InstagramScraperController.detect_location_ner(caption, keywords)[:locations_from_structure]
      end,

      evaluate_rule("All Rule (Gabungan)", data_items, location_keywords) do |caption, keywords|
        ner = InstagramScraperController.detect_location_ner(caption, keywords)

        # Deteksi gabungan minimal 2 rule mendeteksi lokasi
        match_sources = [
          ner[:locations_from_keywords].present?,
          ner[:locations_from_pattern].present?,
          ner[:locations_from_structure].present?
        ]

        match_sources.count(true) >= 1 ? [true] : []  # ← return array agar aman diproses
      end
    ]
  end

  def self.evaluate_rule(rule_name, data_items, location_keywords)
    tp = fp = fn = tn = 0

    data_items.each do |item|
      expected = item.label == 1 ? 1 : 0

      result = yield(item.caption, location_keywords)
      found = if result.respond_to?(:any?)
                result.any? ? 1 : 0
              else
                result.to_i
              end

      if found == 1 && expected == 1
        tp += 1
      elsif found == 1 && expected == 0
        fp += 1
      elsif found == 0 && expected == 1
        fn += 1
      elsif found == 0 && expected == 0
        tn += 1
      end
    end

    accuracy = (tp + tn).to_f / (tp + tn + fp + fn)
    precision = tp / (tp + fp).to_f rescue 0.0
    recall    = tp / (tp + fn).to_f rescue 0.0
    f1_score  = 2 * precision * recall / (precision + recall).to_f rescue 0.0

    {
      rule: rule_name,
      tp: tp,
      fp: fp,
      fn: fn,
      tn: tn,
      accuracy: accuracy.round(2),
      precision: precision.round(2),
      recall: recall.round(2),
      f1_score: f1_score.round(2)
    }
  end
end
