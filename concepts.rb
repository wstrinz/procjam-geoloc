module Concepts
  require 'open-uri'
  require 'json'
  def get_surface(word)
    data = open("http://conceptnet5.media.mit.edu/data/5.4/search?rel=/r/IsA&end=/c/en/#{word}&limit=100")
    JSON.parse(data.read)['edges'].map{|e| e['surfaceStart']}.compact
  end
end

module Words
  require 'wordnet'
  ::WordNet::DB.path = "./word_dbs/wordnet/"

  class WN
    WORDSFLIP = ->(category, word) { WordNet::Lemma.find(word, category) }
    IS_CAP = ->(n){ n[0].upcase == n[0] }
    UNDERSCORE_TO_SPACE = ->(n) { n.gsub('_', ' ') }

    def self.lemma_for(word, category = nil)
      if category
        op = WORDSFLIP.to_proc.curry(2)[category]
      else
        op = WordNet::Lemma.find_all.to_proc
      end

      op[word]
    end

    def self.hyponym_leaves(word, category = nil)
      lem = lemma_for(word, category)
      format_metiers lem.synsets.map(&method(:synset_hyponym_leaves)).flatten
    end

    def self.synset_hyponym_leaves(synset)
      words = synset.words
      hyps = synset.hyponym
      if hyps == []
        words
      else
        hyps.map &method(:synset_hyponym_leaves)
      end
    end

    def self.remove_proper_names(list)
      list.reject &IS_CAP
    end

    def self.format_metiers(list)
      list.reject(&IS_CAP).map(&UNDERSCORE_TO_SPACE)
    end

    def self.collect_metiers(word)
      format_metiers(Words::WN.hyponym_leaves(word, :noun)).uniq
    end

    def self.useful_nouns
      collect_metiers("professional")
    end
  end
end

puts Words::WN.useful_nouns
