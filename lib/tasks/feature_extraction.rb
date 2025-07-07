require 'rumale/text/tfidf_vectorizer'

module FeatureExtraction
  def self.extract_features(text)
    vectorizer = Rumale::Text::TfidfVectorizer.new
    vectorizer.fit_transform([text])
  end
end
