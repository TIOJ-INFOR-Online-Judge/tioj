module ContestsHelper
  def contest_type_desc_map
    {
      "gcj" => "gcj style (partial/dashboard)",
      "ioi" => "ioi style (partial/no dashboard)",
      "acm" => "acm style (no partial/dashboard)",
      "ioicamp" => "ioicamp style (partial+penalty/dashboard)",
    }
  end
end
