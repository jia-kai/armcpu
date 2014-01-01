/*
 * $File: network_flow.cc
 * $Date: Wed Dec 18 23:58:20 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include "network_flow.hh"
#include "math.hh"

#include <deque>
#include <cstring>
#include <algorithm>

NetworkFlow::NetworkFlow(int nr_vtx, int src_vrx, int tgt_vtx):
	m_graph(nr_vtx), m_dist(nr_vtx), m_svtx(src_vrx), m_tvtx(tgt_vtx),
	m_arc(2)
{
}

void NetworkFlow::do_add_arc(int from, int to, weight_t cap) {
	m_arc.emplace_back(to, cap, m_graph[from].arc_start);
	m_graph[from].arc_start = m_arc.size() - 1;
}

bool NetworkFlow::dinic_bfs() {
	std::deque<int> queue;
	queue.push_back(m_svtx);
	std::fill(m_dist.begin(), m_dist.end(), -1);
	m_dist[m_svtx] = 0;
	for (auto &i: m_graph)
		i.arc_cur = i.arc_start;
	while (!queue.empty()) {
		int svtx = queue.front(),
			dt = m_dist[svtx] + 1;
		queue.pop_front();
		for (int i = m_graph[svtx].arc_start; i; ) {
			auto &a = m_arc[i];
			if (a.remain && m_dist[a.tvtx] == -1) {
				m_dist[a.tvtx] = dt;
				queue.push_back(a.tvtx);
				if (a.tvtx == m_tvtx)
					return true;
			}
			i = a.next;
		}
	}
	return false;
}

NetworkFlow::weight_t NetworkFlow::dinic_dfs(
		int v0, NetworkFlow::weight_t flow) {

	if (v0 == m_tvtx)
		return flow;
	int arc_cur = m_graph[v0].arc_cur,
		dt = m_dist[v0] + 1;
	weight_t ret = 0;
	while (arc_cur) {
		auto &a = m_arc[arc_cur];
		weight_t df;
		if (a.remain && m_dist[a.tvtx] == dt &&
				(df = dinic_dfs(a.tvtx, std::min(flow, a.remain)))) {
			ret += df;
			a.remain -= df;
			m_arc[arc_cur ^ 1].remain += df;
			flow -= df;
			if (!flow)
				break;
		}
		arc_cur = a.next;
	}
	m_graph[v0].arc_cur = arc_cur;
	if (!arc_cur)
		m_dist[v0] = -1;
	return ret;
}

NetworkFlow::weight_t NetworkFlow::calc_maxflow() {
	log_printf("computing max flow for %d vertices, %d arcs ...",
			int(m_graph.size()), int(m_arc.size() - 2));
	weight_t sum = 0;
	while (dinic_bfs())
		sum += dinic_dfs(m_svtx, numeric_max<weight_t>());
	return sum;
}

void NetworkFlow::get_minimal_cut_map(std::vector<int> &map) {
	map.resize(m_dist.size());
	for (size_t i = 0; i < m_dist.size(); i ++)
		map[i] = (m_dist[i] == -1);
}

void NetworkFlow::add_arc(int from, int to, weight_t cap) {
	dassert(from >= 0 && from < int(m_graph.size()));
	dassert(to >= 0 && to < int(m_graph.size()));
	dassert(cap >= 0);
	if (!cap)
		return;

	// log_printf("arc: %d -> %d, cap=%d", from, to, cap);

	do_add_arc(from, to, cap);
	do_add_arc(to, from, 0);
}

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

