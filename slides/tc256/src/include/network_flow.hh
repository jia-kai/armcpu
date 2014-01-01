/*
 * $File: network_flow.hh
 * $Date: Wed Dec 18 22:10:35 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#pragma once

#include "utils.hh"
#include <vector>

/*!
 * solving max flow by dinic
 */
class NetworkFlow {
	using weight_t = int;
	struct Vertex {
		int arc_start, arc_cur;

		Vertex():
			arc_start(0)
		{}
	};
	struct Arc {
		int tvtx,	// tvtx number
			next;	// number of next arc from same vertex, or 0 if reaching end
		weight_t remain;	// remaining capacity

		Arc() = default;

		Arc(int tvtx_, weight_t remain_ = 0, int next_ = 0):
			tvtx(tvtx_), next(next_), remain(remain_)
		{ }
	};
	std::vector<Vertex> m_graph;
	std::vector<int> m_dist;
	int m_svtx, m_tvtx;

	std::vector<Arc> m_arc;
	/* arc[i] = (u->v) <==> arc[i ^ 1] = (v->u)
	 * usable arc starts from arc[2]
	 */

	void do_add_arc(int from, int to, weight_t cap); 

	bool dinic_bfs();

	/*!
	 * dfs from a vertex with initial flow, return actual flow
	 */
	weight_t dinic_dfs(int v0, weight_t flow);

	public:
		NetworkFlow(int nr_vtx, int src_vrx, int tgt_vtx);

		void add_arc(int from, int to, weight_t cap);

		weight_t calc_maxflow();

		/*!
		 * must have called calc_maxflow
		 * map[i] = 0 for S, 1 for T
		 */
		void get_minimal_cut_map(std::vector<int> &map);
};

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

