module SubmissionsHelper
  def hsv_to_rgb(h, s, v)
    h, s, v = h.to_f/360, s.to_f/100, v.to_f/100
    h_i = (h*6).to_i
    f = h*6 - h_i
    p = v * (1 - s)
    q = v * (1 - f*s)
    t = v * (1 - (1 - f) * s)
    r, g, b = v, t, p if h_i == 0
    r, g, b = q, v, p if h_i == 1
    r, g, b = p, v, t if h_i == 2
    r, g, b = p, q, v if h_i == 3
    r, g, b = t, p, v if h_i == 4
    r, g, b = v, p, q if h_i == 5
    '#%02x%02x%02x' % [(r*255).to_i, (g*255).to_i, (b*255).to_i]
  end

  def color_map(scale) # scale \in [0, 1]
    scale = scale < 0 ? 0 : scale > 1 ? 1 : scale
    scale = scale < 0.5 ? 0.5 - 2 * (0.5 - scale) ** 2 : 0.5 + 2 * (scale - 0.5) ** 2
    hsv_to_rgb(scale * 120, 100, 85 - 40 * scale)
  end

  def time_str(x)
    ret = number_with_precision(x, precision: 1)
    # pad by invisible digits to align decimal
    prefix = '0' * [0, 6 - ret.length].max
    raw("<span style=\"visibility: hidden;\">#{prefix}</span>" + ret)
  end

  def user_can_view?(user, submission, contest)
    return true if user&.id == submission.user_id
    if contest && contest == submission.contest
      sub_team = contest.find_registration(submission.user)&.team
      team = contest.find_registration(user)&.team
      return true if team && team == sub_team
    end
    false
  end
end
