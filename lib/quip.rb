module Quip
  def self.all
    [
      "vegemite",
      "tim tams and coffee",
      "web2.0 koolaid",
      "bananas",
      "your inner voice",
      "procrastination",
      "faux western Buddhism",
      "complication and elaboration",
      "the present moment",
      "what isn&#8217;t being said",
      "social networks"
    ]
  end
  def self.random
    all[rand(all.length)]
  end
end
