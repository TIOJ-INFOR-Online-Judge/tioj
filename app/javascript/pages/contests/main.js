import { contestRanklistReorder } from "./contest_ranklist_reorder";
import { contestDashboardRefresh } from "./contest_dashboard_refresh";

export function initContestRanklist(data, contest_type) {
  contestDashboardRefresh();
  contestRanklistReorder(data, contest_type, -1);
}